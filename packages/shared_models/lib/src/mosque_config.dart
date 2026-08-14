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

  const MosqueConfig({
    this.name = 'Masjid Al-Ikhlas',
    this.address = 'Jl. Raya Masjid No. 123',
    this.latitude = -6.2088, // Jakarta Default
    this.longitude = 106.8456,
    this.utcOffsetHours = 7,
    this.iqamahDuration = const IqamahDuration(),
    this.prayerOffsets = const {},
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
  }) {
    return MosqueConfig(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      utcOffsetHours: utcOffsetHours ?? this.utcOffsetHours,
      iqamahDuration: iqamahDuration ?? this.iqamahDuration,
      prayerOffsets: prayerOffsets ?? this.prayerOffsets,
    );
  }
}
