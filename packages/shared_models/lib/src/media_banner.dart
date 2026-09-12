import 'dart:convert';

class MediaBanner {
  final String id;
  final String header;
  final String title;
  final String content;
  final String footer;
  final bool isActive;
  final String? base64Image;

  const MediaBanner({
    required this.id,
    required this.header,
    required this.title,
    required this.content,
    this.footer = '',
    this.isActive = true,
    this.base64Image,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'header': header,
        'title': title,
        'content': content,
        'footer': footer,
        'isActive': isActive,
        'base64Image': base64Image,
      };

  factory MediaBanner.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final rawHeader = map['header'];
    final rawTitle = map['title'];
    final rawContent = map['content'];
    final rawSubtitle = map['subtitle'];
    final rawFooter = map['footer'];
    final rawActive = map['isActive'];
    final rawImage = map['base64Image'];
    return MediaBanner(
      id: rawId is String
          ? rawId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      header: rawHeader is String ? rawHeader : 'INFO MASJID',
      title: rawTitle is String ? rawTitle : '',
      // Backward compat: payload lama memakai kunci `subtitle`.
      content: rawContent is String
          ? rawContent
          : rawSubtitle is String
              ? rawSubtitle
              : '',
      footer: rawFooter is String ? rawFooter : '',
      isActive: rawActive is bool ? rawActive : true,
      base64Image: rawImage is String && rawImage.isNotEmpty ? rawImage : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaBanner.fromJson(String source) =>
      MediaBanner.fromMap(json.decode(source));

  /// Membuat salinan banner.
  ///
  /// Karena `copyWith` tidak bisa membedakan "tidak dikirim" dengan
  /// "dikirim null", gunakan [clearBase64Image] = `true` untuk menghapus
  /// gambar banner (mis. saat Remote menghapus lampiran gambar).
  MediaBanner copyWith({
    String? id,
    String? header,
    String? title,
    String? content,
    String? footer,
    bool? isActive,
    String? base64Image,
    bool clearBase64Image = false,
  }) {
    return MediaBanner(
      id: id ?? this.id,
      header: header ?? this.header,
      title: title ?? this.title,
      content: content ?? this.content,
      footer: footer ?? this.footer,
      isActive: isActive ?? this.isActive,
      base64Image: clearBase64Image ? null : (base64Image ?? this.base64Image),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaBanner &&
          other.id == id &&
          other.header == header &&
          other.title == title &&
          other.content == content &&
          other.footer == footer &&
          other.isActive == isActive &&
          other.base64Image == base64Image;

  @override
  int get hashCode =>
      Object.hash(id, header, title, content, footer, isActive, base64Image);

  @override
  String toString() =>
      'MediaBanner(id: $id, header: $header, title: $title, content: $content, '
      'footer: $footer, isActive: $isActive, base64Image: ${base64Image == null ? 'null' : '[set]'})';
}
