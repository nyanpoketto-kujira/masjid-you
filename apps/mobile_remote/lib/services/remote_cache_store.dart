import 'dart:convert';

import 'package:shared_models/shared_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache lokal snapshot TV di perangkat Remote.
///
/// Dipakai sebagai nilai awal form saat aplikasi dibuka (sebelum tersambung),
/// sehingga settingan DKM tidak hilang ketika TV sedang tidak dijangkau.
/// Hanya snapshot berisi data resmi ([StateSnapshot.hasData]) yang di-cache —
/// data contoh bawaan TV tidak pernah menimpa cache.
class RemoteCacheStore {
  static const String snapshotKey = 'remote_cache_snapshot';

  /// Muat cache. `null` bila belum ada / isinya bukan data resmi.
  Future<StateSnapshot?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(snapshotKey);
      if (raw == null) return null;
      final decoded = json.decode(raw);
      if (decoded is! Map) return null;
      final snapshot = StateSnapshot.fromMap({
        for (final entry in decoded.entries) '${entry.key}': entry.value,
      });
      return snapshot.hasData ? snapshot : null;
    } catch (_) {
      // Plugin tidak tersedia (mis. test) atau JSON rusak -> pakai default.
      return null;
    }
  }

  Future<void> save(StateSnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(snapshotKey, json.encode(snapshot.toMap()));
    } catch (_) {
      // Plugin tidak tersedia (mis. test) -> cache hanya di memori.
    }
  }
}
