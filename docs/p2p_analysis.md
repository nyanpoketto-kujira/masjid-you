# Analisis Stack Konektivitas P2P (LocalOnlyHotspot + BLE + WebSocket) — `masjid-you`

> **Jenis dokumen:** analisis teknis *evidence-based* (bukan ADR). Setiap klaim disertai `file:line` dan kutipan kode.
> **Commit yang dianalisis:** `6fa3eb09f3a4d6c551cf428927b6ff1b0ab4c0e7` (branch `main`).
> **Sifat:** READ-ONLY pada seluruh source (`apps/`, `packages/`, `tools/`). Tidak ada file source yang diubah.
> **Dokumen terkait:** [`DECISIONS.md`](DECISIONS.md) (ADR-003, ADR-013, ADR-014, ADR-015), [`MAP.md`](MAP.md).

---

## 1. Ringkasan Arsitektur

### 1.1 Dua jalur yang berbeda dan tidak boleh dicampur

Sistem punya **dua lapisan jaringan** yang sering disebut dengan satu nama ("WiFi Direct"), padahal berbeda fungsi:

| Lapisan | Peran | Implementasi di proyek | Port |
|---|---|---|---|
| **Discovery + credential exchange** | Menemukan TV dan menukar SSID/PSK hotspot | BLE (GATT advertise/scan) via `flutter_p2p_connection` | — (BLE) |
| **Link-layer transport** | Menghubungkan HP ke jaringan TV tanpa router | **LocalOnlyHotspot** (soft-AP) di TV + **WifiNetworkSpecifier** di HP | — (L2) |
| **Aplikasi (data sync)** | Kirim `SyncPacket` JSON (config, running text, banner, kas, aksi cepat) | `shelf_web_socket` di TV (`LocalServer`) ⇄ `web_socket_channel` di HP (`RemoteWsClient`) | **:8080** |

Jadi **koneksi WebSocket `:8080` adalah satu-satunya jalur data aplikasi**. Jaringan P2P hanya membuat "jalan" agar IP TV bisa dijangkau HP ketika tidak ada router.

### 1.2 Koreksi terminologi penting: ini bukan Wi-Fi Direct (`WifiP2pManager`)

Kode proyek dan dokumentasi (`MAP.md:4`, `MAP.md:62`, ADR-003) menyebut "Wi-Fi Direct", tetapi plugin `flutter_p2p_connection 3.0.3` **tidak memakai `WifiP2pManager` sama sekali**. Yang dipakai:

- **Host (TV)** — `WifiManager.startLocalOnlyHotspot(...)`:
  - `flutter_p2p_connection-3.0.3/android/src/main/kotlin/com/ugo/studio/plugins/flutter_p2p_connection/HostManager.kt:26`
    `private var hotspotReservation: WifiManager.LocalOnlyHotspotReservation? = null`
  - `HostManager.kt:65` → `wifiManager.startLocalOnlyHotspot(hotspotCallback!!, mainHandler)`
- **Client (HP)** — `WifiNetworkSpecifier` (API 29+) atau `WifiConfiguration` legacy (API < 29):
  - `ClientManager.kt:11` `import android.net.wifi.WifiNetworkSpecifier`
  - `ClientManager.kt:138-141` `private fun connectToHotspotApi29(...)` → `WifiNetworkSpecifier.Builder()`
  - `ClientManager.kt:59-61` bercabang: `if (SDK >= Q) connectToHotspotApi29 else connectToHotspotLegacy`

`grep` atas seluruh Kotlin plugin tidak menemukan `WifiP2pManager`/`WifiP2pConfig`/`WifiP2pDevice` (hanya `LocalOnlyHotspot*` dan `WifiNetworkSpecifier`).

**Implikasi teknis:**
1. Model keamanannya = soft-AP dengan PSK yang dipertukarkan via BLE. `HotspotHostState.preSharedKey`
   (`src/models/p2p_connection_models.dart:13`) adalah kunci hotspot.
2. `createGroup(advertise: true)` sebenarnya = *start LocalOnlyHotspot* + *BLE advertising kredensial*, bukan *create P2P group*.
3. Batas minimum API = **API 26** (`Constants.kt:24` `MIN_HOTSPOT_API_LEVEL = Build.VERSION_CODES.O`), bukan batas API Wi-Fi Direct.
4. `HotspotClientState.hostGatewayIpAddress` (`p2p_connection_models.dart:83-84`) = gateway IP dari jaringan
   LocalOnlyHotspot — inilah IP yang di-*handoff* ke kolom IP Remote.

### 1.3 Peta komponen

**TV (`apps/tv_display`) — HOST**

| Berkas | Peran |
|---|---|
| `lib/main.dart:70` | `enum P2pMode { pending, directFull, directIpOnly }` |
| `lib/main.dart:190-231` | `_initP2pHost()` — cek prasyarat → `start()` atau dialog fallback |
| `lib/main.dart:292-354` | `_enableAllP2pServices()` — minta izin → nyalakan layanan → retry |
| `lib/server/p2p_host_service.dart:32-155` | `P2pHostService` — bungkus `FlutterP2pHost` |
| `lib/server/p2p_host_service.dart:6-30` | `P2pPrerequisites` (model + `isReady`) |
| `lib/server/local_ws_server.dart:9-59` | `LocalServer` — WebSocket server `anyIPv4:8080` |

**Remote (`apps/mobile_remote`) — CLIENT**

| Berkas | Peran |
|---|---|
| `lib/main.dart:832-896` | `_startScan` / `_runScan` / `_stopScan` / `_connectP2p` |
| `lib/main.dart:170-180` | Listener `P2pClientService.stateStream` → IP handoff → `_connectToTv()` |
| `lib/services/p2p_client_service.dart:34-168` | `P2pClientService` — bungkus `FlutterP2pClient` |
| `lib/services/p2p_client_service.dart:8-32` | `P2pPrerequisites` (salinan kembar dari TV) |
| `lib/services/ws_client.dart:6-129` | `RemoteWsClient` — WebSocket client `:8080` |
| `lib/screens/connectivity/connectivity_tab.dart:5-183` | UI: IP manual + tombol "Cari TV" + daftar perangkat |

**Peran BLE vs transport plugin (port 3456/4567)**

- `defaultP2pTransportPort = 3456` dan `defaultP2pTransportClientFileServerPort = 4567`
  (`flutter_p2p_connection-3.0.3/lib/src/common/p2p_constants.dart:2,5`).
- Port ini dipakai oleh **lapisan transport milik plugin** (`P2pTransportHost`/`P2pTransportClient`, dibuat di
  `p2p_host.dart:171-172` dan `p2p_client.dart:348-352`), yang memang ikut hidup setelah
  `createGroup()`/`connectWithCredentials()`.
- **Proyek ini tidak memakainya sama sekali.** Tidak ada `streamReceivedTexts()`, `streamSentFilesInfo()`,
  `sendText()`, atau `shareFile()` di kedua app. Semua data aplikasi lewat `:8080`. Konsekuensinya plugin membuka
  socket tambahan di **:3456** (dan file server client **:4567**) yang tidak dibutuhkan — *attack surface* &
  resource terbuang (lihat Temuan 7).

**Batas tegas ketiga port:**

```
  BLE GATT            LocalOnlyHotspot (L2)              WebSocket JSON
  ────────            ─────────────────────              ──────────────
  SSID + PSK   ──►    HP join ke AP TV        ──►        ws://<gateway>:8080
  (advertise)         hostGatewayIpAddress               SyncPacket / SyncAction
                                                         (inilah jalur data ASLI)

                      plugin transport :3456 / :4567  ← DIBUKA tapi TIDAK DIPAKAI
```
---

## 2. Alur End-to-End Langkah demi Langkah

### 2.1 Fase A — TV menjadi host (boot)

1. **Entrypoint** `apps/tv_display/lib/main.dart:23-37`: `main()` → `SystemChrome.immersiveSticky`, `WakelockPlus.enable()`, `runApp(MasjidYouTVApp())`.
2. **`initState`** `main.dart:152-179`: `_initLocalServer()` (`:177`) dan `_initP2pHost()` (`:178`).
3. **WebSocket server dulu** `main.dart:360-447`: `_localServer = LocalServer(onPacketReceived: ...)` (`:361`), lalu `:441-443`:
   ```dart
   try {
     await _localServer?.start(port: 8080);
     _fetchLocalIp();
   } catch (e) { debugPrint('Failed to start local server: $e'); }
   ```
   - `LocalServer.start` (`local_ws_server.dart:16-43`) memakai `init_io.serve(handler, InternetAddress.anyIPv4, port)` (`:36`) → listen di `0.0.0.0:8080`.
   - `_fetchLocalIp()` (`:449-470`) mengambil **IPv4 non-loopback pertama** dari `NetworkInterface.list(...)` (`:451-462`) → "Remote Sync IP" di header TV (`:533`).
4. **Cek prasyarat P2P** `main.dart:207-222`:
   ```dart
   final reqs = await _p2pHost.checkPrerequisites();                                      // :208
   final locationRequired = !kIsWeb && Platform.isAndroid && _androidSdkVersion() < 31;   // :211
   if (reqs.isReady(locationRequired: locationRequired)) {                                // :213
     await _p2pHost.start();                                                              // :214
     _p2pMode = P2pMode.directFull;                                                       // :217
   } else { _showP2pPrereqDialog(reqs); }                                                 // :221
   ```
5. **`P2pHostService.start()`** `p2p_host_service.dart:112-142`:
   - guard `if (_started || !Platform.isAndroid) return;` (`:113`);
   - `FlutterP2pHost()` + `initialize()` (`:117-118`);
   - **subscribe `streamHotspotState()`** → teruskan ke `_stateController` (`:121-126`); berpasangan dengan `_p2pHost.stateStream.listen(...)` di `main.dart:191-205` yang men-set `_p2pState`;
   - minta izin (`:128-133`) — **tidak di-gate SDK di sini** (lihat Temuan 2);
   - `await _host!.createGroup(advertise: true);` (`:135`).
6. **`createGroup(advertise: true)`** plugin `src/host/p2p_host.dart:95-172`:
   - `createHotspot()` native (`:107`) → `HostManager.createHotspot` (`HostManager.kt:36-72`) → `startLocalOnlyHotspot`;
   - tunggu state aktif lengkap (`isActive && ssid != null && preSharedKey != null && hostIpAddress != null`) dengan default **timeout 60 detik** (`:101-129`);
   - `startBleAdvertising(state.ssid!, state.preSharedKey!)` (`:137-138`) — **di sinilah kredensial hotspot diiklankan via BLE**; gagal → `removeGroup()` + `throw` (`:146-153`);
   - `P2pTransportHost(defaultPort: 3456).start()` (`:169-176`) → port plugin yang tidak dipakai app (§1.3).
7. **Efek di UI TV**: `HeaderClock` menerima (`main.dart:530-537`):
   ```dart
   serverIp: _localIp,
   p2pActive: _p2pMode == P2pMode.directFull && (_p2pState?.isActive ?? false),
   p2pSsid: _p2pMode == P2pMode.directFull ? _p2pState?.ssid : null,
   p2pIp: _p2pMode == P2pMode.directFull ? _p2pState?.hostIpAddress : null,
   ```
   → chip `Mode Direct: <ssid> (<ip>)` (`header_clock.dart:92-115`) + chip `Remote Sync IP: <ip>:8080` (`header_clock.dart:75-91`).

### 2.2 Fase B — Remote scan (discovery)

8. Tekan **"Cari TV"** (`connectivity_tab.dart:114-125`) → `onStartScan` = `_startScan` (`main.dart:1312`).
9. **`_startScan()`** `main.dart:832-850`:
   ```dart
   final locationRequired = Platform.isAndroid && _androidSdkVersion() < 31;  // :833
   final reqs = await _p2pClient.checkPrerequisites();                        // :835
   if (reqs.isReady(locationRequired: locationRequired)) { _runScan(); }       // :837-838
   else { _showP2pPrereqDialog(reqs); }                                        // :840
   ```
10. **`P2pClientService.checkPrerequisites()`** `p2p_client_service.dart:62-91` → `_ensureClient()` (`:51-59`) lalu baca Wi-Fi/BT/Lokasi/izin.
11. **`_runScan()`** `main.dart:852-880`:
    ```dart
    setState(() { _isScanning = true; _p2pDevices.clear();
                  _p2pStatus = 'WiFi Direct: Mencari TV...'; });                 // :854-858
    _p2pClient.startScan(
      (devices) { if (mounted) setState(() { _p2pDevices = devices; }); },   // :860-866
      onDone: () { if (mounted) setState(() { _isScanning = false; ... }); }, // :867-878
    );
    ```
12. **`P2pClientService.startScan`** `p2p_client_service.dart:126-142`: `askPermissionsIfNeeded()` → `enableLocationIfNeeded()` → `enableWifiIfNeeded()` → `enableBluetoothIfNeeded()` → `_client!.startScan(onDevices, onDone: onDone)`.
13. **`FlutterP2pClient.startScan`** plugin `src/client/p2p_client.dart:110-172`: subscribe `streamBleScanResult()` (`:121-147`) + `Timer(timeout)` default **15 detik** (`:152-156`) → `startBleScan()` native (`:159`). Timeout → `onDone?.call()` lalu `stopScan()` (`:154-155`).

### 2.3 Fase C — Remote connect (BLE credential exchange + join hotspot)

14. Tap perangkat (`connectivity_tab.dart:162-172`) → `onConnectP2p(device)`.
15. **`_connectP2p`** `main.dart:890-896`:
    ```dart
    _stopScan();
    setState(() { _p2pStatus = 'WiFi Direct: Menyambung...'; });
    _p2pClient.connectTo(dev);   // ← Future<bool> TIDAK di-await, hasil diabaikan
    ```
16. **`P2pClientService.connectTo`** `p2p_client_service.dart:150-160` → `await _client!.connectWithDevice(device)`; sukses → `true`; gagal → `catch { print(...); return false; }`.
17. **`connectWithDevice`** plugin `src/client/p2p_client.dart:218-283`:
    - subscribe `streamBleReceivedData()` (`:229-267`), ambil **SSID** lalu **PSK** dari GATT characteristic, tunggu dengan **timeout 20 detik** (`:220`, `:262-265`);
    - `await connectWithCredentials(ssid, psk)` (`:271`);
    - `finally` → cancel sub + `disconnectBleDevice` (`:278-285`) — BLE dilepas setelah kredensial didapat.
18. **`connectWithCredentials`** plugin `:305-361`:
    - `connectToHotspot(ssid, psk)` native → `ClientManager.connectToHotspot` (`ClientManager.kt:47-61`) → `WifiNetworkSpecifier` (API 29+) / legacy;
    - tunggu `streamHotspotState()` dengan `hostSsid == ssid && hostGatewayIpAddress != null && hostIpAddress != null`, **timeout 60 detik** (`:307-308`, `:332-337`);
    - buat `P2pTransportClient(hostIp: state.hostGatewayIpAddress!, defaultPort: 3456, defaultFilePort: 4567)` + `connect()` (`:348-356`).
19. **IP handoff → WebSocket** di Remote `main.dart:170-180`:
    ```dart
    _p2pClient.stateStream.listen((state) {
      if (state == null || !state.isActive || !mounted) return;
      final hostIp = state.hostGatewayIpAddress;
      if (hostIp != null && hostIp.isNotEmpty && hostIp != _ipController.text) {
        setState(() { _ipController.text = hostIp;
                      _p2pStatus = 'WiFi Direct: Terhubung ke TV!'; });
        _connectToTv();          // :178
      }
    });
    ```
20. **`_connectToTv()`** `main.dart:295-329` → `_client.connect(_ipController.text.trim())` (`:300`) → `RemoteWsClient.connect` (`ws_client.dart:23-49`): validasi IPv4 + port (`:24-27`), `WebSocketChannel.connect('ws://$ipAddress:$port')` (`:29-30`), `await channel.ready.timeout(5s)` (`:34`) — komentar `:31-33` menjelaskan `ready` wajib karena `connect` bersifat lazy. `_isConnected = true` (`:36`) → `_syncAllToTv()` (`main.dart:315`).

### 2.4 Fase D — Sinkronisasi `SyncPacket`

21. **Remote → TV** (`main.dart:370-378` `_syncAllToTv`): `sendConfigUpdate` → `sendRunningTextsUpdate` → `sendBannersUpdate` → `sendKasUpdate` (`ws_client.dart:63-95`).
22. **TV menerima** (`local_ws_server.dart:18-33`): decode (`utf8.decode`) → `SyncPacket.fromJson(text)` → `onPacketReceived(packet)` (`:26-27`); error di-swallow (`:28`).
23. **TV memproses** (`main.dart:362-437`): `switch (packet.action)` → `updateConfig` (`:365`), `updateRunningText` (`:370`), `updateBanners` (`:384`), `updateKas` (`:398`), `skipAdhan` (`:412`), `startIqomah` (`:415`), `startShalat` (`:418`), `finishShalat` (`:421`), `forcePhase` (`:424`), `getInitialState` → `_broadcastState()` (`:431-432`).
24. **TV → Remote (push balik)**: `_broadcastState()` (`main.dart:473-483`) mengirim `SyncAction.stateUpdate` (`phase/prayer/remainingSeconds/totalSeconds`); dipicu `_onStateMachineChanged` (`:485-488`) yang terpasang sebagai listener state machine (`:163`).
25. **Remote menerima state**: `RemoteWsClient.onPacket` (`ws_client.dart:12`; diset di `main.dart:167`) → `_handleTvPacket` men-update `_tvPhase` (`main.dart:286-287`) → dipakai `SimulationTab` (`main.dart:1318`).
26. **TV membersihkan client putus**: `onDone`/`onError` → `_clients.remove(webSocket)` (`local_ws_server.dart:30-31`).

### 2.5 Diagram ringkas

```
TV                                                   REMOTE
────────────────────────────────────────────────────────────────────────
main(): wakelock, UI
 ├─ LocalServer.start(anyIPv4:8080)  ── :8080 ──┐
 │   _fetchLocalIp() → "Remote Sync IP"         │
 └─ P2pHostService.start()                      │
     checkPrerequisites() ─┐                    │
     createGroup(advertise:true)                │
       ├─ LocalOnlyHotspot (soft-AP)            │
       ├─ BLE advertising(SSID, PSK) ──┐        │
       └─ P2pTransport host :3456(*)   │        │
                                             ▼  │
                            _startScan() → checkPrerequisites()
                            _runScan() → BLE scan (15 s)
                            tap device → connectWithDevice
                              ├─ BLE read SSID, PSK (20 s)
                              └─ join AP via WifiNetworkSpecifier
                                 → HotspotClientState.hostGatewayIpAddress
                                        │
                     ◄──── _ipController.text = gateway IP
                            _connectToTv() → ws://<gateway>:8080 ────────┘
                            _syncAllToTv() → SyncPacket JSON
TV: onPacketReceived → switch(action) → setState
TV: _broadcastState() → SyncAction.stateUpdate ──► Remote: _tvPhase

(*) :3456/:4567 dibuka plugin tetapi TIDAK dipakai aplikasi.
    :8080 adalah satu-satunya transport data aplikasi.
```

---

## 3. Prasyarat & Izin per Android SDK Level

### 3.1 Tabel prasyarat

| Android | API | Wi-Fi | Bluetooth | Lokasi | Izin runtime yang benar-benar dibutuhkan | Yang dicek proyek |
|---|---|---|---|---|---|---|
| 6.0–10 | 23–29 | ON | ON | **WAJIB aktif** (BLE scan tanpa Location → 0 hasil, tanpa error) | `ACCESS_FINE_LOCATION` (+ `BLUETOOTH`, `BLUETOOTH_ADMIN` dari manifest, auto-granted) | `locationEnabled` + `bluetoothPermissionsGranted` |
| 11 | 30 | ON | ON | WAJIB aktif | `ACCESS_FINE_LOCATION` | idem |
| 12 / 12L | 31–32 | ON | ON | dianjurkan | `BLUETOOTH_SCAN`/`CONNECT`/`ADVERTISE` (+ `ACCESS_FINE_LOCATION`) | `bluetoothPermissionsGranted` (lihat §3.3) |
| 13 | 33 | ON | ON | tidak wajib | **`NEARBY_WIFI_DEVICES`** (targetSdk ≥ 33) + `BLUETOOTH_*` | seharusnya `checkP2pPermissions()` |
| 14–16 | 34–36 | ON | ON | tidak wajib | idem API 33 | idem |

`compileSdk`/`targetSdk` = `flutter.compileSdkVersion`/`flutter.targetSdkVersion`
(`apps/tv_display/android/app/build.gradle.kts:9,23`; `apps/mobile_remote/android/app/build.gradle.kts:9,23`), dan pada Flutter 3.44.9 keduanya = **36**
(`flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt:23,34`). Artinya **`targetSdk >= 31`** → cabang `NEARBY_WIFI_DEVICES` di plugin **aktif**.

### 3.2 Verifikasi special-case `SDK >= 33`

**TV** — `apps/tv_display/lib/server/p2p_host_service.dart:60-69`:
```dart
// `checkP2pPermissions` plugin menuntut NEARBY_WIFI_DEVICES sejak Android 12,
// padahal izin itu baru berlaku Android 13+ dan di beberapa ROM Android 12
// bahkan tidak terdaftar. Untuk Android < 13, P2P cukup FINE_LOCATION yang
// sudah tercakup oleh checkBluetoothPermissions.
final bluetoothPermissionsGranted = await _host!.checkBluetoothPermissions();
final sdkVersion = _androidSdkVersion();
final p2pPermissionsGranted = sdkVersion >= 33
    ? await _host!.checkP2pPermissions()
    : bluetoothPermissionsGranted;   // ← fallback SDK < 33
```
**Remote** — `apps/mobile_remote/lib/services/p2p_client_service.dart:74-83`: **kode identik** (hanya `_client` menggantikan `_host`).

Gate yang sama juga dipakai saat meminta izin: `p2p_host_service.dart:104` dan `p2p_client_service.dart:97`
`if (_androidSdkVersion() >= 33 && !await ...checkP2pPermissions()) await ...askP2pPermissions();`

**Verifikasi terhadap native plugin** — `PermissionsManager.kt:26-46`:
```kotlin
var nearbyWifiGranted = true // Assume true for older APIs
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {                       // API 31+
    val targetsApi31OrHigher = applicationContext.applicationInfo.targetSdkVersion >= Build.VERSION_CODES.S
    if (targetsApi31OrHigher) {
        nearbyWifiGranted = ContextCompat.checkSelfPermission(
            applicationContext, Manifest.permission.NEARBY_WIFI_DEVICES
        ) == PackageManager.PERMISSION_GRANTED
    }
}
return fineLocationGranted && changeWifiStateGranted && nearbyWifiGranted
```
→ dengan `targetSdk 36`, `hasP2pPermissions()` **selalu** menuntut `NEARBY_WIFI_DEVICES` untuk API ≥ 31 — **termasuk Android 12 (31/32)** yang izinnya tidak dapat diberikan platform. Maka justifikasi proyek untuk *skip* di SDK < 33 **benar secara niat**, tetapi default kompensasinya (`= bluetoothPermissionsGranted`) tidak mencakup `NEARBY_WIFI_DEVICES`.

Konsekuensi langsung: `checkBluetoothPermissions()` (`p2p_connection_base.dart:99-113`) hanya memeriksa
`locationWhenInUse + bluetoothScan + bluetoothConnect + bluetoothAdvertise` — **tidak ada `NEARBY_WIFI_DEVICES`**. Jadi `p2pPermissionsGranted` pada cabang `else` **tidak ekuivalen** dengan `hasP2pPermissions()` native.

### 3.3 ⚠️ TEMUAN KRITIS: gate `SDK >= 33` tidak pernah aktif — `_androidSdkVersion()` selalu `0`

Terdapat **empat salinan** fungsi berikut:
`apps/tv_display/lib/server/p2p_host_service.dart:45-53`, `apps/mobile_remote/lib/services/p2p_client_service.dart:41-49`,
`apps/tv_display/lib/main.dart:181-188`, `apps/mobile_remote/lib/main.dart:820-828`:
```dart
int _androidSdkVersion() {
  if (!Platform.isAndroid) return 0;
  final match = RegExp(r'SDK\s+(\d+)').firstMatch(Platform.operatingSystemVersion);
  if (match != null) return int.tryParse(match.group(1) ?? '') ?? 0;
  return 0;
}
```

**Bukti bahwa regex ini tidak pernah match di Android.** Implementasi `Platform.operatingSystemVersion` untuk Android di Dart SDK
(`runtime/bin/platform_linux.cc`, cabang `#if defined(DART_HOST_OS_ANDROID)`):
```c
const char* Platform::OperatingSystemVersion() {
#if defined(DART_HOST_OS_ANDROID)
  char os_version[PROP_VALUE_MAX + 1];
  int os_version_length = __system_property_get("ro.build.display.id", os_version);
  if (os_version_length == 0) return nullptr;
  os_version[Utils::Minimum(os_version_length, PROP_VALUE_MAX)] = '\0';
  return DartUtils::ScopedCopyCString(os_version);
#endif
}
```
Sumber: <https://raw.githubusercontent.com/dart-lang/sdk/main/runtime/bin/platform_linux.cc> (diakses saat penyusunan dokumen ini).
Nilainya = system property **`ro.build.display.id`** (mis. `"TQ3A.230805.001"` atau nomor build TV box), **tidak memuat substring `SDK <angka>`**
→ `firstMatch` = `null` → **return `0`** di semua perangkat Android.

**Rantai dampak:**

| # | Langkah | Bukti |
|---|---|---|
| 1 | `_androidSdkVersion()` = `0` | regex vs `ro.build.display.id` (di atas) |
| 2 | `checkPrerequisites()` → `p2pPermissionsGranted = bluetoothPermissionsGranted` (selalu cabang `else`) | `p2p_host_service.dart:67-69`, `p2p_client_service.dart:81-83` |
| 3 | `askPermissionsIfNeeded()` **tidak pernah** memanggil `askP2pPermissions()` | `p2p_host_service.dart:104`, `p2p_client_service.dart:97` |
| 4 | `NEARBY_WIFI_DEVICES` tidak pernah diminta → native tolak | `FlutterP2pConnectionPlugin.kt:218-222` (`createHotspot` → `PERMISSION_DENIED`), `:231-234` (`connectToHotspot` → `PERMISSION_DENIED`) |
| 5 | TV: `createGroup()` throw → fallback `directIpOnly` | `p2p_host_service.dart:137-141` → `main.dart:223-229` |
| 6 | Remote: `connectWithDevice()` throw → `connectTo` return `false` → **diabaikan UI** | `p2p_client_service.dart:156-159` → `main.dart:895` |
| 7 | `locationRequired = _androidSdkVersion() < 31` → **selalu `true`** | `main.dart:211` (TV), `main.dart:833,997` (Remote) |

**Asimetri host vs client (penting untuk debugging lapangan).** Karena langkah 3 hanya memengaruhi `askPermissionsIfNeeded()`,
sedangkan **`P2pHostService.start()` memanggil izin secara tidak tergate** (`p2p_host_service.dart:128-133`):
```dart
if (!await _host!.checkP2pPermissions()) { await _host!.askP2pPermissions(); }
if (!await _host!.checkBluetoothPermissions()) { await _host!.askBluetoothPermissions(); }
```
maka di Android 13 **TV berpotensi berhasil** (dialog `NEARBY_WIFI_DEVICES` muncul dari `start()`), sementara **Remote tidak pernah memintanya**
(`P2pClientService` tidak punya jalur tak-tergate: `startScan` → `askPermissionsIfNeeded` (tergate), dan `connectTo` tidak meminta izin sama sekali).
Gejala yang diharapkan di lapangan: *"TV sudah tampil Mode Direct, HP tetap gagal menyambung"*.

**Rekomendasi perbaikan:**
1. Ganti deteksi SDK dengan sumber otoritatif, bukan parsing string: `device_info_plus` (`AndroidDeviceInfo.version.sdkInt`),
   atau method channel kecil yang mengembalikan `Build.VERSION.SDK_INT`.
2. Satukan pintu permintaan izin (satu helper `ensureP2pPermissions()`), jangan biarkan `start()`/`connectTo()` berbeda perilaku dari `askPermissionsIfNeeded()`.
3. Perlakukan `hasP2pPermissions() == false` di Android 12 sebagai "P2P tidak tersedia" → langsung fallback `directIpOnly`/dialog, bukan "ready".
   (`__system_property_get`-nya tidak salah: pada Android 12 memang `NEARBY_WIFI_DEVICES` tidak dapat diberikan.)
4. Tambahkan log saat start: `debugPrint('P2P: sdk=$sdk raw=${Platform.operatingSystemVersion}')` agar bug ini terlihat di logcat.

### 3.4 Cross-check terhadap Manifest

Blok izin kedua manifest **identik baris demi baris**
(`apps/tv_display/android/app/src/main/AndroidManifest.xml:4-28` = `apps/mobile_remote/android/app/src/main/AndroidManifest.xml:4-28`):

| Baris | Izin |
|---|---|
| `:5-8` | `NEARBY_WIFI_DEVICES` (`neverForLocation`, `tools:targetApi="33"`) |
| `:9-12` | `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`, `CHANGE_NETWORK_STATE`, `ACCESS_NETWORK_STATE` |
| `:13-14` | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` |
| `:17-20` | `BLUETOOTH_SCAN` (`neverForLocation`, `tools:targetApi="31"`) |
| `:21-22` | `BLUETOOTH_ADVERTISE`, `BLUETOOTH_CONNECT` |
| `:23-28` | `BLUETOOTH`, `BLUETOOTH_ADMIN` (`maxSdkVersion="30"`) |

Manifest plugin **kosong** (`flutter_p2p_connection-3.0.3/android/src/main/AndroidManifest.xml` hanya berisi tag `<manifest package=...>`),
jadi **seluruh izin bergantung pada app** — dan keduanya sudah lengkap. ✅

Temuan sampingan pada manifest:

- **⚠️ `INTERNET` hanya ada di manifest `debug`/`profile`, TIDAK di `src/main`.**
  `apps/tv_display/android/app/src/debug/AndroidManifest.xml:6` dan `.../profile/AndroidManifest.xml:6`:
  `<uses-permission android:name="android.permission.INTERNET"/>` (idem `mobile_remote`).
  `grep -rn 'INTERNET' apps/*/android/` **tidak menemukan `<uses-permission ... INTERNET>` di `src/main`**.
  Bukti terkuat: merged manifest build **release** yang sudah ada di repo **tidak memuat `INTERNET`** —
  `apps/tv_display/build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml` (artefak 3 Sep 2026);
  `grep -n 'uses-permission'` hanya menemukan baris 12, 15-20, 23, 26-28, 31, 61 — **tanpa INTERNET**.
  → **Build release berisiko tidak dapat membuka socket apa pun**: `init_io.serve(..., 8080)` di TV dan
  `WebSocketChannel.connect(...)` di Remote akan gagal (`SocketException: ... Permission denied`).
  Ini **wajib diverifikasi pada APK release** (lihat §6) sebelum disimpulkan final.
- `BLUETOOTH_SCAN` diberi `neverForLocation`, tetapi `checkBluetoothPermissions()`
  (`p2p_connection_base.dart:99-113`) **tetap mensyaratkan `Permission.locationWhenInUse`** → pengguna yang menolak izin lokasi membuat
  baris "Izin Perangkat" merah **permanen**, walaupun manifest menyatakan BLE scan tidak dipakai untuk lokasi (over-restrictive).
- Tidak ada `ACCESS_BACKGROUND_LOCATION`/`POST_NOTIFICATIONS` — memang tidak dibutuhkan. OK.

---

## 4. Temuan Bug / Risiko

Format setiap temuan: **lokasi** → **bukti** → **dampak** → **rekomendasi**.
Urutan mengikuti permintaan (a–f), dilanjutkan temuan tambahan (g–n). Temuan §3.3 (deteksi SDK) adalah **prioritas #1**.

### 4.1 (a) Duplikasi `P2pPrerequisites` + logika SDK di TV & Remote — kode kembar yang bisa *drift*

**Lokasi:** `apps/tv_display/lib/server/p2p_host_service.dart:6-30` vs `apps/mobile_remote/lib/services/p2p_client_service.dart:8-32`;
`p2p_host_service.dart:45-53` vs `p2p_client_service.dart:41-49`;
`apps/tv_display/lib/main.dart:181-188` vs `apps/mobile_remote/lib/main.dart:820-828`.

**Bukti:** kelas & method identik:
```dart
// TV p2p_host_service.dart:21-29 (Remote p2p_client_service.dart:23-31 identik)
bool get allPermissionsGranted => p2pPermissionsGranted && bluetoothPermissionsGranted;
bool isReady({required bool locationRequired}) =>
    wifiEnabled && bluetoothEnabled && allPermissionsGranted &&
    (!locationRequired || locationEnabled);
```
Dokumentasi pun mengakui ini — `docs/DECISIONS.md:427`: *"`P2pPrerequisites` terduplikasi di dua app … tidak dipindah ke `shared_models`
agar paket shared tetap murni Dart tanpa dependensi plugin Flutter."*

**Drift yang SUDAH terjadi** (bukti bahwa risiko ini nyata, bukan teoretis):
1. `_androidSdkVersion()` ada **4 salinan**, dan gate-nya tidak konsisten dipakai:
   - `askPermissionsIfNeeded()` → **tergate** (`p2p_host_service.dart:104`, `p2p_client_service.dart:97`);
   - `P2pHostService.start()` → **tidak tergate** (`p2p_host_service.dart:128-133`);
   - `P2pClientService.startScan()` → memanggil `askPermissionsIfNeeded()` (tergate) sehingga **tidak pernah** meminta izin P2P.
2. `_showP2pPrereqDialog` ada **dua salinan** dengan aksi berbeda: TV men-set `P2pMode.directIpOnly` saat "Mode IP Saja"
   (`main.dart:262-265`), Remote hanya `Navigator.of(ctx).pop()` tanpa efek (`main.dart:925-928`).
3. Remote menambahkan cabang non-Android khusus (`p2p_client_service.dart:64-73`: "anggap siap"), TV tidak punya padanannya.
4. TV memakai `!kIsWeb && Platform.isAndroid && _androidSdkVersion() < 31` (`main.dart:211`), Remote memakai
   `Platform.isAndroid && _androidSdkVersion() < 31` (`main.dart:833`) — dua ekspresi berbeda untuk hal yang sama.

**Dampak:** setiap perbaikan izin/SDK harus diaplikasikan 2–4 kali; sudah terbukti menghasilkan perilaku asimetris TV vs Remote (§3.3).
Kegagalan bersifat *silent* (fallback diam-diam) sehingga drift tidak terdeteksi oleh `flutter analyze`/test.

**Rekomendasi:**
- Pindahkan **model murni** (`P2pPrerequisites` + `isReady`) ke `packages/shared_models` (nol dependensi plugin Flutter — klaim ADR-015 bahwa ini mustahil tidak sepenuhnya benar).
- Satu helper deteksi SDK + **satu** jalur permintaan izin untuk kedua app.
- Tambahkan test tabel kebenaran `isReady` di shared package (§6) sehingga kedua app dijamin identik.
- Satukan dialog prasyarat (atau minimal samakan aksi "Mode IP Saja").

### 4.2 (b) `connectWithDevice` tanpa timeout/retry dari sisi app; `startScan` cukup ber-timeout

**Klarifikasi (agar tidak salah arah):** timeout **ada di plugin**, bukan di app:
- `startScan(..., Duration timeout = const Duration(seconds: 15))` — `flutter_p2p_connection-3.0.3/lib/src/client/p2p_client.dart:110-116`,
  diimplementasikan `Timer(timeout, () { onDone?.call(); stopScan(); })` (`:152-156`).
- `connectWithDevice(device, {Duration timeout = const Duration(seconds: 20)})` — `p2p_client.dart:218-220`; dipakai menunggu kredensial BLE (`:262-265`).
- `connectWithCredentials(ssid, psk, {Duration timeout = const Duration(seconds: 60)})` — `p2p_client.dart:305-308`, menunggu state hotspot (`:332-337`).

**Masalah sesungguhnya ada di sisi app** — `apps/mobile_remote/lib/main.dart:890-896`:
```dart
void _connectP2p(BleDiscoveredDevice dev) {
  _stopScan();
  setState(() { _p2pStatus = 'WiFi Direct: Menyambung...'; });
  _p2pClient.connectTo(dev);   // :895 — Future<bool> tidak di-await, hasil dibuang
}
```
- `connectTo` mengembalikan status yang **diabaikan** (`p2p_client_service.dart:150-160`):
  `return true;` / `catch { print('P2P connect failed: $e'); return false; }`.
- Tidak ada **retry**, tidak ada batas waktu tambahan di app, tidak ada **feedback kegagalan**. `_p2pStatus` bertahan
  `'WiFi Direct: Menyambung...'` selama ~80 detik (20 s BLE + 60 s Wi-Fi) dan **selamanya** bila gagal.
- `_stopScan()` (`:882-888`) juga tidak di-await → `stopScan` plugin membatalkan subscription (`p2p_client.dart:174-193`) sementara
  `connectWithDevice` mulai subscribe `streamBleReceivedData()`; urutan tidak dijamin.

**Dampak:** bila TV tidak merespons (BLE advertising belum aktif / masih menunggu `createGroup` / izin ditolak), user tidak pernah diberi tahu.
Satu-satunya pemulihan adalah menekan "Cari TV" lagi. Status UI berbohong dan tidak ada jalur retry.

**Rekomendasi:**
```dart
Future<void> _connectP2p(BleDiscoveredDevice dev) async {
  await _stopScan();
  setState(() => _p2pStatus = 'WiFi Direct: Menyambung...');
  final ok = await _p2pClient.connectTo(dev)
      .timeout(const Duration(seconds: 45), onTimeout: () => false);
  if (!mounted) return;
  setState(() => _p2pStatus = ok ? 'WiFi Direct: Terhubung ke TV!'
                                 : 'WiFi Direct: Gagal menyambung. Coba lagi.');
}
```
plus tombol "Coba Lagi" dan kemampuan meneruskan `timeout` dari `connectTo` ke `connectWithDevice`.

