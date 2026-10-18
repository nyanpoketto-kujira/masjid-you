# Rencana Kasar — Bluetooth RFCOMM (TV Host <-> Remote)

Dibuat: 2026-10-19 | Sumber: BluetoothSyncPlugin.kt, bluetooth_host_service.dart, bluetooth_client_service.dart
Status: RENCANA SAJA. Belum ada patch/kode. Urut prioritas P0 > P1 > P2.

> **Status akhir (2026-10-19, setelah verifikasi kode):** semua P0/P1/P2 sudah
> tertutup di kode, KECUALI satu sisa (lihat `[TERBUKA]` di item 8b).
> Legenda: `[DIPATCH]` = benar-benar diubah · `[SUDAH BENAR di baseline — bukan bug]` = klaim plan tidak cocok dengan kode apa adanya · `[TERBUKA]` = belum ditutup.

## P0 — bikin fitur nggak jalan / data bisa rusak

1. **makeDiscoverable salah total di Android < 12** — `[DIPATCH]` sekarang `ACTION_REQUEST_DISCOVERABLE` + `startActivityForResult` untuk semua versi; `startDiscovery()` tidak dipakai lagi.
2. **return `true` palsu sebelum user konfirmasi** — `[DIPATCH]` `pendingDiscoverable: MethodChannel.Result` dibalas dari `addActivityResultListener` (`RESULT_CANCELED` = ditolak), plus watchdog.
3. **Izin `BLUETOOTH_ADVERTISE` nggak pernah diminta** — `[DIPATCH]` ADVERTISE masuk `hasPermission()` + `neededPermissions(mode="host")`. (Manifest sendiri sudah punya izin ini.)
4. **`sendFrame()` tanpa lock** — `[DIPATCH]` tulis frame lewat `writeExecutor` single-thread (`sendLocked`), tidak interleave.
5. **`stopHost()` nggak nutup `clientSocket`** — `[DIPATCH]` `stopHostInternal()` menutup `activeSocket` + emit `disconnected`.
6. **Satu executor buat accept-loop + connect + send** — `[DIPATCH]` dipisah: `hostExecutor`, `clientExecutor`, `writeExecutor`, `timeoutExecutor`.
7. **`connect()` tanpa timeout & tanpa guard** — `[DIPATCH]` guard `connectPending` + watchdog `CONNECT_TIMEOUT_MS = 15s`.

## P1 — bug beneran tapi nggak fatal

8. **Listener terdaftar dobel saat config change** — `[SUDAH BENAR di baseline — bukan bug]` re-attach hanya memanggil `attachActivityBinding()` sekali; `onAttachedToActivity` sudah `detachActivityBinding()` dulu, jadi listener tidak numpuk.
   - **8b. `[TERBUKA]`** — dialog discoverable yang masih terbuka saat config change bisa membuat `makeDiscoverable()` berikutnya dijawab `DISCOVERABLE_PENDING` sesaat. Sisa ini sedang dikerjakan.
9. **`pendingPermission` bisa nyangkut** — `[DIPATCH]` `onDetachedFromActivity` membalas error `PERMISSION_FAILED` (bukan menggantung).
10. **`stopHostInternal()` bisa lempar IOException** — `[SUDAH BENAR di baseline — bukan bug]` `server?.close()` sudah dibungkus try/catch.
11. **Device tanpa nama dibuang** — `[DIPATCH]` `DiscoveryReceiver` tidak lagi membuang nama kosong; Dart menampilkan `"?"`.
12. **`bonded` di client hardcoded `false`** — `[DIPATCH]` client memakai `event.bonded` (fallback `false` hanya untuk entri tanpa data event).
13. **TV cuma kelihatan 2 menit** — `[DIPATCH]` `_makeDiscoverable()` di-`await` + `Timer.periodic(discoverableRefresh)` selama listening.
14. **`requestPermission()` di host nggak dicek hasilnya** — `[DIPATCH]` hasil dicek; ditolak → `_fail(...)` dengan pesan izin.

## P2 — rapi-rapi / UX

15. `[DIPATCH]` `stop()`/`_fail()` me-reset `peerName`, `error`, `_started`, `_connected`.
16. `[DIPATCH]` error saat terhubung tidak lagi cuma `debugPrint`; status di-set error + jadwal reconnect (UI tidak lagi "connected" palsu).
17. `[DIPATCH]` auto-reconnect ditambahkan (`_scheduleReconnect`, `reconnectDelay`, `reconnectAttempts`).
18. `[DIPATCH]` `clientSocket` → `activeSocket` (host & client).

## Area lain yang wajib dicek (belum dibaca)

Semua item di bawah sudah diverifikasi: **`[SUDAH BENAR di baseline — bukan bug]`** — tidak perlu perubahan.

- `packages/bluetooth_sync/android/build.gradle` — `namespace`, `minSdk = 23`, Java/Kotlin target 17, `compileSdk = 36`: sudah benar.
- `AndroidManifest.xml` (plugin + app) — `BLUETOOTH_SCAN` + `neverForLocation`, `BLUETOOTH_CONNECT`, `BLUETOOTH_ADVERTISE`, legacy `BLUETOOTH`/`BLUETOOTH_ADMIN` `maxSdkVersion="30"`, `ACCESS_FINE_LOCATION` `maxSdkVersion="30"`: sudah benar.
- `packages/bluetooth_sync/lib/bluetooth_sync.dart` — channel `com.masjidyou/bluetooth_sync` (+`/events`), mapping `bytes` menerima `Uint8List`/`List<int>`, enum lengkap (`listening`, `discovered`, `discoveryFinished`): sudah benar.
- `apps/mobile_remote/lib/main.dart` — listener BT dipasang sekali lewat subscription, `disconnect()` dipanggil saat app background (lifecycle observer): sudah benar.
- `apps/tv_display` chip header — teks/ikon status BT sinkron `BluetoothHostState` termasuk state error: sudah benar.
