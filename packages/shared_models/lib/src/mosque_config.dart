import 'dart:convert';
import 'prayer_type.dart';

/// Helper aman parsing numerik dari payload JSON yang tidak dipercaya.
/// Mengembalikan [fallback] bila [raw] bukan angka, sehingga `fromMap`
/// tidak pernah melempar `TypeError` dari cast `as num?`.
int _intOf(Object? raw, int fallback) => raw is num ? raw.toInt() : fallback;

double _doubleOf(Object? raw, double fallback) =>
    raw is num ? raw.toDouble() : fallback;

/// Helper aman parsing bool: [fallback] bila [raw] bukan bool (mis. payload
/// lama yang belum mengenal kunci ini), sehingga toggle baru selalu punya
/// nilai default yang aman.
bool _boolOf(Object? raw, bool fallback) => raw is bool ? raw : fallback;

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
      fajr: _intOf(map['fajr'], 10),
      dhuhr: _intOf(map['dhuhr'], 10),
      asr: _intOf(map['asr'], 10),
      maghrib: _intOf(map['maghrib'], 7),
      isha: _intOf(map['isha'], 10),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IqamahDuration &&
          other.fajr == fajr &&
          other.dhuhr == dhuhr &&
          other.asr == asr &&
          other.maghrib == maghrib &&
          other.isha == isha;

  @override
  int get hashCode => Object.hash(fajr, dhuhr, asr, maghrib, isha);

  @override
  String toString() =>
      'IqamahDuration(fajr: $fajr, dhuhr: $dhuhr, asr: $asr, maghrib: $maghrib, isha: $isha)';
}

/// Konfigurasi identitas & siklus waktu shalat masjid.
///
/// Objek ini dirancang immutable. Catatan: konstruktor utama tetap `const`
/// agar bisa dipakai sebagai konstanta compile-time, sehingga [prayerOffsets]
/// yang diberikan langsung ke konstruktor TIDAK dibungkus unmodifiable
/// (pemanggil yang membuat instance sendiri bertanggung jawab untuk tidak
/// memutak-ataikannya). Semua pembuatan lewat [fromMap] / [copyWith]
/// membungkus map menjadi unmodifiable sehingga tidak bisa diubah dari luar.
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

  /// Tampilkan kartu Kas Masjid di slot samping TV (rotasi kartu kanan).
  ///
  /// `false` = kartu kas dilewati dari rotasi slot samping; data transaksi
  /// kas sendiri tetap disimpan & disinkronkan seperti biasa.
  final bool showKas;

  /// Masjid/musholla ini menyelenggarakan shalat Jumat (Jumatan).
  ///
  /// `false` (umumnya musholla) = tidak ada perlakuan khusus hari Jumat:
  /// kartu Petugas Jumat tidak masuk rotasi slot samping, Dzuhur tetap
  /// berlabel "Dzuhur" (bukan "Jumat"), dan fase khutbah tidak dijalankan.
  final bool hasFridayPrayer;

  /// Interval slideshow gambar latar TV, detik per gambar (ADR-031).
  ///
  /// Selalu dalam rentang [minBackgroundSlideSeconds]..
  /// [maxBackgroundSlideSeconds] — `fromMap` dan `copyWith` men-clamp
  /// nilai di luar rentang.
  final int backgroundSlideSeconds;

  /// Batas bawah interval slideshow gambar latar (detik).
  static const int minBackgroundSlideSeconds = 5;

  /// Batas atas interval slideshow gambar latar (detik).
  static const int maxBackgroundSlideSeconds = 300;

  /// Nilai default interval slideshow gambar latar (detik).
  static const int defaultBackgroundSlideSeconds = 30;

  /// Clamp [seconds] ke rentang interval slideshow yang sah.
  static int clampBackgroundSlideSeconds(int seconds) => seconds.clamp(
        minBackgroundSlideSeconds,
        maxBackgroundSlideSeconds,
      );

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
    this.showKas = true,
    this.hasFridayPrayer = true,
    this.backgroundSlideSeconds = defaultBackgroundSlideSeconds,
  });

  /// Konstruktor internal: selalu membungkus [prayerOffsets] menjadi
  /// unmodifiable (dipakai `fromMap` & `copyWith`).
  MosqueConfig._internal({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetHours,
    required this.iqamahDuration,
    required Map<PrayerType, int> prayerOffsets,
    required this.preAdhanMinutes,
    required this.adhanMinutes,
    required this.preIqomahMinutes,
    required this.shalatMinutes,
    required this.khutbahMinutes,
    required this.fridayKhatib,
    required this.fridayMuadzin,
    required this.showKas,
    required this.hasFridayPrayer,
    required this.backgroundSlideSeconds,
  }) : prayerOffsets = Map.unmodifiable(prayerOffsets);

  int offsetFor(PrayerType type) => prayerOffsets[type] ?? 0;

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'utcOffsetHours': utcOffsetHours,
        'iqamahDuration': iqamahDuration.toMap(),
        'prayerOffsets': {
          for (final type in kAllPrayerTypes)
            type.name: prayerOffsets[type] ?? 0,
        },
        'preAdhanMinutes': preAdhanMinutes,
        'adhanMinutes': adhanMinutes,
        'preIqomahMinutes': preIqomahMinutes,
        'shalatMinutes': shalatMinutes,
        'khutbahMinutes': khutbahMinutes,
        'fridayKhatib': fridayKhatib,
        'fridayMuadzin': fridayMuadzin,
        'showKas': showKas,
        'hasFridayPrayer': hasFridayPrayer,
        'backgroundSlideSeconds': backgroundSlideSeconds,
      };

  factory MosqueConfig.fromMap(Map<String, dynamic> map) {
    Map<PrayerType, int> parseOffsets() {
      final result = <PrayerType, int>{};
      final raw = map['prayerOffsets'];
      if (raw is Map) {
        for (final entry in raw.entries) {
          final type =
              PrayerType.values.where((t) => t.name == entry.key).firstOrNull;
          if (type != null) {
            result[type] = _intOf(entry.value, 0);
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

    final rawName = map['name'];
    final rawAddress = map['address'];
    final rawUtc = map['utcOffsetHours'];
    final rawIqamah = map['iqamahDuration'];
    final rawKhatib = map['fridayKhatib'];
    final rawMuadzin = map['fridayMuadzin'];

    return MosqueConfig._internal(
      name: rawName is String ? rawName : 'Masjid Al-Ikhlas',
      address: rawAddress is String ? rawAddress : '',
      latitude: _doubleOf(map['latitude'], -6.2088),
      longitude: _doubleOf(map['longitude'], 106.8456),
      utcOffsetHours: _intOf(rawUtc, 7),
      iqamahDuration: rawIqamah is Map
          ? IqamahDuration.fromMap(Map<String, dynamic>.from(rawIqamah))
          : const IqamahDuration(),
      prayerOffsets: parseOffsets(),
      preAdhanMinutes: _intOf(map['preAdhanMinutes'], 15),
      adhanMinutes: _intOf(map['adhanMinutes'], 2),
      preIqomahMinutes: _intOf(map['preIqomahMinutes'], 1),
      shalatMinutes: _intOf(map['shalatMinutes'], 10),
      khutbahMinutes: _intOf(map['khutbahMinutes'], 20),
      fridayKhatib: rawKhatib is String ? rawKhatib : 'Ustadz Khatib',
      fridayMuadzin: rawMuadzin is String ? rawMuadzin : 'Ustadz Bilal',
      // Payload lama belum punya kedua kunci ini -> default `true`
      // (perilaku lama: kas tampil & Jumatan ada).
      showKas: _boolOf(map['showKas'], true),
      hasFridayPrayer: _boolOf(map['hasFridayPrayer'], true),
      // Payload lama belum punya kunci ini -> default 30 detik; nilai di
      // luar rentang di-clamp agar TV tidak pernah slideshow terlalu
      // cepat/lambat (ADR-031).
      backgroundSlideSeconds: clampBackgroundSlideSeconds(
        _intOf(map['backgroundSlideSeconds'], defaultBackgroundSlideSeconds),
      ),
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
    bool? showKas,
    bool? hasFridayPrayer,
    int? backgroundSlideSeconds,
  }) {
    return MosqueConfig._internal(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      utcOffsetHours: utcOffsetHours ?? this.utcOffsetHours,
      iqamahDuration: iqamahDuration ?? this.iqamahDuration,
      // Deep copy: salinan punya map-nya sendiri sehingga mutasi pada map
      // milik objek lama tidak ikut mengubah salinan (dan sebaliknya).
      prayerOffsets:
          prayerOffsets ?? Map<PrayerType, int>.of(this.prayerOffsets),
      preAdhanMinutes: preAdhanMinutes ?? this.preAdhanMinutes,
      adhanMinutes: adhanMinutes ?? this.adhanMinutes,
      preIqomahMinutes: preIqomahMinutes ?? this.preIqomahMinutes,
      shalatMinutes: shalatMinutes ?? this.shalatMinutes,
      khutbahMinutes: khutbahMinutes ?? this.khutbahMinutes,
      fridayKhatib: fridayKhatib ?? this.fridayKhatib,
      fridayMuadzin: fridayMuadzin ?? this.fridayMuadzin,
      showKas: showKas ?? this.showKas,
      hasFridayPrayer: hasFridayPrayer ?? this.hasFridayPrayer,
      backgroundSlideSeconds: backgroundSlideSeconds == null
          ? this.backgroundSlideSeconds
          : clampBackgroundSlideSeconds(backgroundSlideSeconds),
    );
  }

  static bool _mapsEqual(Map<PrayerType, int> a, Map<PrayerType, int> b) {
    // Perbandingan semantik: {fajr: 1} dan {fajr: 1, sunrise: 0, ...}
    // dianggap sama karena hasil offsetFor-nya identik untuk semua shalat.
    for (final type in kAllPrayerTypes) {
      if ((a[type] ?? 0) != (b[type] ?? 0)) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MosqueConfig &&
          other.name == name &&
          other.address == address &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.utcOffsetHours == utcOffsetHours &&
          other.iqamahDuration == iqamahDuration &&
          _mapsEqual(other.prayerOffsets, prayerOffsets) &&
          other.preAdhanMinutes == preAdhanMinutes &&
          other.adhanMinutes == adhanMinutes &&
          other.preIqomahMinutes == preIqomahMinutes &&
          other.shalatMinutes == shalatMinutes &&
          other.khutbahMinutes == khutbahMinutes &&
          other.fridayKhatib == fridayKhatib &&
          other.fridayMuadzin == fridayMuadzin &&
          other.showKas == showKas &&
          other.hasFridayPrayer == hasFridayPrayer &&
          other.backgroundSlideSeconds == backgroundSlideSeconds;

  @override
  int get hashCode => Object.hash(
        name,
        address,
        latitude,
        longitude,
        utcOffsetHours,
        iqamahDuration,
        Object.hashAll(kAllPrayerTypes.map(offsetFor)),
        preAdhanMinutes,
        adhanMinutes,
        preIqomahMinutes,
        shalatMinutes,
        khutbahMinutes,
        fridayKhatib,
        fridayMuadzin,
        showKas,
        hasFridayPrayer,
        backgroundSlideSeconds,
      );

  @override
  String toString() =>
      'MosqueConfig(name: $name, address: $address, latitude: $latitude, '
      'longitude: $longitude, utcOffsetHours: $utcOffsetHours, '
      'iqamahDuration: $iqamahDuration, prayerOffsets: $prayerOffsets, '
      'preAdhanMinutes: $preAdhanMinutes, adhanMinutes: $adhanMinutes, '
      'preIqomahMinutes: $preIqomahMinutes, shalatMinutes: $shalatMinutes, '
      'khutbahMinutes: $khutbahMinutes, fridayKhatib: $fridayKhatib, '
      'fridayMuadzin: $fridayMuadzin, showKas: $showKas, '
      'hasFridayPrayer: $hasFridayPrayer, '
      'backgroundSlideSeconds: $backgroundSlideSeconds)';
}
