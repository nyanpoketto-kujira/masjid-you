# tv_display — Material 3 Expressive Shapes (m3_shapes.md)

> Dokumen arsitektur untuk **perubahan shape terbaru** di `apps/tv_display`:
> pergantian dari shape package `material_new_shapes` ke shape manual
> (`RoundedRectangleBorder(28)` + `ArchBorder` + `StadiumBorder`), dan model
> *swap* jam di kartu shalat aktif.
>
> Setiap bagian ditulis dengan pola **Apa yang diubah → Kenapa keputusan
> diambil → Bagaimana cara kerjanya**.

**Navigasi:** [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [widget_mapping.md](widget_mapping.md) · [mobile_remote/tab_mapping.md](../mobile_remote/tab_mapping.md)

---

## Ringkasan Perubahan (terbaru)

| No | Perubahan | File |
|---|---|---|
| 1 | Shape `MaterialShapes.square` diganti `RoundedRectangleBorder(borderRadius: 28)` di 4 kartu utama | `header_clock.dart`, `banner_carousel.dart`, `kas_summary_card.dart`, `running_text_bar.dart` |
| 2 | Jam header tidak lagi `MaterialShapes.arch` — dibuat **`ArchBorder`** manual (dome di dalam bounds) | `theme/m3_shape_border.dart`, `header_clock.dart` |
| 3 | Badge "SELANJUTNYA" **dihapus** dari kartu shalat aktif; kartu aktif kini `RoundedRectangleBorder(28)` + border primary 2px | `prayer_cards.dart` |
| 4 | Jam di ring kartu aktif memakai model **swap** (countdown ↔ waktu, tiap 4 detik) — bukan tampil statis | `prayer_cards.dart` (`_NextPrayerTimer`) |
| 5 | Kartu shalat non-aktif tetap `M3ShapeBorder(MaterialShapes.slanted)`; badge pill tetap `M3ShapeBorder(MaterialShapes.pill)` / `StadiumBorder` | `prayer_cards.dart`, `running_text_bar.dart`, `banner_carousel.dart` |
| 6 | `ArchBorder.getInnerPath` = `getOuterPath` (tanpa `Path.deflate` — tidak ada di Flutter 3.44.9) | `theme/m3_shape_border.dart` |

---

## 1. Square Package → `RoundedRectangleBorder(28)` manual

### Apa yang diubah
Kartu-kartu besar di layar TV yang sebelumnya memakai
`M3ShapeBorder(MaterialShapes.square)` dari `material_new_shapes` sekarang
memakai `RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))`:
- **Header** (nama & alamat masjid) — `header_clock.dart`
- **Info Masjid** (`BannerCarousel`, kondisi kosong & terisi) — `banner_carousel.dart`
- **Kas Summary** — `kas_summary_card.dart`
- **Running Text Bar** (kondisi kosong & terisi) — `running_text_bar.dart`

Badge **pill** dibiarkan ekspresif: "INFORMASI" memakai `StadiumBorder()` murni
(`running_text_bar.dart`), badge header banner memakai
`M3ShapeBorder(MaterialShapes.pill)` (`banner_carousel.dart`).

### Kenapa keputusan ini diambil
- `MaterialShapes.square` dari package dihasilkan oleh `_cornerRound30` yang
  membulatkan sudut **terlalu besar** sehingga kartu tampak tidak bersih/rapi
  sebagai "kotak" konten.
- Sudut 28 px adalah nilai kompromi yang konsisten dengan radius kartu aktif
  shalat dan terlihat rapi di layar TV (960×540 logis).
- Menghindari `M3ShapeBorder` non-const di dalam pohon widget statis yang tidak
  butuh ekspresi bentuk — `RoundedRectangleBorder` juga `const`-friendly.

### Bagaimana cara kerjanya
`RoundedRectangleBorder` adalah shape bawaan Flutter; langsung dipakai sebagai
`Card.shape` (atau `Container`/`ShapeDecoration`). Semua kartu memakai
`side: BorderSide(outlineVariant alpha 0.2–0.3)` agar tetap terlihat di atas
latar belakang kiosk.

```dart
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(28),
  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
),
```

---

## 2. Jam Header: `ArchBorder` Manual

### Apa yang diubah
Kapsul jam digital (`HH:mm:ss` + tanggal) di header tidak lagi memakai
`M3ShapeBorder(MaterialShapes.arch)` dari package. Dibuat kelas baru
**`ArchBorder`** (`theme/m3_shape_border.dart`) — `OutlinedBorder` custom
berbentuk *arch pintu masjid*: dome di bagian atas, sudut bawah membulat.
Padding container jam diubah ke `EdgeInsets.only(top: 20, bottom: 12, left: 28, right: 28)`.

### Kenapa keputusan ini diambil
- Polygon package **ternormalisasi (0..1)**; saat di-stretch ke container jam
  yang lebar, tinggi kubah ikut membesar dan **memakan ruang vertikal** header.
- Versi awal `ArchBorder` menggambar dome **di luar** `rect.top`
  (`rect.top - rise`) sehingga ter-clip menjadi **dome dengan puncak terpotong
  datar** (ditemukan lewat verifikasi emulator — bagian atas kapsul tampak
  "dipotong").
- Keputusan: dome selalu digambar **di dalam bounds** layout (puncak di
  `rect.top`, sisi lurus mulai di `rect.top + rise`).

### Bagaimana cara kerjanya
- `rise = min(width × domeFactor, height × 0.4)` — `domeFactor = 0.2`, dan
  di-clamp agar tidak melebihi 40% tinggi container. Ini yang mencegah kubah
  "makan" area teks.
- Path: mulai bawah-kiri → dua `quadraticBezierTo` membulatkan dua sudut bawah
  (`r = min(bottomRadius, min(w,h)/2)`), naik ke `rect.top + rise` di kanan →
  dome atas digambar dengan dua kurva kuadratik bertemu di titik `(cx, rect.top)`
  → tutup di kiri.
- `getInnerPath` mengembalikan `getOuterPath` — tidak memakai
  `Path.deflate` (API `deflate` **tidak tersedia** pada Flutter 3.44.9), jadi
  sisi dalam = sisi luar. Ini cukup karena `ArchBorder` dipakai sebagai
  `ShapeDecoration.shape` (isi saja, tanpa border tebal).
- Padding `top: 20` memberi ruang untuk teks agar tidak menempel di titik
  puncak dome yang menyempit; `bottom: 12` + `horizontal: 28` menyamakan
  estetika dengan kartu lain (radius 28).

```dart
Container(
  padding: const EdgeInsets.only(top: 20, bottom: 12, left: 28, right: 28),
  decoration: ShapeDecoration(
    color: colorScheme.surfaceContainerHighest,
    shape: const ArchBorder(),
  ),
  child: Column(
    children: [
      Text(timeFormat.format(currentTime), ...), // HH:mm:ss 42px
      Text(dateFormat.format(currentTime), ...), // EEEE, d MMMM yyyy (id_ID)
    ],
  ),
)
```

---

## 3. Badge "SELANJUTNYA" Dihapus & Kartu Aktif Dirombak

### Apa yang diubah
- Badge pill **"SELANJUTNYA"** di kartu shalat aktif **dihapus total**.
- Kartu aktif tidak lagi memakai `MaterialShapes.arch`; kini
  `RoundedRectangleBorder(borderRadius: 28)` + `BorderSide(primary, width: 2)`,
  dengan warna `primaryContainer`.
- Layout kartu aktif **tidak lagi menampilkan jam statis besar** di atas ring —
  hanya nama shalat + ring `_NextPrayerTimer`.
- Kartu non-aktif tetap `M3ShapeBorder(MaterialShapes.slanted)` dengan nama +
  jam statis (`FittedBox`, `fontSize: 32`).

### Kenapa keputusan ini diambil
- User (via verifikasi visual) melaporkan jam di kartu aktif yang tampil statis
  besar **bertabrakan** dengan ring — keduanya berebut perhatian dan membuat
  kartu aktif lebih ramai daripada kartu lain.
- Keputusan: kartu aktif cukup menampilkan **nama shalat + ring**, dan ring
  sendirilah yang menampilkan informasi waktu secara bergantian (model *swap*,
  lihat §4). Ini mengembalikan perilaku "jam bergantian" seperti sebelumnya
  yang sudah disetujui user.
- Border `primary` 2px + `primaryContainer` tetap jadi penanda "ini shalat
  berikutnya" tanpa badge tambahan.

### Bagaimana cara kerjanya
```dart
final isNext = item.type == schedule.nextPrayer;
shape: isNext
    ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.primary, width: 2),
      )
    : M3ShapeBorder(MaterialShapes.slanted, side: ...),
```

Di dalam kartu:
```dart
if (isNext && schedule.timeUntilNextPrayer != null) ...[
  SizedBox(height: 8),
  _NextPrayerTimer(...)   // ring + swap
] else ...[
  SizedBox(height: 6),
  FittedBox(child: Text(item.formattedTime, fontSize: 32)), // kartu non-aktif
],
```

---

## 4. Model "Swap" Jam di `_NextPrayerTimer`

### Apa yang diubah
`_NextPrayerTimer` (di `prayer_cards.dart`) kembali menjadi **`StatefulWidget`**
yang menampilkan ring `CircularProgressIndicator` 84×84 dengan teks di tengah
yang **bergantian tiap 4 detik** (sebelumnya sempat disederhanakan menjadi
hanya countdown).

### Kenapa keputusan ini diambil
- User meminta mengembalikan model **swap** "seperti sebelumnya": dua informasi
  (sisa waktu & jam shalat) tidak muat berdampingan di dalam ring kecil, maka
  ditampilkan bergantian agar keduanya tetap terlihat tanpa menambah ukuran.
- `AnimatedSwitcher` memberi transisi halus (fade + slide 400 ms) alih-alih
  kedipan mendadak.

### Bagaimana cara kerjanya
- `Timer.periodic(4s)` membalik `_showCountdown` (di-cancel di `dispose`).
- Dua mode, dipisah dengan `ValueKey(_showCountdown)` agar `AnimatedSwitcher`
  mengenali perubahan child:
  - **Countdown**: `mm:ss` / `hh:mm:ss` (dari `_formatDuration`, clamp negatif
    → `Duration.zero`) + label **"tersisa"**.
  - **Waktu**: `item.formattedTime` (`HH:mm`) + label **"waktu"**.
- `transitionBuilder` = `FadeTransition` + `SlideTransition` (offset 0→0.6)
  dengan `Curves.easeOut`.

```dart
Timer.periodic(const Duration(seconds: 4), (_) {
  setState(() => _showCountdown = !_showCountdown);
});
```

---

## 5. Pengaturan detail pendukung

### Running Text Bar
- Padding internal kini `EdgeInsets.symmetric(horizontal: 24, vertical: 8)`
  (vertikal diperkecil dari 16 → 8) dengan `SizedBox(height: 40)` konten.
- Badge "INFORMASI" = `StadiumBorder()` (pill murni), padding `12×6`.
- `ListView` marquee diberi `padding: EdgeInsets.symmetric(horizontal: 12)`.

### `_remainingFraction` (progress ring)
- `idx` = posisi shalat berikutnya; `total` = interval
  `item[idx].time − item[idx-1].time`.
- Khusus Fajr (`idx == 0`): `total = fajr_hari_ini − isha_kemarin`
  (`item[0].time − (item.last.time − 1 hari)`).
- `fraction = remaining/total` di-clamp `0..1`.

---

## 6. Matriks Shape Final (per komponen)

| Komponen | Shape final |
|---|---|
| Header card (nama & alamat) | `RoundedRectangleBorder(28)` |
| Kapsul jam (HH:mm:ss + tanggal) | **`ArchBorder`** (manual, dome di dalam bounds) |
| Info Masjid card (`BannerCarousel`) | `RoundedRectangleBorder(28)` |
| Badge header banner | `M3ShapeBorder(MaterialShapes.pill)` |
| Kas Summary card | `RoundedRectangleBorder(28)` |
| Kartu shalat **aktif** | `RoundedRectangleBorder(28)` + side primary 2px |
| Kartu shalat **non-aktif** | `M3ShapeBorder(MaterialShapes.slanted)` |
| Badge "INFORMASI" (running text) | `StadiumBorder()` |
| Running text bar | `RoundedRectangleBorder(28)` |
| Background blob | `MaterialBlobBackground` (tetap, blob 120–160, alpha 0.10–0.15) |

---

> Kembali ke [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [widget_mapping.md](widget_mapping.md)
