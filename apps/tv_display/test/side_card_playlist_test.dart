import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/state/side_card_playlist.dart';

/// Tes susunan rotasi slot samping TV:
/// `[Kas] -> [Petugas Jumat] -> [Gambar 1..n] -> ulang`.
void main() {
  // 13 Agustus 2026 = Kamis, 14 Agustus 2026 = Jumat.
  final thursday = DateTime(2026, 8, 13);
  final friday = DateTime(2026, 8, 14);

  const imgA = SpecialImage(id: 'a', base64Image: 'AA==', caption: 'A');
  const imgB = SpecialImage(id: 'b', base64Image: 'BB==', caption: 'B');
  const imgOff = SpecialImage(id: 'off', base64Image: 'CC==', isActive: false);
  const imgEmpty = SpecialImage(id: 'empty', base64Image: '');

  List<String> keysOf(List<SideCardItem> items) =>
      items.map((i) => i.key).toList();

  group('buildSideCardPlaylist', () {
    test('hari biasa, default: hanya kas', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(),
        date: thursday,
        images: const [],
      );
      expect(keysOf(playlist), equals(['kas-summary']));
    });

    test('hari Jumat, default: kas lalu petugas Jumat', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(),
        date: friday,
        images: const [],
      );
      expect(keysOf(playlist), equals(['kas-summary', 'friday-staff']));
    });

    test('urutan penuh: kas -> petugas Jumat -> gambar sesuai urutan daftar',
        () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(),
        date: friday,
        images: const [imgB, imgA],
      );
      expect(
        keysOf(playlist),
        equals([
          'kas-summary',
          'friday-staff',
          'special-image-b',
          'special-image-a',
        ]),
      );
    });

    test('toggle kas mati: kas dilewati, sisanya tetap berurutan', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(showKas: false),
        date: friday,
        images: const [imgA],
      );
      expect(keysOf(playlist), equals(['friday-staff', 'special-image-a']));
    });

    test('musholla (Jumatan mati) di hari Jumat: tidak ada kartu Jumat', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(hasFridayPrayer: false),
        date: friday,
        images: const [imgA],
      );
      expect(keysOf(playlist), equals(['kas-summary', 'special-image-a']));
    });

    test('kartu Jumat tidak muncul di hari biasa walau Jumatan aktif', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(),
        date: thursday,
        images: const [imgA],
      );
      expect(keysOf(playlist), equals(['kas-summary', 'special-image-a']));
    });

    test('gambar non-aktif dan gambar kosong dilewati', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(),
        date: thursday,
        images: const [imgOff, imgEmpty, imgA],
      );
      expect(keysOf(playlist), equals(['kas-summary', 'special-image-a']));
    });

    test('semua mati & tanpa gambar: playlist kosong (placeholder)', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(showKas: false, hasFridayPrayer: false),
        date: friday,
        images: const [imgOff],
      );
      expect(playlist, isEmpty);
    });

    test('item gambar membawa objek SpecialImage yang benar', () {
      final playlist = buildSideCardPlaylist(
        config: const MosqueConfig(showKas: false),
        date: thursday,
        images: const [imgA],
      );
      expect(playlist.single.kind, equals(SideCardKind.specialImage));
      expect(playlist.single.image, equals(imgA));
    });
  });
}
