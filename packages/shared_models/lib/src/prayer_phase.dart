import 'mosque_config.dart';

/// Fase siklus waktu shalat di layar TV.
///
/// Urutan otomatis: `normal` -> `preAdhan` -> `adhan` -> `preIqomah` -> `shalat` -> `normal`.
/// Nama enum dikirim sebagai string melalui protokol WS (`SyncAction.stateUpdate`),
/// sehingga perubahan nama harus disinkronkan antara Remote dan TV.
enum PrayerPhase {
  normal,
  preAdhan,
  adhan,
  khutbah,
  preIqomah,
  shalat;

  /// Parsing nama fase dari protokol WS (fallback `normal` bila tidak dikenal).
  static PrayerPhase fromName(String? name) => PrayerPhase.values.firstWhere(
        (p) => p.name == name,
        orElse: () => PrayerPhase.normal,
      );
}

extension PrayerPhaseX on PrayerPhase {
  /// Label Indonesia untuk ditampilkan di Remote / overlay TV.
  String get label {
    switch (this) {
      case PrayerPhase.normal:
        return 'Normal (Standby)';
      case PrayerPhase.preAdhan:
        return 'Menjelang Azan';
      case PrayerPhase.adhan:
        return 'Azan';
      case PrayerPhase.khutbah:
        return 'Khutbah';
      case PrayerPhase.preIqomah:
        return 'Jeda Ikamah';
      case PrayerPhase.shalat:
        return 'Shalat Berlangsung';
    }
  }

  /// Durasi konfigurasi untuk fase ini (dari Remote, menit).
  Duration durationFor(MosqueConfig config) {
    switch (this) {
      case PrayerPhase.normal:
        return Duration.zero;
      case PrayerPhase.preAdhan:
        return Duration(minutes: config.preAdhanMinutes);
      case PrayerPhase.adhan:
        return Duration(minutes: config.adhanMinutes);
      case PrayerPhase.khutbah:
        return Duration(minutes: config.khutbahMinutes);
      case PrayerPhase.preIqomah:
        return Duration(minutes: config.preIqomahMinutes);
      case PrayerPhase.shalat:
        return Duration(minutes: config.shalatMinutes);
    }
  }
}
