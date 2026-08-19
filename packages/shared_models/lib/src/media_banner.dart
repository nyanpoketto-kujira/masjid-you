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
    return MediaBanner(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      header: map['header'] ?? 'INFO MASJID',
      title: map['title'] ?? '',
      content: map['content'] ?? map['subtitle'] ?? '',
      footer: map['footer'] ?? '',
      isActive: map['isActive'] ?? true,
      base64Image: map['base64Image'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaBanner.fromJson(String source) =>
      MediaBanner.fromMap(json.decode(source));

  MediaBanner copyWith({
    String? id,
    String? header,
    String? title,
    String? content,
    String? footer,
    bool? isActive,
    String? base64Image,
  }) {
    return MediaBanner(
      id: id ?? this.id,
      header: header ?? this.header,
      title: title ?? this.title,
      content: content ?? this.content,
      footer: footer ?? this.footer,
      isActive: isActive ?? this.isActive,
      base64Image: base64Image ?? this.base64Image,
    );
  }
}
