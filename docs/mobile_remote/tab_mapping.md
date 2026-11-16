# mobile_remote — Tab & File Mapping

> Bedah lengkap **`apps/mobile_remote/lib/`** — aplikasi kontroler Remote Masjid DKM di HP Android.
> Navigasi 4 menu bawah (**Beranda, Konten, Pengaturan, Tes**) via `IndexedStack` tanpa swipe antar destinasi (ADR-023); **Konten** berisi 4 sub-tab atas yang bisa di-swipe di dalamnya. Plus mekanisme GPS/geolocator, offset jadwal sholat, indikator "Unsaved Changes", dan tema Material 3 standar.

**Navigasi:** [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [theme_shapes.md](theme_shapes.md) · [tv_display/widget_mapping.md](../tv_display/widget_mapping.md)

---

## 1. Struktur File

```
apps/mobile_remote/lib/
├── main.dart                  # Entry, navigasi 4 destinasi IndexedStack (Beranda/Konten/Pengaturan/Tes) + sub-tab Konten, strip status koneksi + bottom sheet, state global, semua handler, koneksi, durasi + aksi cepat shalat, theme M3
├── services/
│   ├── ws_client.dart         # Client WebSocket + helper kirim per tipe data + listen paket masuk
│   ├── p2p_client_service.dart# Scan & konek WiFi Direct / BLE
│   └── bluetooth_client_service.dart # Client Bluetooth Classic (RFCOMM): discovery, connect, auto-reconnect
└── test/
    ├── widget_test.dart       # Smoke test
    └── bluetooth_client_service_test.dart # Unit test transisi state client BT
```

**Tema Material 3 standar** (`lib/theme/remote_theme.dart` → `buildRemoteTheme`): `cardTheme` = `RoundedRectangleBorder(16)`; `dialogTheme`/`bottomSheetTheme` = `RoundedRectangleBorder(28)`; tombol (`FilledButton`/`OutlinedButton`/`TextButton`), `ChipThemeData.shape`, dan `navigationBarTheme.indicatorShape` = `StadiumBorder()`. Skema warna sejak Fase 0 (ADR-022) berasal dari dynamic color wallpaper (Android 12+) atau seed "Hijau Masjid", dipilih `resolveRemoteColorScheme`; preferensi mode/sumber warna di `lib/theme/theme_preferences.dart`. `M3Pressable` memberi feedback spring saat tekan — tetap dipakai, bukan shape (dibuang di fase refaktor berikutnya per keputusan D4). **Riwayat revert dari M3 Expressive (`puffy`/clover) → square:** lihat [theme_shapes.md](theme_shapes.md) & [ADR-012](../DECISIONS.md#adr-012).

---

## 2. `main.dart` — Pusat UI Remote

### 2.1 Entry
```dart
void main() => runApp(const MasjidYouRemoteApp());
```
`MasjidYouRemoteApp` → `MaterialApp` (tema & darkTheme dari seed `0xFF006A60`, Material 3) → `home: RemoteHomeScreen`.

### 2.2 State global `_RemoteHomeScreenState`

| State | Tipe | Peran |
|---|---|---|
| `_tabIndex` | `int` | Destinasi menu bawah aktif (0 Beranda, 1 Konten, 2 Pengaturan, 3 Tes) — indeks `IndexedStack` |
| `_subTabController` | `TabController` (4) | Menggerakkan sub-tab di dalam Konten saja (Running Text/Info Masjid/Kas/Gambar Khusus) |
| `_tvMuted` / `_tvStandby` | `bool` | Status kontrol tampilan TV dari `stateUpdate` (Beranda, ADR-023) |
| `_ipController` | `TextEditingController` | IP TV (default `192.168.1.`) |
| `_client` | `RemoteWsClient` | Koneksi WS |
| `_p2pClient` | `P2pClientService` | Koneksi WiFi Direct/BLE |
| `_btClient` | `BluetoothClientService` | Koneksi Bluetooth Classic (RFCOMM) |
| `_btIsScanning` / `_btConnected` / `_btDevices` / `_btStatus` | — | Status scan BT, koneksi, daftar perangkat, teks status |
| `_btWasConnected` | `bool` | Guard agar `_syncAllToTv()` + `getInitialState` hanya dikirim saat transisi tersambung (bukan tiap emit) |
| `_isConnecting` / `_isConnected` | `bool` | Status koneksi |
| `_isScanning` / `_p2pDevices` / `_p2pStatus` | — | Status scan P2P + daftar perangkat + teks status |
| `_hasUnsyncedChanges` | `bool` | Penanda perubahan belum dikirim (ADR-008) |
| `_config` | `MosqueConfig` | Config lokal + koordinat + offset + durasi siklus shalat |
| `_runningTexts` / `_banners` / `_kasTransactions` | `List` | Data editor lokal |
| 8× `TextEditingController` + map `_prayerOffsetControllers` | — | Form: nama, alamat, lat, lng, offset per sholat, running text, banner (4), kas (2) |
| 4× `TextEditingController` durasi | — | `_preAdhanController`, `_adhanController`, `_preIqomahController`, `_shalatController` |
| `_tvPhase` / `_tvRemaining` | `PrayerPhase` / `Duration` | Status fase TV dari `SyncAction.stateUpdate` (untuk enable tombol aksi cepat) |
| `_isFetchingLocation` | `bool` | Indikator proses ambil GPS |
| `_runningCategory` / `_kasType` | enum/string | Pilihan dropdown |

### 2.3 Inisialisasi
- `initState`: isi controller dari `_config` (termasuk lat/lng 6 desimal & offset per sholat).
- Subscribe `_p2pClient.stateStream` → jika hotspot aktif & punya `hostGatewayIpAddress` → isi `_ipController` + `_connectToTv()` (auto-connect).

### 2.4 Sinkronisasi & Unsaved Changes

**Alur umum setiap mutasi:**
```
setState { data berubah; _hasUnsyncedChanges = true }
   └─ jika _isConnected → kirim paket → setState { _hasUnsyncedChanges = false }
```

| Method | Fungsi |
|---|---|
| `_connectToTv()` | Sambung WS ke `_ipController`; sukses → `_syncAllToTv()` + reset flag |
| `_buildConfigFromForm()` | Bangun `MosqueConfig` dari semua controller (parse lat/lng dgn fallback + clamp) |
| `_syncAllToTv()` | Kirim 4 paket: config, running texts, banners, kas |
| `_pushAllToTv()` | Cek koneksi → `_syncAllToTv()` → reset flag + snackbar (dipanggil tombol "Kirim Ke TV") |
| `_sendConfigUpdate()` | Simpan config (set flag), kirim bila terhubung |

**Banner "Unsaved Changes"** (`_buildUnsyncedBanner`): Material `tertiaryContainer` di bawah AppBar saat `_hasUnsyncedChanges == true` — ikon `sync_problem` + "Ada perubahan belum dikirim ke TV" + `TextButton.icon` "Kirim Ke TV".

### 2.5 Layout utama

```
Scaffold
├── AppBar "Remote Masjid DKM"
├── body: Column
│   ├── [jika terputus] _buildDisconnectedBanner (errorContainer + Sambungkan Ulang)
│   ├── [jika unsynced] _buildUnsyncedBanner
│   ├── _buildConnectionStatusStrip — strip tonal status koneksi (tap → bottom sheet, ADR-023)
│   └── Expanded > IndexedStack(index: _tabIndex) — 4 destinasi:
│       ├── 0 HomeTab          (Beranda: status TV, jam, hitung mundur, Aksi Cepat, kas)
│       ├── 1 Konten           (Column: Top TabBar + TabBarView `_subTabController`, 4 sub-tab)
│       ├── 2 SettingsTab      (Pengaturan)
│       └── 3 SimulationTab    (Tes — simulasi waktu shalat)
└── bottomNavigationBar: NavigationBar (4 destinations: Beranda, Konten, Pengaturan, Tes)
```

Navigasi destinasi memakai **`IndexedStack`** (ADR-023): berpindah menu bawah hanya lewat tap `NavigationBar` — **tidak ada swipe antar destinasi** (mengikuti panduan M3) dan state setiap destinasi tetap hidup selama terhubung. Satu-satunya `TabController` yang tersisa adalah `_subTabController` (4) untuk sub-tab **di dalam Konten**; swipe kiri/kanan hanya berlaku di dalam Konten.

**Riwayat (sebelum ADR-023):** navigasi pernah berupa satu `TabBarView` 6 halaman yang bisa di-swipe menembus semua destinasi, disinkronkan dua `TabController` + guard `_syncingControllers`, dengan Top Tab Bar yang fade/slide mengikuti geseran dan mikro-animasi ikon `PlayfulNavIcon` (lompat + `bounceOut` + putar). Seluruh mekanisme itu dihapus: kompleks, rapuh, dan bertentangan dengan panduan navigasi M3.

State & teks form hidup karena controller-nya milik `_RemoteHomeScreenState` (tidak pernah di-reset saat destinasi berganti).

---

## 3. Tab Demi Tab

### 3.0 Destinasi Beranda (indeks 0)

`HomeTab` (`lib/screens/home/home_tab.dart`, ADR-023): kartu status TV (jalur koneksi + fase + penanda Senyap), jam aktif per detik + tanggal Indonesia, hitung mundur sholat berikutnya (`nextPrayerInfo` dari `PrayerSchedule.calculate`), **Aksi Cepat 56dp** — Senyap (`_toggleTvMuted` → `SyncAction.setMuted`), Standby (`_toggleTvStandby` → `SyncAction.setStandby`), Sinkron (`_pushAllToTv`) — dan ringkasan kas (`_totalKas` per tipe → `KasStatCard`).

### 3.1 Destinasi Pengaturan (indeks 2)

**Fungsi**: identitas masjid + koordinat + durasi siklus shalat + offset jadwal + aksi cepat + simulasi.

| Bagian | Elemen | Keterangan |
|---|---|---|
| Identitas | `Nama Masjid`, `Alamat Masjid` | `_nameController`, `_addressController` |
| Koordinat & Jadwal Sholat | `Latitude`, `Longitude` | input desimal; `_latitudeController`, `_longitudeController` |
| GPS | tombol "Ambil Koordinat dari GPS" | `_getLocationFromGps()` — spinner saat `_isFetchingLocation` |
| Offset | 6 kolom "Subuh … Isya" (suffix `mnt`) | `_prayerOffsetControllers` per `PrayerType` |
| Durasi Siklus Shalat | 4 kolom `Jelang Azan` (15), `Azan` (2), `Jeda Ikamah` (1), `Shalat` (10) | `_preAdhanController` dkk; angka `digitsOnly`, min 0 |
| Aksi Cepat | kartu "Aksi Cepat Waktu Shalat": `Skip Azan`, `Skip Ikamah / Mulai Shalat`, `Selesaikan Shalat` + status "Mode TV saat ini" | `_buildQuickActionsCard`, `_sendQuickAction(action)`; tombol aktif hanya saat fase TV sesuai (`_tvPhase`) |
| Tampilan Aplikasi | `SegmentedButton` Tema (Sistem/Terang/Gelap) + Warna (Ikuti Wallpaper/Hijau Masjid) | preferensi `ThemePreferences` (ADR-022); langsung berlaku & tersimpan di HP, tidak dikirim ke TV |
| Aksi | "Simpan & Update Ke TV" | `_sendConfigUpdate()` — juga persist durasi ke SharedPreferences |
| Simulasi | "Simulasi Jadwal" | `_showScheduleSimulation()` |

**Persist lokal:** `_loadSavedDurations()` (init) & `_persistDurations(config)` (saat kirim) memakai `shared_preferences` — kunci `preAdhanMinutes`, `adhanMinutes`, `preIqomahMinutes`, `shalatMinutes`.

### 3.2 Destinasi Konten & Sub-tab-nya (indeks 1)

Menu bawah **Konten** menyatukan 4 editor dalam satu destinasi: **Running Text**, **Info Masjid**, **Kas**, dan **Gambar Khusus**. Di dalamnya ada **Top Tab Bar** (controller `_subTabController`) + `TabBarView` sendiri:

```dart
Top Tab Bar (selalu tampil di dalam Konten, controller _subTabController)
├── Running Text   (campaign)
├── Info Masjid    (newspaper)
├── Kas            (account_balance_wallet)
└── Gambar Khusus  (photo_library)
```

Pindah antar sub-tab: **tap Top Tab Bar** atau **swipe** kiri/kanan di dalam Konten (tidak tembus ke destinasi lain).

#### 3.2.1 Sub-tab Running Text

| Elemen | Fungsi |
|---|---|
| TextField "Tambah Teks Berjalan" + tombol `+` | `_addRunningText()` |
| Dropdown "Kategori" | `Pengumuman`, `Kajian`, `Kas`, `Himbauan`, `Infaq`, `Umum` (`_runningCategories`) |
| Daftar kartu | tiap item: `edit` (`_editRunningText` dialog: isi + kategori) & `delete` (`_removeRunningText`) |

Semua men-set `_hasUnsyncedChanges` dan mengirim `sendRunningTextsUpdate` bila terhubung.

#### 3.2.2 Sub-tab Info Masjid (MediaBanner)

Form 4 bidang: **Header/Kategori** (default `INFO MASJID`), **Judul**, **Isi** (3 baris), **Kaki/Catatan**.

- Tambah: `_addBanner()` — validasi minimal judul ATAU isi.
- Daftar: tiap banner punya **Switch** (`_toggleBanner` — on/off tampil di TV), **Edit** (`_editBanner` dialog 4 bidang), **Hapus** (`_removeBanner`).
- Banner `isActive=false` akan disembunyikan TV (lihat `BannerCarousel._activeBanners`).

#### 3.2.3 Sub-tab Kas

| Bagian | Elemen |
|---|---|
| Statistik | 3 kartu `_KasStatCard`: Saldo, Pemasukan, Pengeluaran (dari `KasSummary.fromTransactions`) |
| Tambah Transaksi | `SegmentedButton` Masuk/Keluar + `Nominal (Rp)` (input digitsOnly) + `Keterangan` → `_addKasTransaction()` |
| Riwayat | daftar transaksi: avatar arah panah, tanggal `d MMM yyyy, HH:mm`, `+/-Rp` berwarna; **long-press** untuk hapus (`_removeKasTransaction`) |

### 3.3 Tab 2 — Konektivitas

| Bagian | Elemen |
|---|---|
| Koneksi Jaringan (WiFi/Router) | kolom IP + tombol `Sambungkan/Terhubung` (`_connectToTv`); kartu berubah `primaryContainer` saat terhubung |
| WiFi Direct (Tanpa Router) | tombol `Cari TV`/`Stop` (`_startScan`/`_stopScan`), `LinearProgressIndicator` saat scanning, teks status `_p2pStatus`, daftar perangkat `BleDiscoveredDevice` → tap = `_connectP2p(device)` |

### 3.4 Tab 3 — Tes (Simulasi Waktu Shalat)

**Fungsi**: menguji state machine & overlay TV dengan **memaksa TV masuk fase tertentu** (`_buildTestTab`, `_sendForcePhase`).

| Bagian | Elemen |
|---|---|
| Status koneksi & fase | kartu: ikon TV hijau/off + "Mode TV saat ini: `_tvPhase.label`" (live dari `stateUpdate`) |
| Paksa Fase — Hari Biasa | 5 tombol full-width: `Normal (Standby)`, `PRE_ADHAN`, `ADHAN`, `PRE_IQOMAH`, `SHALAT` → `sendForcePhase(phase)`; disabled bila belum terhubung |
| Paksa Fase — Hari Jumat | kartu terpisah: 1 tombol `KHUTBAH · Khutbah Jumat` → `sendForcePhase(khutbah)` |

- Tombol tersedia meski TV sedang di fase lain — tes menu **menimpa** fase saat itu (masuk dengan durasi penuh dari konfigurasi).
- Tekan `Normal (Standby)` untuk kembali ke dashboard.
- Teks tombol memakai `PrayerPhaseX.label`; dipilih pakai `Icons.rocket_launch/access_time_filled/campaign/menu_book_rounded/groups/dark_mode`.

---

## 4. Mekanisme GPS (Geolocator) & Offset Jadwal

### 4.1 `_getLocationFromGps()` — alur

```mermaid
flowchart TD
    A[Tombol Ambil Koordinat dari GPS] --> B{isLocationServiceEnabled?}
    B -- tidak --> C[Snackbar: Aktifkan layanan lokasi]
    B -- ya --> D{checkPermission}
    D -- denied --> E[requestPermission]
    E -- denied/deniedForever --> F[Snackbar: izin ditolak]
    E -- granted --> G[getCurrentPosition<br/>accuracy high, timeLimit 15s]
    D -- granted --> G
    G --> H[set lat/lng controller 6 desimal + _hasUnsyncedChanges = true]
    H --> I[Snackbar: Koordinat GPS diambil]
```

- Paket: `geolocator ^14.0.3`.
- Izin Android sudah ada di manifest: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` (+ runtime request).

### 4.2 Offset per jadwal
- `_buildConfigFromForm()` membaca 6 field offset → `prayerOffsets: Map<PrayerType,int>` (menit, boleh negatif).
- `_config` di-sync ke TV via `sendConfigUpdate`; TV menerapkan offset di `PrayerSchedule.calculate` (lihat [shared_models/MosqueConfig & PrayerSchedule](../MAP.md)).
- Backward compat: config lama ber-`prayerCorrectionMinutes` otomatis di-seed ke semua offset.

### 4.3 Simulasi Jadwal (`_showScheduleSimulation`)
- Membangun `MosqueConfig` dari form (koordinat + offset), lalu dialog:
  - Pilih **tanggal** (`showDatePicker`) & **jam** (`showTimePicker`).
  - `PrayerSchedule.calculate(config, simDateTime)` — **dihitung offline** (paket `adhan`).
  - Menampilkan 6 waktu sholat; sholat "SELANJUTNYA" disorot (`primaryContainer`) + countdown `mm:ss`.
- Tujuan: verifikasi jadwal & countdown sebelum dikirim ke TV.

---

## 5. `services/ws_client.dart` — Client WebSocket

| Method | Fungsi |
|---|---|
| `connect(ip, {port=8080})` | `WebSocketChannel.connect('ws://ip:port')` + await `ready`; set `_isConnected`; listen stream → `onPacket` |
| `sendPacket(SyncPacket)` | `sink.add(packet.toJson())` bila terhubung |
| `sendConfigUpdate(MosqueConfig)` | paket `SyncAction.updateConfig` |
| `sendRunningTextsUpdate(List<RunningTextMessage>)` | paket `updateRunningText` |
| `sendBannersUpdate(List<MediaBanner>)` | paket `updateBanners` |
| `sendKasUpdate(List<KasTransaction>)` | paket `updateKas` |
| `sendSkipAdhan()` | paket `skipAdhan` (ADHAN → PRE_IQOMAH) |
| `sendStartShalat()` | paket `startShalat` (PRE_IQOMAH → SHALAT) |
| `sendFinishShalat()` | paket `finishShalat` (SHALAT → NORMAL) |
| `sendForcePhase(PrayerPhase)` | paket `forcePhase` dengan payload `{'phase': <name>}` (dari Menu Tes) |
| `onPacket` | callback paket masuk (mis. `stateUpdate` fase TV) |
| `disconnect()` | tutup sink, reset flag |

---

## 6. `services/p2p_client_service.dart` — WiFi Direct / BLE

| Method | Fungsi |
|---|---|
| `_ensureClient()` | lazy-init `FlutterP2pClient` (hanya Android) + listen `streamHotspotState` → `_stateController` |
| `startScan(onDevices)` | cek/minta izin P2P & Bluetooth; cek/aktifkan WiFi & Bluetooth; `startScan(onDevices)` |
| `stopScan()` | hentikan scan |
| `connectTo(BleDiscoveredDevice)` | `connectWithDevice(device)` |
| `disconnect()` | `disconnect()` + `stopScan()` |

**Auto-connect:** `stateStream` (hotspot aktif dengan `hostGatewayIpAddress`) di-subscribe di `initState` → isi IP + `_connectToTv()`.

---

## 7. `services/bluetooth_client_service.dart` — Bluetooth Classic (RFCOMM)

| Method / anggota | Fungsi |
|---|---|
| `startDiscovery()` | cek/minta izin mode `client` (`CONNECT` + `SCAN`); aktifkan BT bila mati; `BluetoothSync.startDiscovery()` → event `discovered` mengisi daftar (dedupe per alamat, perangkat tanpa nama dilewati) |
| `stopDiscovery()` | hentikan scan; selalu emit state (tidak early-return diam) |
| `connectTo(BluetoothDeviceInfo)` | set status `connecting` → `BluetoothSync.connect(address)`; `connected` datang dari event plugin |
| `sendPacket(SyncPacket)` | kirim JSON sebagai frame 4-byte big-endian bila terhubung |
| `stateStream` / `currentState` | `BluetoothClientState` (status, isScanning, isConnected, devices, peerName, error) |
| `onPacket` | callback `SyncPacket` masuk dari TV |
| `disconnect()` / `dispose()` | putus koneksi, reset flag + daftar device |

**Auto-reconnect:** setelah event `disconnected`/`error`, service menjadwalkan reconnect dengan guard `_reconnecting` dan batas percobaan; pesan error yang tampil membedakan "menunggu percobaan ulang" vs "percobaan habis".

**Alur di `main.dart`:** listener `stateStream` → `if (state.isConnected && !_btWasConnected)` → `_syncAllToTv()` + kirim `getInitialState`; saat putus `_btWasConnected` direset. Paket keluar dari `RemoteWsClient.onSendPacket` di-mirror ke `_btClient.sendPacket` agar Remote yang hanya tersambung lewat BT tetap bisa kirim.

---

## 8. Kebersihan & Dispose

Semua controller di-`dispose()`: `_ipController`, nama/alamat/lat/lng, `_prayerOffsetControllers.values`, 4 controller durasi (`_preAdhanController` dkk), running text, 4 banner, 2 kas, `_mainTabController`, `_subTabController`; lalu `_p2pClient.disconnect()`, `_btClient.dispose()`, dan `_client.disconnect()`.

---

## 9. Lint & Test

- `flutter analyze`: hanya `info` (tidak `error`):
  - `avoid_print` di `p2p_client_service.dart`.
  - `deprecated_member_use` `DropdownButtonFormField.value` — **sengaja dipertahankan** karena dropdown dikendalikan state (`_runningCategory`).
- `test/widget_test.dart`: smoke test `MasjidYouRemoteApp` render judul "Remote Masjid DKM" + navigasi ke menu Tes (`pumpAndSettle` karena pindah tab memakai animasi `TabBarView`).

---

## 9. Menambah Tab / Fitur (checklist)

1. Tambah halaman di `TabBarView` utama (`_mainTabController`), tambah destination di `NavigationBar`, dan lengkapi `_bottomNavIndexForPage` / `_mainPageForBottomNav`.
2. Untuk grup sub-tab: tambahkan halamannya di tengah `TabBarView` + tab di Top Tab Bar (`_subTabController`); pastikan mapping `_bottomNavIndexForPage` mengelompokkannya ke satu menu bawah; beri `PageStorageKey` pada `ListView` tiap halaman.
3. Tambah state & controller; daftarkan di `dispose()`.
4. Setiap mutasi: `setState { data; _hasUnsyncedChanges = true }` → kirim bila terhubung → reset flag.
5. Bila butuh data baru di TV: tambah case `SyncAction` + model di `shared_models` + rebuild dua app.
6. Verifikasi: `flutter analyze`, `flutter test`, build `android-x64`, pasang ke `emulator-5554` (HP).

---

> Kembali ke [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [theme_shapes.md](theme_shapes.md) · [tv_display/widget_mapping.md](../tv_display/widget_mapping.md) · [tv_display/prayer_state_machine.md](../tv_display/prayer_state_machine.md)
