#!/usr/bin/env python3
"""WiFi-Direct WebSocket test client for the Masjid You sync protocol.

Talks to the TV host's local_ws_server (port 8080) which speaks the
SyncPacket JSON text-frame protocol (packages/shared_models).

Implemented with the stdlib only (no third-party deps): the dart
`shelf_web_socket` server interoperates reliably with a minimal RFC6455
client that does NOT negotiate permessage-deflate, which is exactly what
this does. Run directly:  python3 ws_test.py <ip> -a getInitialState
"""
import argparse
import base64
import json
import os
import socket
import sys
import time

ACTIONS = [
    "getInitialState",
    "triggerBeep",
    "skipAdhan",
    "startIqomah",
    "startShalat",
    "finishShalat",
]

VALID_PHASES = ["normal", "preAdhan", "adhan", "khutbah", "preIqomah", "shalat"]


class WSClient:
    def __init__(self, host, port, timeout=8.0):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        self.sock.settimeout(timeout)
        self.sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        self.timeout = timeout
        self._handshake(host, port)

    def _handshake(self, host, port):
        key = base64.b64encode(os.urandom(16)).decode()
        req = (
            f"GET / HTTP/1.1\r\n"
            f"Host: {host}:{port}\r\n"
            f"Upgrade: websocket\r\n"
            f"Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            f"Sec-WebSocket-Version: 13\r\n\r\n"
        )
        self.sock.sendall(req.encode())
        # baca hingga akhir header HTTP (CRLFCRLF)
        buf = b""
        while b"\r\n\r\n" not in buf:
            chunk = self.sock.recv(4096)
            if not chunk:
                raise ConnectionError("connection closed during WS handshake")
            buf += chunk
        if not buf.startswith(b"HTTP/1.1 101"):
            raise ConnectionError(
                "WS handshake failed: " + buf.decode(errors="replace").split("\r\n")[0]
            )
        self._pending = buf.split(b"\r\n\r\n", 1)[1]

    def _read_exact(self, n):
        buf = b""
        while len(buf) < n:
            if getattr(self, "_pending", b""):
                take = self._pending[: n - len(buf)]
                buf += take
                self._pending = self._pending[len(take):]
                continue
            chunk = self.sock.recv(n - len(buf))
            if not chunk:
                raise ConnectionError("connection closed while reading")
            buf += chunk
        return buf

    def close(self):
        try:
            self.sock.close()
        except Exception:
            pass

    def send_text(self, payload):
        data = json.dumps(payload).encode("utf-8")
        mask = os.urandom(4)
        masked = bytes(b ^ mask[i % 4] for i, b in enumerate(data))
        n = len(data)
        header = bytearray([0x81])  # FIN + text
        if n < 126:
            header.append(0x80 | n)
        elif n < 65536:
            header.append(0x80 | 126)
            header += n.to_bytes(2, "big")
        else:
            header.append(0x80 | 127)
            header += n.to_bytes(8, "big")
        self.sock.sendall(bytes(header) + mask + masked)

    def _recv_frame(self):
        first = self._read_exact(2)
        b1, b2 = first[0], first[1]
        fin = (b1 >> 7) & 1
        opcode = b1 & 0x0F
        masked = (b2 >> 7) & 1
        length = b2 & 0x7F
        if length == 126:
            length = int.from_bytes(self._read_exact(2), "big")
        elif length == 127:
            length = int.from_bytes(self._read_exact(8), "big")
        mask = None
        if masked:
            mask = self._read_exact(4)
        payload = self._read_exact(length)
        if mask:
            payload = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
        return fin, opcode, payload

    def recv_all(self, run_for):
        end = time.time() + run_for
        # ignore control/ping frames, handle continuation for text
        data = b""
        while time.time() < end:
            try:
                fin, opcode, payload = self._recv_frame()
            except socket.timeout:
                return
            except ConnectionError:
                return
            if opcode == 0x9:  # ping -> pong
                self.sock.sendall(bytes([0x8A, 0x80, 0, 0, 0, 0]) + b"\x00" * 0)
                continue
            if opcode == 0x8:  # close
                return
            if opcode == 0x1 or opcode == 0x2 or opcode == 0x0:
                data += payload
                if fin and (opcode == 0x1 or opcode == 0x2):
                    yield data
                    data = b""


def run(host, port, actions, force_phase, json_input, timeout, run_for):
    frames = []
    if json_input is not None:
        frames.append(json.loads(json_input))
    if force_phase is not None:
        frames.append({"action": "forcePhase", "payload": {"phase": force_phase}})
    frames += [{"action": a, "payload": {}} for a in actions]

    if not frames:
        print("error: no action to send", file=sys.stderr)
        return 2

    ws = WSClient(host, port, timeout=timeout)
    print(f"connected: ws://{host}:{port}", flush=True)

    for f in frames:
        raw = json.dumps(f)
        ws.send_text(f)
        print(f"  >> {raw}", flush=True)

    got_state = False
    for message in ws.recv_all(run_for):
        try:
            data = json.loads(message.decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError):
            print(f"  [non-json] {message!r}")
            continue
        if isinstance(data, dict) and data.get("action") == "stateUpdate":
            p = data.get("payload", {})
            got_state = True
            print(
                f"  << stateUpdate: phase={p.get('phase')} prayer={p.get('prayer')} "
                f"remaining={p.get('remainingSeconds')}s",
                flush=True,
            )
        else:
            print(f"  << {data}", flush=True)

    ws.close()
    return 0


def main():
    ap = argparse.ArgumentParser(description="Masjid You WS control client (stdlib only)")
    ap.add_argument("host", help="TV host IP")
    ap.add_argument("-p", "--port", type=int, default=8080)
    ap.add_argument("-a", "--action", action="append", choices=ACTIONS,
                    help="sync action to send (repeatable)")
    ap.add_argument("-f", "--force-phase", choices=VALID_PHASES, help="forcePhase")
    ap.add_argument("-j", "--json", help="raw JSON packet to send")
    ap.add_argument("-t", "--timeout", type=float, default=5.0, help="conn/disconnect timeout")
    ap.add_argument("-r", "--run-for", type=float, default=3.0, help="seconds to listen for replies")
    ap.add_argument("-q", "--quiet", action="store_true")
    args = ap.parse_args()

    try:
        rc = run(args.host, args.port, args.action or [], args.force_phase,
                 args.json, args.timeout, args.run_for)
    except ConnectionRefusedError:
        print(f"error: connection refused on {args.host}:{args.port}", file=sys.stderr)
        return 1
    except socket.timeout:
        print("error: timeout connecting", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"error: {type(e).__name__}: {e}", file=sys.stderr)
        return 1
    return rc


if __name__ == "__main__":
    sys.exit(main())
