import 'dart:convert';

/// Satu kartu gambar khusus untuk slot samping TV.
///
/// Berbeda dari MediaBanner (carousel Info Masjid di sisi kiri), gambar
/// khusus ini tampil **penuh satu kartu** di slot kanan TV, bergantian
/// dengan kartu Kas dan kartu Petugas Jumat:
/// `[Kas] -> [Petugas Jumat] -> [Gambar 1] -> ... -> [Gambar ke-n] -> ulang`.
///
/// Urutan tampil mengikuti urutan daftar di Remote (tidak ada field urutan
/// terpisah). Gambar dengan [isActive] = `false` dilewati dari rotasi.
class SpecialImage {
  final String id;

  /// Keterangan gambar (boleh kosong) — tampil sebagai caption di TV.
  final String caption;

  /// Isi gambar ter-encode base64 (tanpa prefix `data:`).
  final String base64Image;

  final bool isActive;

  const SpecialImage({
    required this.id,
    required this.base64Image,
    this.caption = '',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'caption': caption,
        'base64Image': base64Image,
        'isActive': isActive,
      };

  /// Parsing toleran seperti model lain: field hilang / tipe salah jatuh ke
  /// default, tidak pernah melempar error.
  factory SpecialImage.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final rawCaption = map['caption'];
    final rawImage = map['base64Image'];
    final rawActive = map['isActive'];
    return SpecialImage(
      id: rawId is String
          ? rawId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      caption: rawCaption is String ? rawCaption : '',
      base64Image: rawImage is String ? rawImage : '',
      isActive: rawActive is bool ? rawActive : true,
    );
  }

  String toJson() => json.encode(toMap());

  factory SpecialImage.fromJson(String source) =>
      SpecialImage.fromMap(json.decode(source));

  SpecialImage copyWith({
    String? id,
    String? caption,
    String? base64Image,
    bool? isActive,
  }) {
    return SpecialImage(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      base64Image: base64Image ?? this.base64Image,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecialImage &&
          other.id == id &&
          other.caption == caption &&
          other.base64Image == base64Image &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, caption, base64Image, isActive);

  @override
  String toString() => 'SpecialImage(id: $id, caption: $caption, '
      'base64Image: ${base64Image.isEmpty ? 'null' : '[set]'}, '
      'isActive: $isActive)';
}
