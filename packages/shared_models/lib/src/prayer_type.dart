enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

extension PrayerTypeX on PrayerType {
  String get displayName {
    switch (this) {
      case PrayerType.fajr:
        return 'Subuh';
      case PrayerType.sunrise:
        return 'Syuruq';
      case PrayerType.dhuhr:
        return 'Dzuhur';
      case PrayerType.asr:
        return 'Ashar';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isya';
    }
  }

  /// Nama tampilan yang peka tanggal: `dhuhr` menjadi "Jumat" pada hari Jumat.
  ///
  /// Dipakai untuk kartu jadwal & overlay supaya shalat Jumat tampil sebagai
  /// "Jumat" (bukan "Dzuhur") hanya saat hari Jumat.
  String displayNameForDate(DateTime date) {
    if (this == PrayerType.dhuhr && date.weekday == DateTime.friday) {
      return 'Jumat';
    }
    return displayName;
  }
}

const List<PrayerType> kAllPrayerTypes = [
  PrayerType.fajr,
  PrayerType.sunrise,
  PrayerType.dhuhr,
  PrayerType.asr,
  PrayerType.maghrib,
  PrayerType.isha,
];
