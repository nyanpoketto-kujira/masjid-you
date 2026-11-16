import 'package:shared_models/shared_models.dart';

/// Jenis kartu yang bisa tampil di slot samping (kanan) TV.
enum SideCardKind {
  /// Ringkasan kas masjid.
  kas,

  /// Petugas Jumat (khatib & muadzin) — hanya hari Jumat & ada Jumatan.
  fridayStaff,

  /// Satu kartu gambar khusus.
  specialImage,
}

/// Satu entri playlist rotasi slot samping.
///
/// Untuk [SideCardKind.specialImage], [image] berisi gambarnya; untuk jenis
/// lain [image] selalu `null`.
class SideCardItem {
  final SideCardKind kind;
  final SpecialImage? image;

  const SideCardItem(this.kind, {this.image});

  /// Kunci stabil untuk `AnimatedSwitcher` & test: setiap kartu dalam satu
  /// putaran rotasi punya kunci unik.
  String get key => switch (kind) {
        SideCardKind.kas => 'kas-summary',
        SideCardKind.fridayStaff => 'friday-staff',
        SideCardKind.specialImage => 'special-image-${image?.id ?? ''}',
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideCardItem && other.kind == kind && other.image == image;

  @override
  int get hashCode => Object.hash(kind, image);

  @override
  String toString() => 'SideCardItem($key)';
}

/// Susun urutan rotasi slot samping TV untuk tanggal [date]:
///
/// `[Kas] -> [Petugas Jumat] -> [Gambar 1] -> ... -> [Gambar ke-n] -> ulang`
///
/// Aturan:
/// - Kas hanya masuk bila [MosqueConfig.showKas] aktif.
/// - Petugas Jumat hanya masuk bila hari Jumat **dan**
///   [MosqueConfig.hasFridayPrayer] aktif (musholla tanpa Jumatan tidak
///   pernah menampilkannya).
/// - Gambar khusus: hanya yang `isActive` dan punya isi gambar, mengikuti
///   urutan daftar [images].
///
/// Hasil boleh kosong (semua mati / tidak ada gambar) — pemanggil
/// menampilkan kartu placeholder dalam kasus itu.
List<SideCardItem> buildSideCardPlaylist({
  required MosqueConfig config,
  required DateTime date,
  required List<SpecialImage> images,
}) {
  final playlist = <SideCardItem>[];
  if (config.showKas) {
    playlist.add(const SideCardItem(SideCardKind.kas));
  }
  if (config.hasFridayPrayer && date.weekday == DateTime.friday) {
    playlist.add(const SideCardItem(SideCardKind.fridayStaff));
  }
  for (final image in images) {
    if (image.isActive && image.base64Image.isNotEmpty) {
      playlist.add(SideCardItem(SideCardKind.specialImage, image: image));
    }
  }
  return playlist;
}
