# PLAN: Perbaikan WiFi Direct Discovery + Prasyarat Check

## Status: DRAFT

---

## Masalah

Mode WiFi Direct tidak bisa menemukan device saat dijalankan di device asli.

### Akar Masalah

1. **TV Display (`p2p_host_service.dart`):** Tidak ada validasi prasyarat sebelum
   `createGroup()`. Kalau Location/Bluetooth/WiFi mati, `startLocalOnlyHotspot`
   gagal diam-diam (error di-print tapi tidak ada feedback ke user).

2. **Mobile Remote (`p2p_client_service.dart:22-42`):** `startScan()` **tidak mengecek
   Location enabled**. Di Android 6-11, BLE scan tanpa Location ON = 0 results
   tanpa error. Ini penyebab utama "Mencari TV..." stuck.

3. **Mobile Remote (`main.dart:808-820`):** Scan auto-stop 15 detik tapi callback
   `onDone` tidak di-pass ke `startScan()` → UI tidak update status setelah
   scan selesai.

---

## File yang Diubah

| # | File | Perubahan |
|---|------|-----------|
| 1 | `apps/tv_display/lib/server/p2p_host_service.dart` | Tambah prerequisite check + state + logging |
| 2 | `apps/tv_display/lib/main.dart` | Prerequisite check di initState, dialog fallback, P2pMode state |
| 3 | `apps/mobile_remote/lib/services/p2p_client_service.dart` | Tambah Location check di `startScan()` |
| 4 | `apps/mobile_remote/lib/main.dart` | Handle `onDone` callback di `_startScan()` |

---

## Detail per File

### 1. `apps/tv_display/lib/server/p2p_host_service.dart`

#### Tambah model `P2pPrerequisites`

```dart
class P2pPrerequisites {
  final bool wifiEnabled;
  final bool bluetoothEnabled;
  final bool locationEnabled;
  final bool p2pPermissionsGranted;
  final bool bluetoothPermissionsGranted;

  const P2pPrerequisites({
    required this.wifiEnabled,
    required this.bluetoothEnabled,
    required this.locationEnabled,
    required this.p2pPermissionsGranted,
    required this.bluetoothPermissionsGranted,
  });

  bool get allPermissionsGranted =>
      p2pPermissionsGranted && bluetoothPermissionsGranted;

  /// Location hanya wajib di Android < 12.
  bool isReady({required bool locationRequired}) =>
      wifiEnabled &&
      bluetoothEnabled &&
      allPermissionsGranted &&
      (!locationRequired || locationEnabled);
}
```

#### Tambah method `checkPrerequisites()`

```dart
Future<P2pPrerequisites> checkPrerequisites() async {
  if (_host == null) {
    _host = FlutterP2pHost();
    await _host!.initialize();
  }
  return P2pPrerequisites(
    wifiEnabled: await _host!.checkWifiEnabled(),
    bluetoothEnabled: await _host!.checkBluetoothEnabled(),
    locationEnabled: await _host!.checkLocationEnabled(),
    p2pPermissionsGranted: await _host!.checkP2pPermissions(),
    bluetoothPermissionsGranted: await _host!.checkBluetoothPermissions(),
  );
}
```

#### Tambah logging di `start()`

Setelah `await _host!.createGroup(advertise: true)`, tambah:

```dart
debugPrint('P2P Host: Group created successfully');
```

Di catch block, pastikan error juga di-forward ke caller supaya bisa ditangani
oleh UI (bukan hanya `print` yang hilang di production).

#### Tambah state `isActive` getter

```dart
bool get isRunning => _started;
```

---

### 2. `apps/tv_display/lib/main.dart`

#### Tambah enum dan state

```dart
enum P2pMode { pending, directFull, directIpOnly }

// Di state class:
P2pMode _p2pMode = P2pMode.pending;
```

#### Ubah `_initP2pHost()`

Sebelumnya:
```dart
void _initP2pHost() {
  _p2pHost.stateStream.listen((state) { ... });
  _p2pHost.start();
}
```

Sesudahnya:
```dart
Future<void> _initP2pHost() async {
  _p2pHost.stateStream.listen((state) {
    if (mounted) setState(() { _p2pState = state; });
  }, onError: (error) {
    debugPrint('P2P Host error: $error');
    if (mounted) setState(() { _p2pState = null; });
  });

  try {
    final reqs = await _p2pHost.checkPrerequisites();
    if (!mounted) return;

    // Location hanya wajib untuk Android < 12
    final locationRequired = !kIsWeb && Platform.isAndroid &&
        (await _androidSdkVersion()) < 31;

    if (reqs.isReady(locationRequired: locationRequired)) {
      await _p2pHost.start();
      if (mounted) setState(() { _p2pMode = P2pMode.directFull; });
    } else {
      // Tampilkan dialog
      _showP2pPrereqDialog(reqs);
    }
  } catch (e) {
    debugPrint('P2P host init failed: $e');
    if (mounted) setState(() { _p2pMode = P2pMode.directIpOnly; });
  }
}
```

> Catatan: Untuk deteksi Android SDK version di Dart, bisa pakai
> `Platform.version` atau `Theme.of(context).platform` — atau cukup
> hardcode check berdasarkan `NEARBY_WIFI_DEVICES` permission availability.
> Alternatif sederhana: selalu minta Location (aman untuk semua versi).

#### Tambah method `_showP2pPrereqDialog()`

```dart
void _showP2pPrereqDialog(P2pPrerequisites reqs) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.wifi_tethering,
          size: 48, color: Theme.of(context).colorScheme.primary),
      title: const Text('WiFi Direct Belum Siap'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Beberapa fitur belum aktif untuk menjalankan mode sync '
            'otomatis (WiFi Direct).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _prereqRow('Wi-Fi', reqs.wifiEnabled),
          _prereqRow('Bluetooth', reqs.bluetoothEnabled),
          _prereqRow('Lokasi (GPS)', reqs.locationEnabled),
          _prereqRow('Izin Perangkat', reqs.allPermissionsGranted),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            setState(() { _p2pMode = P2pMode.directIpOnly; });
          },
          child: const Text('Mode IP Saja'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await _enableAllP2pServices();
          },
          child: const Text('Aktifkan & Mulai'),
        ),
      ],
    ),
  );
}

Widget _prereqRow(String label, bool enabled) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          color: enabled ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );
}
```

#### Tambah method `_enableAllP2pServices()`

```dart
Future<void> _enableAllP2pServices() async {
  // Buka settings satu per satu, tunggu user selesai
  // (enableXxxServices() membuka settings panel, return true kalau panel terbuka)
  await _p2pHost.enableWifiIfNeeded();
  await _p2pHost.enableBluetoothIfNeeded();
  await _p2pHost.enableLocationIfNeeded();

  // Setelah user kembali, re-check
  if (!mounted) return;
  final reqs = await _p2pHost.checkPrerequisites();
  if (reqs.isReady(locationRequired: true)) {
    try {
      await _p2pHost.start();
      if (mounted) setState(() { _p2pMode = P2pMode.directFull; });
    } catch (e) {
      debugPrint('P2P start failed after enable: $e');
      if (mounted) setState(() { _p2pMode = P2pMode.directIpOnly; });
    }
  } else {
    // Masih ada yang mati, tampilkan dialog lagi
    if (mounted) _showP2pPrereqDialog(reqs);
  }
}
```

> Catatan: `enableXxxServices()` perlu ditambahkan di `p2p_host_service.dart`
> sebagai wrapper yang hanya menjalankan enable kalau belum ON (agar tidak
> selalu buka settings panel).

#### Update `HeaderClock` props

Sudah ada `p2pActive`, `p2pSsid`, `p2pIp`. Tidak perlu diubah. State
`_p2pMode` sudah cukup untuk menentukan apakah chip P2P ditampilkan atau tidak:

```dart
// Di build():
p2pActive: _p2pMode == P2pMode.directFull && (_p2pState?.isActive ?? false),
```

Kalau `_p2pMode == P2pMode.directIpOnly`, chip P2P tidak ditampilkan (hanya
Remote Sync IP yang muncul).

---

### 3. `apps/mobile_remote/lib/services/p2p_client_service.dart`

#### Tambah Location check di `startScan()`

```dart
Future<void> startScan(
    void Function(List<BleDiscoveredDevice>) onDevices) async {
  await _ensureClient();
  if (_client == null) return;
  try {
    if (!await _client!.checkP2pPermissions()) {
      await _client!.askP2pPermissions();
    }
    if (!await _client!.checkBluetoothPermissions()) {
      await _client!.askBluetoothPermissions();
    }
    // TAMBAHAN: Location services wajib ON untuk BLE scan
    if (!await _client!.checkLocationEnabled()) {
      await _client!.enableLocationServices();
    }
    if (!await _client!.checkWifiEnabled()) {
      await _client!.enableWifiServices();
    }
    if (!await _client!.checkBluetoothEnabled()) {
      await _client!.enableBluetoothServices();
    }
    await _client!.startScan(onDevices);
  } catch (e) {
    print('P2P scan failed: $e');
  }
}
```

---

### 4. `apps/mobile_remote/lib/main.dart`

#### Handle scan timeout di `_startScan()`

```dart
void _startScan() {
  setState(() {
    _isScanning = true;
    _p2pDevices.clear();
    _p2pStatus = 'WiFi Direct: Mencari TV...';
  });
  _p2pClient.startScan(
    (devices) {
      if (mounted) {
        setState(() { _p2pDevices = devices; });
      }
    },
    onDone: () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          if (_p2pDevices.isEmpty) {
            _p2pStatus = 'WiFi Direct: Tidak ada TV ditemukan.';
          }
        });
      }
    },
  );
}
```

---

## Flow UX

### TV Display

```
App Start
  └─ initState()
       ├─ Init clock, local server, config...
       └─ _initP2pHost()
            ├─ 1. checkPrerequisites()
            │     ├─ Semua OK (WiFi ✓ BT ✓ Loc ✓ Perm ✓)
            │     │   → _p2pHost.start()
            │     │   → _p2pMode = directFull
            │     │   → Chip "Mode Direct: <ssid> (<ip>)" muncul
            │     │
            │     └─ Ada yg missing
            │         → setState() → tampilkan dialog
            │
            └─ 2. Dialog "WiFi Direct Belum Siap"
                   ├─ [Aktifkan & Mulai]
                   │    → open WiFi settings
                   │    → open BT settings
                   │    → open Location settings
                   │    → re-check → masih ada missing? tampilkan lagi
                   │    → semua OK?
                   │       → _p2pHost.start()
                   │       → _p2pMode = directFull
                   │
                   └─ [Mode IP Saja]
                        → _p2pMode = directIpOnly
                        → Local server tetap jalan (port 8080)
                        → Chip P2P tidak tampil
                        → User input IP di HP, langsung connect
```

### Mobile Remote (scan)

```
User tap "Cari TV"
  └─ _startScan()
       ├─ Check Location → mati? → buka settings Location
       ├─ Check WiFi → mati? → buka panel WiFi
       ├─ Check BT → mati? → buka dialog enable BT
       ├─ startScan(onDevices, onDone: update UI)
       └─ UI update:
            ├─ Scan running → "Mencari TV..." + progress indicator
            ├─ Device found → list device muncul
            └─ Timeout 15s → "Tidak ada TV ditemukan."
```

---

## Risiko & Mitigasi

| Risiko | Mitigasi |
|--------|----------|
| TV Android tanpa BLE | Dialog tawarkan "Mode IP Saja" → WS server tetap jalan |
| User tolak permission | Dialog bisa ditampilkan ulang, atau pilih "Mode IP Saja" |
| `enableLocationServices()` buka settings tapi user tidak nyalakan | Re-check setelah return, kalau masih mati tampilkan dialog lagi |
| Android TV chipsets yang tidak support `LocalOnlyHotspot` | Error di catch → fallback ke `directIpOnly` |
| Scan timeout terlalu pendek (15s) | Sudah cukup untuk BLE scan; bisa ditambah ke 20s jika perlu |

---

## Checklist Implementasi

- [ ] Tambah `P2pPrerequisites` model di `p2p_host_service.dart`
- [ ] Tambah `checkPrerequisites()` method di `p2p_host_service.dart`
- [ ] Tambah helper methods (`enableWifiIfNeeded`, `enableBluetoothIfNeeded`, `enableLocationIfNeeded`) di `p2p_host_service.dart`
- [ ] Tambah logging di `p2p_host_service.dart`
- [ ] Ubah `_initP2pHost()` di `tv_display/main.dart` jadi async + prerequisite check
- [ ] Tambah `_showP2pPrereqDialog()` di `tv_display/main.dart`
- [ ] Tambah `_enableAllP2pServices()` di `tv_display/main.dart`
- [ ] Tambah `P2pMode` enum dan state di `tv_display/main.dart`
- [ ] Update HeaderClock props berdasarkan `_p2pMode`
- [ ] Tambah Location check di `p2p_client_service.dart:startScan()`
- [ ] Handle `onDone` callback di `mobile_remote/main.dart:_startScan()`
- [ ] Test di device asli (HP + TV/STB)
- [ ] Lint & typecheck pass
