# tv_display — Widget & File Mapping

> Bedah lengkap **`apps/tv_display/lib/`** — aplikasi kiosk di Google TV / Android TV.
> Layout, state management, lifecycle timer, dan penanganan layar TV (2K / emulator 960×540).

**Navigasi:** [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [mobile_remote/tab_mapping.md](../mobile_remote/tab_mapping.md)

---

## 1. Struktur File

```
apps/tv_display/lib/
├── main.dart                  # Entry, state global, orkestrasi server + P2P + state machine, layout
├── theme/
│   ├── app_theme.dart         # Tema gelap Material You (seed 0xFF006A60, Card puffy)
│   └── m3_shape_border.dart   # M3ShapeBorder (wrapper polygon) + ArchBorder (arch manual)
├── state/
│   └── prayer_state_machine.dart # Siklus waktu shalat otomatis (NORMAL→PRE_ADHAN→ADHAN→PRE_IQOMAH→SHALAT)
├── widgets/
│   ├── header_clock.dart      # Header: jam (ArchBorder), tanggal, nama masjid, chip IP/P2P
│   ├── banner_carousel.dart   # Carousel Info Masjid + fallback + auto-scroll
│   ├── kas_summary_card.dart  # Ringkasan kas
│   ├── prayer_cards.dart      # 6 kartu sholat + ring swap countdown/waktu
│   ├── prayer_state_overlay.dart # Overlay fase shalat + CustomPainter (ring, wavy)
│   └── running_text_bar.dart  # Marquee running text + fallback kosong
└── server/
    ├── local_ws_server.dart   # Server WebSocket :8080
    └── p2p_host_service.dart  # Host WiFi Direct
```

---

## 2. `main.dart` — Orkestrator Utama

### 2.1 Entry (`main()`)
```dart
WidgetsFlutterBinding.ensureInitialized();
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // fullscreen kiosk
await WakelockPlus.enable();                                       // TV tidak tidur
runApp(const MasjidYouTVApp());
```

### 2.2 Widget tree level atas
- `MasjidYouTVApp` (stateless) → `MaterialApp(theme: AppTheme.darkTheme, home: MasjidDisplayScreen)`.
- `MasjidDisplayScreen` (stateful) → semua state global hidup di sini.

### 2.3 State global di `_MasjidDisplayScreenState`

| State | Tipe | Peran |
|---|---|---|
| `_now` | `DateTime` | Jam sekarang, di-update tiap detik |
| `_clockTimer` | `Timer?` | Timer 1 detik → `setState(_now; _prayerSchedule = calculate(_config,_now))` + `_prayerStateMachine.tick(...)` |
| `_localServer` | `LocalServer?` | Server WS |
| `_localIp` | `String?` | IP LAN TV (untuk chip "Remote Sync IP") |
| `_p2pHost` | `P2pHostService` | Host WiFi Direct |
| `_p2pState` | `HotspotHostState?` | Status grup P2P |
| `_config` | `MosqueConfig` | Konfigurasi masjid + koordinat + offset + durasi siklus shalat |
| `_runningTexts` | `List<RunningTextMessage>` | Pesan berjalan |
| `_banners` | `List<MediaBanner>` | Info masjid |
| `_kasTransactions` | `List<KasTransaction>` | Transaksi kas |
| `_prayerSchedule` | `PrayerSchedule` | Jadwal sholat terhitung |
| `_prayerStateMachine` | `PrayerStateMachine` | Siklus waktu shalat otomatis (lihat §3.6) |

### 2.3b Lifecycle state machine (baru)

- `initState`: `_prayerStateMachine.initialize(_config, autoCycle: widget.autoPrayerCycle)` + `addListener(_onStateMachineChanged)`.
- Clock timer 1 detik juga memanggil `_prayerStateMachine.tick(_now, _prayerSchedule)`.
- `_onStateMachineChanged` → `_broadcastState()`: kirim `SyncAction.stateUpdate` (`phase`, `prayer`, `remainingSeconds`) ke Remote.
- Paket masuk: `skipAdhan` / `startShalat` / `finishShalat` → delegasi ke state machine; `forcePhase` (`{'phase': ...}`) → `PrayerPhase.fromName` + `forcePhase(...)`; `getInitialState` → `_broadcastState()`.
- `dispose()`: `removeListener` + `dispose()` state machine.

### 2.4 Lifecycle & sinkronisasi

```mermaid
flowchart TD
    A[initState] --> B[_recalculateSchedule]
    B --> C[clockTimer 1 detik]
    C --> D[setState now + schedule]
    A --> E[_initLocalServer port 8080]
    E --> F[_fetchLocalIp]
    A --> G[_initP2pHost]
    G --> H[listen stateStream + start]
    E --> I[onPacketReceived switch SyncAction]
    I --> J[updateConfig→recalc schedule]
    I --> K[updateRunningText→_runningTexts]
    I --> L[updateBanners→_banners]
    I --> M[updateKas→_kasTransactions]
```

`dispose()`: `_clockTimer?.cancel()`, `_localServer?.stop()`, `_p2pHost.stop()`.

### 2.5 Layout layar (build)

```
Stack(fit: expand)
├── Image.network(masjid)  ── errorBuilder → surfaceContainerLowest
├── Overlay hitam alpha .85 (kontras)
└── SafeArea > Padding(10) > Column
    ├── HeaderClock
    ├── SizedBox(6)
    ├── Expanded > Row [ BannerCarousel (flex 3) | KasSummaryCard (flex 2) ]
    ├── SizedBox(6)
    ├── PrayerCardsRow
    ├── SizedBox(6)
    └── RunningTextBar
```

---

## 2.6 Pemetaan Material 3 Expressive Shapes (per komponen)

> **Arsitektur & riwayat lengkap perubahan shape terbaru** (manual shapes, `ArchBorder`,
> model swap, penghapusan badge): lihat [`m3_shapes.md`](m3_shapes.md).
> Padding internal setiap Card: **`EdgeInsets.symmetric(horizontal: 24, vertical: 16)`** agar teks tidak terpotong sudut shape.

| Komponen | Shape |
|---|---|
| Header container (nama & alamat masjid) | `RoundedRectangleBorder(28)` |
| Container jam digital (`HH:mm:ss` + tanggal) | **`ArchBorder`** (manual — dome di dalam bounds) |
| Info Masjid card (`BannerCarousel`) | `RoundedRectangleBorder(28)` |
| Kas Summary card | `RoundedRectangleBorder(28)` |
| Kartu shalat standar (Subuh–Maghrib) | `M3ShapeBorder(MaterialShapes.slanted)` |
| Kartu shalat aktif (shalat berikutnya) | `RoundedRectangleBorder(28)` + side `primary` 2px |
| Badge "INFORMASI" (running text) | `StadiumBorder()` |
| Badge header banner | `M3ShapeBorder(MaterialShapes.pill)` |
| Running text bar (kosong & aktif) | `RoundedRectangleBorder(28)` |

**Catatan penyesuaian**: kartu besar (Header, Info Masjid, Kas, Running Text) memakai
**`RoundedRectangleBorder(borderRadius: 28)`** manual, bukan `MaterialShapes.square` dari
package (pembulatan `_cornerRound30` terlalu besar). Badge tetap **pill/stadium**.
Kapsul jam memakai **`ArchBorder`** manual (polygon `arch` package ternormalisasi → kubah
terlalu besar & makan ruang vertikal; versi awal yang menggambar dome di luar `rect.top`
diperbaiki agar dome selalu di dalam bounds).

**Background** (`MaterialBlobBackground`): blob diperkecil — `size` 120–160 (radius ~60–80 px, turun 40–50% dari 300–420) dan opacity diturunkan ke **0.10–0.15** agar melayang halus tanpa menutupi konten.

---

## 3. Widget-Widget

### 3.1 `HeaderClock` — header & jam (stateless)
- Props: `config`, `currentTime`, `serverIp`, `p2pActive`, `p2pSsid`, `p2pIp`.
- Kiri: nama masjid (`config.name`), alamat (`config.address`), chip IP (`serverIp:8080`), chip P2P ("Mode Direct: `<ssid>` (`<ip>`)").
- Kanan: kapsul jam besar `HH:mm:ss` (tabular figures) + tanggal `EEEE, d MMMM yyyy` (locale `id_ID`, fallback default).
- **M3 Expressive**: kartu header `RoundedRectangleBorder(28)`, kapsul jam **`ArchBorder`** (manual) dengan padding `only(top: 20, bottom: 12, left: 28, right: 28)` — dome di dalam bounds agar tidak ter-clip (lihat [m3_shapes.md](m3_shapes.md) §2).
- **Catatan TV**: teks nama/alamat di-`ellipsis` (max 1 baris) agar tidak overflow di layar sempit.

### 3.2 `BannerCarousel` — carousel info masjid (stateful)

**`_BannerCarouselState`:**
| Elemen | Detail |
|---|---|
| `_activeBanners` | getter filter `b.isActive` — hanya banner aktif ditampilkan |
| `_pageController` | `PageController` untuk `PageView.builder` |
| `_timer` | `Timer.periodic(10 dtk)` → `animateToPage(next, 600ms, easeInOutCubic)` |
| Fallback kosong | jika `_activeBanners.isEmpty` → kartu ikon masjid + **"Jagalah Shaf dan Shalatlah Tepat Waktu"** |
| Reset indeks | `if (_currentIndex >= banners.length) _currentIndex = 0` |

**`_BannerPage` (stateful, satu halaman):**
- Layout: header pill (`M3ShapeBorder(MaterialShapes.pill)`) + judul (`displayMedium` 26px) + isi (`titleMedium` 16px, `height 1.3`) + footer (`labelLarge`, warna primary); padding `symmetric(horizontal: 24, vertical: 16)`.
- Kartu `BannerCarousel` memakai shape **`RoundedRectangleBorder(28)`** (latar bersih/rapi).
- **Auto-scroll vertikal** untuk teks panjang:
  - `_scrollController` + `SingleChildScrollView`.
  - `_startAutoScroll()`: hitung `step = maxScrollExtent / (9000ms / 50ms)`; `Timer.periodic(50ms)` `jumpTo(offset + step)`; berhenti saat sampai ujung; abaikan jika `maxScroll <= 0`.
  - Reset ke atas jika konten berubah **atau** halaman kembali aktif.
- `didUpdateWidget`: bandingkan 4 field (header/title/content/footer); jika berubah → cancel timer, `jumpTo(0)`, mulai ulang. Jika `active` berubah `false→true` → reset & mulai ulang.

**Tidak memakai FittedBox** → font tidak mengecil (lihat [ADR-005](../DECISIONS.md#adr-005)).

### 3.3 `KasSummaryCard` — ringkasan kas (stateless)
- `KasSummary.fromTransactions(transactions)` → `saldo`, `totalMasuk`, `totalKeluar`.
- Format uang: `NumberFormat.currency(id_ID, 'Rp ', 0 desimal)`.
- Layout: ikon + judul "Kas Masjid", saldo besar (42px, `FittedBox` scaleDown), label "SALDO KAS", baris pemasukan (tertiary) & pengeluaran (error) via `_KasAmountRow`.
- **M3 Expressive**: kartu `square`, padding internal `symmetric(horizontal: 24, vertical: 16)`.

### 3.4 `PrayerCardsRow` — 6 kartu sholat (stateless)

```
Row
└─ Expanded × 6 (kartu per PrayerScheduleItem)
   ├─ nama sholat (displayName)
   └─ waktu:
        ├─ jika NEXT & timeUntilNextPrayer != null → _NextPrayerTimer (ring + swap)
        └─ lainnya → FittedBox teks HH:mm (32px)
```

**Highlight shalat berikutnya:** kartu berwarna `primaryContainer` + border `primary` 2px.
- **M3 Expressive**: kartu shalat standar **`M3ShapeBorder(MaterialShapes.slanted)`**, kartu aktif **`RoundedRectangleBorder(28)`** + side `primary` 2px (badge "SELANJUTNYA" **dihapus**), padding internal `symmetric(horizontal: 24, vertical: 16)`.
- Kartu aktif hanya berisi **nama shalat + ring** (tanpa jam statis besar di atas ring) — informasi waktu ditampilkan bergantian di dalam ring (model *swap*, lihat di bawah).

**`_remainingFraction(schedule)`** (proporsi sisa):
- `idx` = posisi sholat berikutnya.
- total = interval `item[idx].time − item[idx-1].time`; untuk Fajr (`idx==0`): interval = `fajr_today − (isha_kemarin)` dihitung `item[0].time − (item.last.time − 1 hari)`.
- `fraction = remaining/total` di-clamp `0..1`, 0 jika total ≤ 0.

**`_NextPrayerTimer` (stateful):**
- Ring `CircularProgressIndicator` 84×84, stroke 6, `StrokeCap.round`, warna `primary` di atas `onPrimaryContainer` alpha 0.15.
- Di tengah, **AnimatedSwitcher** (slide + fade 400ms) **swap tiap 4 detik** (`Timer.periodic`, di-cancel di `dispose`):
  - Mode countdown: `mm:ss` / `hh:mm:ss` + label **"tersisa"** (font 20px).
  - Mode waktu: `HH:mm` asli + label **"waktu"**.
- `_formatDuration` meng-clamp negatif ke `Duration.zero` (tidak pernah tampil minus).
- `ValueKey(_showCountdown)` menjadi kunci child AnimatedSwitcher agar transisi terpicu.
- Riwayat & alasan model swap: lihat [m3_shapes.md](m3_shapes.md) §3–§4.

### 3.5 `RunningTextBar` — running text (stateful)

**Dua kondisi di `build`:**

| Kondisi | Render |
|---|---|
| `activeMessages.isEmpty` | `_buildEmptyState`: `Card` full width shape **`RoundedRectangleBorder(28)`** (padding `symmetric(24, 8)`, tinggi konten 40, warna `primary`) berisi icon 📢 + **INFORMASI** + `•` + **"Tidak ada informasi"** (statis, tanpa scroll) |
| ada pesan aktif | `_buildRunningState`: `Card` shape **`RoundedRectangleBorder(28)`** dengan badge **`StadiumBorder()`** kiri (icon + INFORMASI) + `Expanded(ListView horizontal)` marquee `[Kategori] isi • [Kategori] isi …`; padding `symmetric(horizontal: 24, vertical: 8)`, `ListView` padding `horizontal: 12` |

**Timer marquee (`_startAutoScroll`):**
- `Timer.periodic(50ms)`; `jumpTo(offset + 2.0)`; reset ke 0 saat mencapai `maxScrollExtent`; `SizedBox(width: 400)` di akhir list sebagai ruang loop.
- Jika `activeMessages.isEmpty` → **tidak menjalankan timer** (`return` sebelum `Timer.periodic`).

**`didUpdateWidget`:** saat `widget.messages` berubah —
- kosong → `_timer?.cancel()`;
- terisi & timer mati → `_startAutoScroll()`.

**Perbaikan leak:** teks fallback lama berisi `${Theme.of(context).primaryColor}` (menghasilkan `Color(0xff006a60)` di layar) **dihapus total** — lihat [ADR-004](../DECISIONS.md#adr-004).

---

## 3.6 `PrayerStateMachine` & `PrayerStateOverlay` — siklus waktu shalat

> **Arsitektur lengkap fitur ini** (apa yang diubah, kenapa, cara kerja, protokol & alur end-to-end): lihat [`prayer_state_machine.md`](prayer_state_machine.md).

### 3.6.1 `PrayerStateMachine` (`state/prayer_state_machine.dart`)
Manager murni Dart (`ChangeNotifier`), **tidak punya timer sendiri** — di-drive oleh clock timer 1 detik:

| Method | Fungsi |
|---|---|
| `initialize(config, {autoCycle})` | Reset ke `NORMAL` |
| `tick(now, schedule)` | Auto-start dari normal (`timeUntilNextPrayer <= preAdhanMinutes`; Syuruq dikecualikan) atau hitung sisa & transisi |
| `skipAdhan()` | `ADHAN → PRE_IQOMAH` (no-op di fase lain) |
| `startShalat()` | `PRE_IQOMAH → SHALAT` (no-op di fase lain) |
| `finishShalat()` | `SHALAT → NORMAL` (no-op di fase lain) |
| `forcePhase(phase, {now, schedule})` | Paksa masuk fase (Menu Tes): durasi penuh dari config; prayer = `schedule.nextPrayer` (atau pertahankan saat ini); `normal` reset penuh |
| `updateConfig(config, now)` | Update durasi; clamp sisa jika durasi baru lebih pendek |
| `phase / prayer / remaining / total / progress` | Getter untuk overlay + broadcast |

Fase & durasi diambil dari `MosqueConfig` (default: 15/2/1/10 menit).

### 3.6.2 `PrayerStateOverlay` (`widgets/prayer_state_overlay.dart`)

Overlay layar penuh (Stack paling atas). Render per fase:

| Fase | UI | Painter |
|---|---|---|
| `normal` | `SizedBox.shrink()` | — |
| `preAdhan` | Circular ring + `Icons.access_time_rounded` + "Menjelang Azan [Nama]" | `_CircularRingPainter` |
| `adhan` | Wavy bar + `Icons.volume_up_rounded` + "Azan [Nama] Berkumandang" (palet moody: muted teal/olive/amber/sage) | `_WavyProgressPainter` (single sine wave stroke line + cursor bar `|`) |
| `preIqomah` | Circular ring + `Icons.groups_rounded` + "Shalat [Nama] Sebentar Lagi" | `_CircularRingPainter` |
| `shalat` | Hitam penuh + teks redup "Sedang Melangsungkan Shalat [Nama]" | — |

**Performa:** animasi gelombang `AnimationController.repeat()` + `CustomPainter(repaint:)` → repaint 60 FPS tanpa rebuild; **progress wavy bar dihitung sub-detik dari `deadline`** (`PrayerStateMachine.deadline`) terhadap `DateTime.now()` saat `paint` → cursor mulus 60 FPS tanpa menunggu tick 1 detik; ring dihaluskan `TweenAnimationBuilder` 900 ms antar tick 1 detik.

**Tuning wavy bar (ADHAN):** garis gelombang `strokeWidth 8.0`, `wavelength 52.0`, `amplitude 5.0`, `step 2.0`, `StrokeCap.round`; track `strokeWidth 4.0`; cursor bar vertikal `height 22`, `strokeWidth 4.0`. Progress aktif (ujung kanan garis + cursor) = `clamp(remainingMs / totalMs)` dari `deadline.difference(now)` tiap frame.

---

## 4. Server & Konektivitas

### 4.1 `LocalServer` (`server/local_ws_server.dart`)
- `start({port=8080})`: `webSocketHandler` + `serve(handler, anyIPv4, 8080)`.
  - Tiap koneksi masuk ditambahkan ke `_clients`; pesan didecode `utf8` → `SyncPacket.fromJson` → `onPacketReceived(packet)`; `onDone`/`onError` menghapus client.
- `broadcast(SyncPacket)`: kirim JSON ke semua client.
- `stop()`: tutup semua sink + `_server?.close(force:true)`.

### 4.2 `P2pHostService` (`server/p2p_host_service.dart`)
- `start()` (hanya Android): `FlutterP2pHost.initialize()` → `streamHotspotState()` (di-forward ke `_stateController` broadcast) → minta izin P2P & Bluetooth bila perlu → `createGroup(advertise:true)`.
- `stop()`: `removeGroup()` + `dispose()`.
- **Catatan**: tidak memanggil `enableWifiServices`/`enableBluetoothServices` (menghindari layar pengaturan WiFi terbuka otomatis di emulator/TV).

---

## 5. State Management & Lifecycle Timer (rekap)

| Timer | Lokasi | Periode | Fungsi |
|---|---|---|---|
| `_clockTimer` | main.dart | 1 dtk | update jam + hitung ulang schedule + `_prayerStateMachine.tick()` |
| `_pageTimer` | banner_carousel | 10 dtk | pindah halaman carousel |
| `_scrollTimer` | banner_carousel (`_BannerPage`) | 50 ms | auto-scroll vertikal (9 dtk) |
| `_scrollTimer` | running_text_bar | 50 ms | marquee horizontal |
| `_toggleTimer` | prayer_cards (`_NextPrayerTimer`) | 4 dtk | toggle countdown ↔ waktu |
| `AnimationController.repeat()` | prayer_state_overlay (`_WavyProgressBar`) | 2,8 dtk | animasi sine wave 60 FPS (`repaint`) |

Semua timer di-`cancel` di `dispose()` masing-masing widget/state.

**Pattern state:** *local widget state* + *parent-driven props*. Tidak ada state management library (setState saja) — volume data kecil dan satu arah (Remote → TV). Perubahan data dari WS masuk lewat `onPacketReceived` → `setState` → widget turunan menerima props baru.

---

## 6. Penanganan Layar TV / 2K / Resizing

- **Viewport dev**: emulator Android TV = `wm size 1920x1080` + density 320 → Flutter melihat **960×540 logical**. Test regresi `TV layout has no overflow at small TV viewport` memakai `physicalSize 1920x1080` + `devicePixelRatio 2.0` dan memastikan `tester.takeException() == null`.
- **Anti-overflow** yang dipakai:
  - `FittedBox(scaleDown)` untuk jam kas, waktu sholat non-next, chip IP/P2P.
  - `maxLines + TextOverflow.ellipsis` untuk nama/alamat masjid.
  - `Expanded` + `flex` untuk membagi banner (3) dan kas (2).
  - fallback penuh untuk daftar kosong (banner & running text).
- **Kiosk**: `immersiveSticky` + `wakelock_plus` → tampilan penuh tanpa sleep.

---

## 7. Test yang Ada

| File | Cakupan |
|---|---|
| `test/widget_test.dart` | Smoke `MasjidYouTVApp`; regresi overflow 960×540 (memakai `MasjidDisplayScreen(autoPrayerCycle: false)` agar deterministik) |
| `test/running_text_bar_test.dart` | Kosong → badge full-width + "Tidak ada informasi" (tidak di dalam ListView); semua non-aktif → sama; ada isi → marquee + badge |
| `test/prayer_state_machine_test.dart` | 15 unit test state machine: auto-start, auto-cycle penuh, skip (no-op di fase salah), clamp durasi, exclude Syuruq, `autoCycle:false`, `forcePhase` |
| `test/prayer_state_overlay_test.dart` | 5 widget test overlay (4 fase) bebas overflow di viewport 960×540 |

---

## 8. Menambah Fitur Baru (checklist)

1. Model baru / ubah field → di `packages/shared_models` + test → rebuild **kedua app**.
2. Sisi TV: tambah case di `onPacketReceived` (main.dart) bila data datang dari Remote.
3. Widget: ikuti pola props + local timer; cancel timer di `dispose`; tangani daftar kosong.
4. Jalankan `flutter analyze` & `flutter test` (termasuk test 960×540).
5. Build `flutter build apk --debug --target-platform android-x64` dan pasang ke `emulator-5556` (Android TV).

---

> Kembali ke [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [m3_shapes.md](m3_shapes.md) · [prayer_state_machine.md](prayer_state_machine.md) · [mobile_remote/tab_mapping.md](../mobile_remote/tab_mapping.md)
