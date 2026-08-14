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
    return RunningTextMessage(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: map['content'] ?? '',
      isActive: map['isActive'] ?? true,
      category: map['category'] ?? 'Umum',
    );
  }

  String toJson() => json.encode(toMap());

  factory RunningTextMessage.fromJson(String source) =>
      RunningTextMessage.fromMap(json.decode(source));
}
