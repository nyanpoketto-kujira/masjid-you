import 'dart:convert';
import 'prayer_type.dart';

class IqamahDuration {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const IqamahDuration({
    this.fajr = 10,
    this.dhuhr = 10,
    this.asr = 10,
    this.maghrib = 7,
    this.isha = 10,
  });

  Map<String, dynamic> toMap() => {
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

  factory IqamahDuration.fromMap(Map<String, dynamic> map) {
    return IqamahDuration(
      fajr: map['fajr'] ?? 10,
      dhuhr: map['dhuhr'] ?? 10,
      asr: map['asr'] ?? 10,
      maghrib: map['maghrib'] ?? 7,
      isha: map['isha'] ?? 10,
    );
  }
}

class MosqueConfig {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int utcOffsetHours;
  final IqamahDuration iqamahDuration;
  final Map<PrayerType, int> prayerOffsets;

  /// Durasi fase "Menjelang Azan" (countdown sebelum azan berkumandang).
  final int preAdhanMinutes;

  /// Durasi fase "Azan" (azan berkumandang).
  final int adhanMinutes;

  /// Durasi fase "Jeda Ikamah" (himbauan merapatkan shaf sebelum shalat).
  final int preIqomahMinutes;

  /// Durasi fase "Shalat Berlangsung" (layar redup total).
  final int shalatMinutes;

  /// Durasi fase "Khutbah" (khusus Jumat, menggantikan Jeda Ikamah).
  final int khutbahMinutes;

  /// Nama Khatib shalat Jumat (ditampilkan di TV).
  final String fridayKhatib;

  /// Nama Muadzin shalat Jumat (ditampilkan di TV).
  final String fridayMuadzin;

  const MosqueConfig({
    this.name = 'Masjid Al-Ikhlas',
    this.address = 'Jl. Raya Masjid No. 123',
    this.latitude = -6.2088, // Jakarta Default
    this.longitude = 106.8456,
    this.utcOffsetHours = 7,
    this.iqamahDuration = const IqamahDuration(),
    this.prayerOffsets = const {},
    this.preAdhanMinutes = 15,
    this.adhanMinutes = 2,
    this.preIqomahMinutes = 1,
    this.shalatMinutes = 10,
    this.khutbahMinutes = 20,
    this.fridayKhatib = 'Ustadz Khatib',
    this.fridayMuadzin = 'Ustadz Bilal',
  });

  int offsetFor(PrayerType type) => prayerOffsets[type] ?? 0;

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'utcOffsetHours': utcOffsetHours,
        'iqamahDuration': iqamahDuration.toMap(),
        'prayerOffsets': {
          for (final type in kAllPrayerTypes) type.name: prayerOffsets[type] ?? 0,
        },
        'preAdhanMinutes': preAdhanMinutes,
        'adhanMinutes': adhanMinutes,
        'preIqomahMinutes': preIqomahMinutes,
        'shalatMinutes': shalatMinutes,
        'khutbahMinutes': khutbahMinutes,
        'fridayKhatib': fridayKhatib,
        'fridayMuadzin': fridayMuadzin,
      };

  factory MosqueConfig.fromMap(Map<String, dynamic> map) {
    Map<PrayerType, int> parseOffsets() {
      final result = <PrayerType, int>{};
      final raw = map['prayerOffsets'];
      if (raw is Map) {
        for (final entry in raw.entries) {
          final type = PrayerType.values
              .where((t) => t.name == entry.key)
              .firstOrNull;
          if (type != null) {
            result[type] = (entry.value as num?)?.toInt() ?? 0;
          }
        }
        return result;
      }
      final legacy = map['prayerCorrectionMinutes'];
      if (legacy is num) {
        for (final type in kAllPrayerTypes) {
          result[type] = legacy.toInt();
        }
      }
      return result;
    }

    return MosqueConfig(
      name: map['name'] ?? 'Masjid Al-Ikhlas',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? -6.2088,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 106.8456,
      utcOffsetHours: map['utcOffsetHours'] ?? 7,
      iqamahDuration: map['iqamahDuration'] != null
          ? IqamahDuration.fromMap(Map<String, dynamic>.from(map['iqamahDuration']))
          : const IqamahDuration(),
      prayerOffsets: parseOffsets(),
      preAdhanMinutes: (map['preAdhanMinutes'] as num?)?.toInt() ?? 15,
      adhanMinutes: (map['adhanMinutes'] as num?)?.toInt() ?? 2,
      preIqomahMinutes: (map['preIqomahMinutes'] as num?)?.toInt() ?? 1,
      shalatMinutes: (map['shalatMinutes'] as num?)?.toInt() ?? 10,
      khutbahMinutes: (map['khutbahMinutes'] as num?)?.toInt() ?? 20,
      fridayKhatib: (map['fridayKhatib'] as String?) ?? 'Ustadz Khatib',
      fridayMuadzin: (map['fridayMuadzin'] as String?) ?? 'Ustadz Bilal',
    );
  }

  String toJson() => json.encode(toMap());

  factory MosqueConfig.fromJson(String source) =>
      MosqueConfig.fromMap(json.decode(source));

  MosqueConfig copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? utcOffsetHours,
    IqamahDuration? iqamahDuration,
    Map<PrayerType, int>? prayerOffsets,
    int? preAdhanMinutes,
    int? adhanMinutes,
    int? preIqomahMinutes,
    int? shalatMinutes,
    int? khutbahMinutes,
    String? fridayKhatib,
    String? fridayMuadzin,
  }) {
    return MosqueConfig(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      utcOffsetHours: utcOffsetHours ?? this.utcOffsetHours,
      iqamahDuration: iqamahDuration ?? this.iqamahDuration,
      prayerOffsets: prayerOffsets ?? this.prayerOffsets,
      preAdhanMinutes: preAdhanMinutes ?? this.preAdhanMinutes,
      adhanMinutes: adhanMinutes ?? this.adhanMinutes,
      preIqomahMinutes: preIqomahMinutes ?? this.preIqomahMinutes,
      shalatMinutes: shalatMinutes ?? this.shalatMinutes,
      khutbahMinutes: khutbahMinutes ?? this.khutbahMinutes,
      fridayKhatib: fridayKhatib ?? this.fridayKhatib,
      fridayMuadzin: fridayMuadzin ?? this.fridayMuadzin,
    );
  }
}
