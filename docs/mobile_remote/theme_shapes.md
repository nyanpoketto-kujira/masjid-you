# mobile_remote — Tema & Shape (theme_shapes.md)

> Dokumen arsitektur untuk **perubahan tema terbaru** di `apps/mobile_remote`:
> **revert** tema M3 Expressive (`MaterialShapes.puffy`/`pill` — tampak seperti
> clover) kembali ke **shape Material 3 standar** (square/rounded).
>
> Setiap bagian ditulis dengan pola **Apa yang diubah → Kenapa keputusan
> diambil → Bagaimana cara kerjanya**.

**Navigasi:** [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [tab_mapping.md](tab_mapping.md) · [tv_display/m3_shapes.md](../tv_display/m3_shapes.md)

---

## Ringkasan Perubahan (terbaru)

| No | Perubahan | File |
|---|---|---|
| 1 | `cardTheme` dari `M3ShapeBorder(MaterialShapes.puffy)` (clover) → `RoundedRectangleBorder(borderRadius: 16)` | `main.dart` (`_buildTheme`) |
| 2 | `dialogTheme`/`bottomSheetTheme` dari `puffy` → `RoundedRectangleBorder(borderRadius: 28)` | `main.dart` (`_buildTheme`) |
| 3 | `navigationBarTheme.indicatorShape`, tombol, chip dari `M3ShapeBorder(MaterialShapes.pill)` → `StadiumBorder()` standar | `main.dart` (`_buildTheme`) |
| 4 | File `lib/m3_shape_border.dart` **dihapus**; import & dependency `material_new_shapes` dihapus dari pubspec | `main.dart`, `pubspec.yaml` |
| 5 | `M3Pressable` (feedback tekan spring) **tetap dipakai** — bukan shape, hanya skala animasi | `main.dart` (kelas lokal) |

---

## 1. Apa yang diubah

### Theme `_buildTheme` — shape kembali ke Material 3 standar

```dart
cardTheme: CardThemeData(
  elevation: 1,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  clipBehavior: Clip.antiAlias,
),
navigationBarTheme: NavigationBarThemeData(
  indicatorShape: StadiumBorder(),   // pill standar M3
  ...
),
chipTheme: ChipThemeData(shape: const StadiumBorder(), ...),
filledButtonTheme / outlinedButtonTheme / textButtonTheme:
  shape: const StadiumBorder(),
dialogTheme / bottomSheetTheme:
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
```

### Pembongkaran dependensi

- `lib/m3_shape_border.dart` (wrapper `M3ShapeBorder`) **dihapus** dari mobile_remote.
- Import `package:material_new_shapes/material_new_shapes.dart` dan `m3_shape_border.dart` **dihapus** dari `main.dart`.
- Dependency `material_new_shapes: ^1.0.0` **dihapus** dari `apps/mobile_remote/pubspec.yaml`.
- `M3Pressable` tetap ada — kelas ini didefinisikan lokal di `main.dart` dan hanya memakai Flutter bawaan (`Listener`, `AnimatedBuilder`, `Transform.scale`), bukan `material_new_shapes`.

> Catatan: `material_new_shapes` **tetap** dipakai di `tv_display` (kartu shalat
> non-aktif `slanted`, badge pill, `MaterialBlobBackground`) — lihat
> [tv_display/m3_shapes.md](../tv_display/m3_shapes.md).

---

## 2. Kenapa keputusan ini diambil

- **Feedback user**: seluruh UI admin/remote tampak berubah menjadi bentuk
  **clover** (4 lobus). Penyebabnya `MaterialShapes.puffy` yang dipakai untuk
  semua kartu, dialog, dan bottom sheet — bentuk organik M3 Expressive ini
  secara visual menyerupai daun semanggi dan tidak diinginkan untuk UI
  admin/form yang bersifat informasi-densitas tinggi.
- **Keterbacaan & kebersihan**: shape square/rounded standar Material lebih
  netral, tidak merebut perhatian dari konten (form, daftar kas, banner, dll).
- **Menghindari kebingungan bentuk**: `puffy` di kartu besar terasa "aneh"
  untuk aplikasi pengaturan; kembali ke `RoundedRectangleBorder(16)` konsisten
  dengan `OutlineInputBorder(16)` yang sudah dipakai input field.
- **Prinsip "square biasa"**: keputusan eksplisit dari user untuk kembali ke
  bentuk default Material 3 tanpa harus menghapus semua sentuhan ekspresif —
  `M3Pressable` (spring saat tekan) tetap dipertahankan karena itu bukan shape.

---

## 3. Bagaimana cara kerjanya

- Semua shape kini memakai widget `ShapeBorder` bawaan Flutter:
  - `RoundedRectangleBorder(borderRadius: 16)` untuk kartu — radius sama dengan
    input field agar tema konsisten.
  - `StadiumBorder()` untuk tombol, chip, dan indikator NavigationBar — bentuk
    pill standar M3 (bukan "clover").
  - `RoundedRectangleBorder(borderRadius: 28)` untuk dialog & bottom sheet —
    radius default M3.
- Karena `M3ShapeBorder` dan `MaterialShapes.*` tidak lagi direferensikan di
  mobile_remote, import & dependency dihapus sehingga tree-shaking lebih bersih
  dan tidak ada kode mati (`dead code`).
- `M3Pressable` tetap membungkus tombol-tombol utama (`_buildConfigTab`,
  `_buildTestTab`, dll.) — bekerja independen dari bentuk tombol, hanya
  menganimasikan skala 0.96 saat tekan lalu spring kembali.

---

## 4. Matriks Shape Final (mobile_remote)

| Komponen | Shape |
|---|---|
| Card | `RoundedRectangleBorder(16)` |
| Dialog / Bottom Sheet | `RoundedRectangleBorder(28)` |
| Tombol (Filled/Outlined/Text) | `StadiumBorder()` |
| Chip | `StadiumBorder()` |
| NavigationBar indicator | `StadiumBorder()` |
| Input field | `OutlineInputBorder(16)` (tetap) |

---

> Kembali ke [MAP.md](../MAP.md) · [DECISIONS.md](../DECISIONS.md) · [tab_mapping.md](tab_mapping.md)
