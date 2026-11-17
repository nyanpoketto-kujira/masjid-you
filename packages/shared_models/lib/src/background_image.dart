import 'dart:convert';

/// Satu gambar latar TV yang dikelola dari Remote (ADR-031).
///
/// Sejajar dengan [SpecialImage] (gambar khusus slot samping), tetapi
/// gambar ini menjadi **latar penuh layar TV** dan ditampilkan sebagai
/// slideshow bergilir dengan crossfade. Urutan slideshow mengikuti urutan
/// daftar di Remote; gambar dengan [isActive] = `false` dilewati.
///
/// [base64Image] selalu gambar ASLI dari HP (tanpa prefix `data:`) —
/// kompresi hanya terjadi sesaat di jalur kirim Bluetooth, tidak pernah
/// mengubah data yang tersimpan di HP maupun di TV hasil jalur Wi-Fi.
class BackgroundImage {
  final String id;

  /// Isi gambar ter-encode base64 (tanpa prefix `data:`).
  final String base64Image;

  final bool isActive;

  const BackgroundImage({
    required this.id,
    required this.base64Image,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'base64Image': base64Image,
        'isActive': isActive,
      };

  /// Parsing toleran seperti model lain: field hilang / tipe salah jatuh
  /// ke default, tidak pernah melempar error.
  factory BackgroundImage.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final rawImage = map['base64Image'];
    final rawActive = map['isActive'];
    return BackgroundImage(
      id: rawId is String
          ? rawId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      base64Image: rawImage is String ? rawImage : '',
      isActive: rawActive is bool ? rawActive : true,
    );
  }

  String toJson() => json.encode(toMap());

  factory BackgroundImage.fromJson(String source) =>
      BackgroundImage.fromMap(json.decode(source));

  BackgroundImage copyWith({
    String? id,
    String? base64Image,
    bool? isActive,
  }) {
    return BackgroundImage(
      id: id ?? this.id,
      base64Image: base64Image ?? this.base64Image,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackgroundImage &&
          other.id == id &&
          other.base64Image == base64Image &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, base64Image, isActive);

  @override
  String toString() => 'BackgroundImage(id: $id, '
      'base64Image: ${base64Image.isEmpty ? 'null' : '[set]'}, '
      'isActive: $isActive)';
}
