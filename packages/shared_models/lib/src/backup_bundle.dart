import 'state_snapshot.dart';

/// Menyalin [raw] menjadi map berkunci String tanpa `as` cast mentah.
///
/// Kunci dipaksa String sehingga payload JSON dari versi lama (mis. kunci
/// angka) tidak pernah melempar `TypeError` saat decoding.
Map<String, dynamic> _stringKeyed(Map raw) => {
      for (final entry in raw.entries) '${entry.key}': entry.value,
    };

/// Bundle export/import backup keadaan masjid.
///
/// Membawa metadata export (versi format, waktu export, nama masjid) bersama
/// snapshot keadaan lengkap, sehingga file backup bisa dipakai untuk import
/// dengan validasi versi. Import dari file yang lebih baru / rusak ditolak
/// lewat [FormatException], tidak pernah diam-diam mengembalikan data kosong.
class BackupBundle {
  /// Versi format bundle yang didukung saat ini.
  static const int currentFormatVersion = 1;

  final int formatVersion;
  final DateTime exportedAt;

  /// Nama masjid, boleh kosong bila belum diisi.
  final String mosqueName;

  final StateSnapshot snapshot;

  const BackupBundle({
    this.formatVersion = currentFormatVersion,
    required this.exportedAt,
    required this.mosqueName,
    required this.snapshot,
  });

  Map<String, dynamic> toMap() => {
        'formatVersion': formatVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'mosqueName': mosqueName,
        'snapshot': snapshot.toMap(),
      };

  /// Membaca bundle dari payload. Data yang tidak valid melempar
  /// [FormatException] dengan pesan jelas:
  /// - `formatVersion` hilang atau bukan int
  /// - `formatVersion` lebih besar dari versi yang didukung
  /// - `snapshot` hilang atau bukan Map
  factory BackupBundle.fromMap(Map<String, dynamic> map) {
    final raw = _stringKeyed(map);

    final rawVersion = raw['formatVersion'];
    if (rawVersion is! int) {
      throw FormatException(
        'BackupBundle: formatVersion hilang atau bukan int (got: '
        '$rawVersion)',
      );
    }
    if (rawVersion > currentFormatVersion) {
      throw FormatException(
        'BackupBundle: formatVersion file ($rawVersion) lebih besar dari '
        'versi yang didukung ($currentFormatVersion)',
      );
    }

    final rawExportedAt = raw['exportedAt'];
    final exportedAt = rawExportedAt is String
        ? (DateTime.tryParse(rawExportedAt) ??
            DateTime.fromMillisecondsSinceEpoch(0))
        : DateTime.fromMillisecondsSinceEpoch(0);

    final rawSnapshot = raw['snapshot'];
    if (rawSnapshot is! Map) {
      throw FormatException(
        'BackupBundle: snapshot hilang atau bukan Map (got: $rawSnapshot)',
      );
    }

    return BackupBundle(
      formatVersion: rawVersion,
      exportedAt: exportedAt,
      mosqueName: raw['mosqueName'] is String ? raw['mosqueName'] : '',
      snapshot: StateSnapshot.fromMap(_stringKeyed(rawSnapshot)),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupBundle &&
          other.formatVersion == formatVersion &&
          other.exportedAt == exportedAt &&
          other.mosqueName == mosqueName &&
          other.snapshot == snapshot;

  @override
  int get hashCode =>
      Object.hash(formatVersion, exportedAt, mosqueName, snapshot);

  @override
  String toString() =>
      'BackupBundle(formatVersion: $formatVersion, exportedAt: $exportedAt, '
      'mosqueName: $mosqueName, snapshot: $snapshot)';
}