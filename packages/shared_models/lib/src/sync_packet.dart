import 'dart:convert';

enum SyncAction {
  updateConfig,
  updateRunningText,
  updateBanners,
  updateKas,
  triggerBeep,
  getInitialState,
  stateUpdate,
}

class SyncPacket {
  final SyncAction action;
  final Map<String, dynamic> payload;

  const SyncPacket({
    required this.action,
    required this.payload,
  });

  Map<String, dynamic> toMap() => {
        'action': action.name,
        'payload': payload,
      };

  factory SyncPacket.fromMap(Map<String, dynamic> map) {
    final actionName = map['action'] as String? ?? '';
    final action = SyncAction.values.firstWhere(
      (e) => e.name == actionName,
      orElse: () => SyncAction.stateUpdate,
    );
    return SyncPacket(
      action: action,
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncPacket.fromJson(String source) =>
      SyncPacket.fromMap(json.decode(source));
}
