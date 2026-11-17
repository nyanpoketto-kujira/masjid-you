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
  static const String sideImagesKey = 'tv_sideImages';
  static const String backgroundImagesKey = 'tv_backgroundImages';
  static const String hasDataKey = 'tv_hasData';
  static const String mutedKey = 'tv_muted';
  static const String standbyKey = 'tv_standby';

  /// Flag permanen: jendela Mode Pairing otomatis (instalasi baru) sudah
  /// pernah dijalankan. Sekali terpasang, TV tidak pernah membuka Mode
  /// Pairing sendiri lagi — hanya manual dari menu admin (ADR-029).
  static const String pairingIntroDoneKey = 'tv_btPairingIntroDone';

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
        // Data lama belum punya blok ini -> daftar kosong.
        sideImages: _decodeList(
          prefs.getString(sideImagesKey),
          SpecialImage.fromMap,
        ),
        // Data lama belum punya blok ini -> daftar kosong.
        backgroundImages: _decodeList(
          prefs.getString(backgroundImagesKey),
          BackgroundImage.fromMap,
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

  Future<void> saveSideImages(List<SpecialImage> images) =>
      _save(sideImagesKey, [for (final i in images) i.toMap()]);

  Future<void> saveBackgroundImages(List<BackgroundImage> images) =>
      _save(backgroundImagesKey, [for (final i in images) i.toMap()]);

  /// Status kontrol tampilan dari Remote (senyap & standby). Disimpan
  /// sebagai bool terpisah dan TIDAK menandai `tv_hasData` — ini preferensi
  /// perangkat, bukan data resmi DKM.
  Future<({bool muted, bool standby})> loadDisplayState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (
        muted: prefs.getBool(mutedKey) ?? false,
        standby: prefs.getBool(standbyKey) ?? false,
      );
    } catch (_) {
      return (muted: false, standby: false);
    }
  }

  Future<void> saveMuted(bool muted) => _saveBool(mutedKey, muted);

  Future<void> saveStandby(bool standby) => _saveBool(standbyKey, standby);

  /// `true` bila jendela Mode Pairing otomatis instalasi baru sudah pernah
  /// dijalankan (ADR-029). Bukan data resmi: tidak menandai `tv_hasData`.
  Future<bool> loadPairingIntroDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(pairingIntroDoneKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> savePairingIntroDone() =>
      _saveBool(pairingIntroDoneKey, true);

  Future<void> _saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // Plugin tidak tersedia (mis. test) -> perubahan hanya di memori.
    }
  }

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
