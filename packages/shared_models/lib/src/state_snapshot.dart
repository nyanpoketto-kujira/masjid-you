import 'kas_transaction.dart';
import 'media_banner.dart';
import 'mosque_config.dart';
import 'running_text.dart';

/// Menyalin [raw] menjadi map berkunci String tanpa `as` cast mentah.
///
/// Kunci dipaksa String sehingga payload JSON dari versi lama (mis. kunci
/// angka) tidak pernah melempar `TypeError` saat decoding.
Map<String, dynamic> _stringKeyed(Map raw) => {
      for (final entry in raw.entries) '${entry.key}': entry.value,
    };

/// Parsing daftar model dari payload yang tidak dipercaya.
///
/// Entri yang bukan Map dilewati (bukan error): satu item rusak tidak boleh
/// membuat seluruh snapshot gagal dipakai.
List<T> _parseList<T>(
  Object? raw,
  T Function(Map<String, dynamic> map) fromMap,
) {
  if (raw is! List) return const [];
  final result = <T>[];
  for (final entry in raw) {
    if (entry is Map) {
      result.add(fromMap(_stringKeyed(entry)));
    }
  }
  return result;
}

/// Snapshot keadaan lengkap TV (`SyncAction.stateSnapshot`, TV -> Remote).
///
/// Membawa sekaligus seluruh data yang dimiliki TV — konfigurasi masjid,
/// teks berjalan, banner informasi, dan transaksi kas — sehingga Remote bisa
/// memakai TV sebagai **trust source** (TV menimpa Remote, bukan sebaliknya).
///
/// [hasData] menandai apakah TV sudah pernah diisi data resmi (hasil persist
/// lokal atau kiriman DKM). Bila `false`, TV masih memakai data contoh bawaan
/// sehingga Remote boleh mengirim datanya sekali sebagai bootstrap.
class StateSnapshot {
  final MosqueConfig config;
  final List<RunningTextMessage> runningTexts;
  final List<MediaBanner> banners;
  final List<KasTransaction> kasTransactions;
  final bool hasData;

  const StateSnapshot({
    this.config = const MosqueConfig(),
    this.runningTexts = const [],
    this.banners = const [],
    this.kasTransactions = const [],
    this.hasData = false,
  });

  Map<String, dynamic> toMap() => {
        'config': config.toMap(),
        'runningTexts': [for (final message in runningTexts) message.toMap()],
        'banners': [for (final banner in banners) banner.toMap()],
        'kasTransactions': [
          for (final transaction in kasTransactions) transaction.toMap(),
        ],
        'hasData': hasData,
      };

  /// Membaca snapshot dari payload paket. Payload rusak / kosong tetap
  /// menghasilkan snapshot valid (default + daftar kosong, [hasData] `false`).
  factory StateSnapshot.fromMap(Map<String, dynamic> map) {
    final rawConfig = map['config'];
    final rawHasData = map['hasData'];
    return StateSnapshot(
      config: rawConfig is Map
          ? MosqueConfig.fromMap(_stringKeyed(rawConfig))
          : const MosqueConfig(),
      runningTexts:
          _parseList(map['runningTexts'], RunningTextMessage.fromMap),
      banners: _parseList(map['banners'], MediaBanner.fromMap),
      kasTransactions:
          _parseList(map['kasTransactions'], KasTransaction.fromMap),
      hasData: rawHasData is bool ? rawHasData : false,
    );
  }

  static bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateSnapshot &&
          other.config == config &&
          other.hasData == hasData &&
          _listsEqual(other.runningTexts, runningTexts) &&
          _listsEqual(other.banners, banners) &&
          _listsEqual(other.kasTransactions, kasTransactions);

  @override
  int get hashCode => Object.hash(
        config,
        hasData,
        Object.hashAll(runningTexts),
        Object.hashAll(banners),
        Object.hashAll(kasTransactions),
      );

  @override
  String toString() =>
      'StateSnapshot(hasData: $hasData, config: $config, '
      'runningTexts: ${runningTexts.length}, banners: ${banners.length}, '
      'kasTransactions: ${kasTransactions.length})';
}