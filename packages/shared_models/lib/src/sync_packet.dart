import 'dart:convert';

enum SyncAction {
  updateConfig,
  updateRunningText,
  updateBanners,
  updateKas,
  triggerBeep,
  getInitialState,
  stateUpdate,
  skipAdhan,
  startIqomah,
  startShalat,
  finishShalat,
  forcePhase,
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
    final actionName = map['action'] is String
        ? map['action'] as String
        : '';
    final action = SyncAction.values.firstWhere(
      (e) => e.name == actionName,
      orElse: () => SyncAction.stateUpdate,
    );
    return SyncPacket(
      action: action,
      // Payload wajib berupa Map. Bila payload hilang / bukan Map (mis. hasil
      // JSON `[]` atau `"text"`), paket tetap valid dengan payload kosong
      // supaya protokol WS tidak pernah melempar error saat decoding frame.
      payload: _parsePayload(map['payload']),
    );
  }

  static Map<String, dynamic> _parsePayload(Object? raw) {
    if (raw is Map) {
      return {
        // Kunci dipaksa String: melindungi dari payload dengan kunci non-String
        // (mis. hasil decode JSON dari klien lama) tanpa melempar TypeError.
        for (final entry in raw.entries) '${entry.key}': entry.value,
      };
    }
    return const {};
  }

  String toJson() => json.encode(toMap());

  factory SyncPacket.fromJson(String source) =>
      SyncPacket.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncPacket && other.action == action && _mapsEqual(other.payload, payload);

  static bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(action, Object.hashAll(payload.keys.toList()..sort()));

  @override
  String toString() => 'SyncPacket(action: ${action.name}, payload: $payload)';
}
