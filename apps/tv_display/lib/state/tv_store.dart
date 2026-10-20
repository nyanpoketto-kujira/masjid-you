import 'dart:convert';

import 'package:shared_models/shared_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal data resmi TV (trust source) di perangkat TV.
///
/// Setiap blok data disimpan sebagai JSON string dengan kunci berprefix `tv_`
/// sehingga mudah dibedakan dari preferensi lain. [load] mengembalikan `null`
/// selama `tv_hasData` belum pernah di-set — artinya TV belum pernah menerima
/// data resmi dari DKM, sehingga Remote masih boleh mengirim datanya sekali
/// (bootstrap).
class TvStore {
  static const String configKey = 'tv_config';
  static const String runningTextsKey = 'tv_runningTexts';
  static const String bannersKey = 'tv_banners';
  static const String kasKey = 'tv_kas';
  static const String hasDataKey = 'tv_hasData';

  /// Muat data tersimpan. `null` = TV belum pernah diisi.
  Future<StateSnapshot?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(hasDataKey) != true) return null;
      final configJson = prefs.getString(configKey);
      final configMap = configJson == null ? null : _decodeMap(configJson);
      return StateSnapshot(
        config: configMap == null
            ? const MosqueConfig()
            : MosqueConfig.fromMap(configMap),
        runningTexts: _decodeList(
          prefs.getString(runningTextsKey),
          RunningTextMessage.fromMap,
        ),
        banners: _decodeList(prefs.getString(bannersKey), MediaBanner.fromMap),
        kasTransactions: _decodeList(
          prefs.getString(kasKey),
          KasTransaction.fromMap,
        ),
        hasData: true,
      );
    } catch (_) {
      // Plugin tidak tersedia (mis. test) -> anggap belum ada data tersimpan.
      return null;
    }
  }

  Future<void> saveConfig(MosqueConfig config) =>
      _save(configKey, config.toMap());

  Future<void> saveRunningTexts(List<RunningTextMessage> messages) =>
      _save(runningTextsKey, [for (final m in messages) m.toMap()]);

  Future<void> saveBanners(List<MediaBanner> banners) =>
      _save(bannersKey, [for (final b in banners) b.toMap()]);

  Future<void> saveKas(List<KasTransaction> transactions) =>
      _save(kasKey, [for (final t in transactions) t.toMap()]);

  Future<void> _save(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(value));
      // Data resmi pernah diterima -> snapshot berikutnya tidak lagi "kosong".
      await prefs.setBool(hasDataKey, true);
    } catch (_) {
      // Plugin tidak tersedia (mis. test) -> perubahan hanya di memori.
    }
  }

  /// `null` bila JSON rusak / bukan objek (blok ini jatuh ke default).
  static Map<String, dynamic>? _decodeMap(String source) {
    try {
      final decoded = json.decode(source);
      if (decoded is! Map) return null;
      return {for (final entry in decoded.entries) '${entry.key}': entry.value};
    } catch (_) {
      // JSON rusak pada satu blok tidak boleh membatalkan blok lain.
      return null;
    }
  }

  static List<T> _decodeList<T>(
    String? source,
    T Function(Map<String, dynamic> map) fromMap,
  ) {
    if (source == null) return const [];
    try {
      final decoded = json.decode(source);
      if (decoded is! List) return const [];
      final result = <T>[];
      for (final entry in decoded) {
        if (entry is Map) {
          result.add(fromMap(
            {for (final e in entry.entries) '${e.key}': e.value},
          ));
        }
      }
      return result;
    } catch (_) {
      return const [];
    }
  }
}
