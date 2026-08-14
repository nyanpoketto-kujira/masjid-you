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
}

const List<PrayerType> kAllPrayerTypes = [
  PrayerType.fajr,
  PrayerType.sunrise,
  PrayerType.dhuhr,
  PrayerType.asr,
  PrayerType.maghrib,
  PrayerType.isha,
];
