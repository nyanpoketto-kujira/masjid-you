import 'dart:convert';

class RunningTextMessage {
  final String id;
  final String content;
  final bool isActive;
  final String category; // e.g. 'Umum', 'Kas', 'Kajian'

  const RunningTextMessage({
    required this.id,
    required this.content,
    this.isActive = true,
    this.category = 'Umum',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'isActive': isActive,
        'category': category,
      };

  factory RunningTextMessage.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final rawContent = map['content'];
    final rawCategory = map['category'];
    final rawActive = map['isActive'];
    return RunningTextMessage(
      // `id` wajib String: bila tidak ada di payload (atau tipenya salah),
      // id baru dibuat agar pesan tetap punya identitas stabil di UI.
      id: rawId is String
          ? rawId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      content: rawContent is String ? rawContent : '',
      isActive: rawActive is bool ? rawActive : true,
      category: rawCategory is String ? rawCategory : 'Umum',
    );
  }

  String toJson() => json.encode(toMap());

  factory RunningTextMessage.fromJson(String source) =>
      RunningTextMessage.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunningTextMessage &&
          other.id == id &&
          other.content == content &&
          other.isActive == isActive &&
          other.category == category;

  @override
  int get hashCode => Object.hash(id, content, isActive, category);

  @override
  String toString() =>
      'RunningTextMessage(id: $id, content: $content, isActive: $isActive, category: $category)';
}
