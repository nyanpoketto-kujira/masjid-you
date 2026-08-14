import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'mosque_config.dart';
import 'prayer_type.dart';

export 'prayer_type.dart';

class PrayerScheduleItem {
  final PrayerType type;
  final DateTime time;

  PrayerScheduleItem({
    required this.type,
    required this.time,
  });

  String get formattedTime => DateFormat('HH:mm').format(time);
}

class PrayerSchedule {
  final DateTime date;
  final List<PrayerScheduleItem> items;
  final PrayerType? nextPrayer;
  final Duration? timeUntilNextPrayer;

  PrayerSchedule({
    required this.date,
    required this.items,
    this.nextPrayer,
    this.timeUntilNextPrayer,
  });

  factory PrayerSchedule.calculate(MosqueConfig config, [DateTime? targetDate]) {
    final now = targetDate ?? DateTime.now();
    final coordinates = Coordinates(config.latitude, config.longitude);

    // Kemenag RI uses Singapore or MABIMS standard
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final dateComponents = DateComponents.from(now);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    int offsetFor(PrayerType type) => config.offsetFor(type);

    final items = [
      PrayerScheduleItem(
        type: PrayerType.fajr,
        time: prayerTimes.fajr.add(Duration(minutes: offsetFor(PrayerType.fajr))),
      ),
      PrayerScheduleItem(
        type: PrayerType.sunrise,
        time: prayerTimes.sunrise.add(Duration(minutes: offsetFor(PrayerType.sunrise))),
      ),
      PrayerScheduleItem(
        type: PrayerType.dhuhr,
        time: prayerTimes.dhuhr.add(Duration(minutes: offsetFor(PrayerType.dhuhr))),
      ),
      PrayerScheduleItem(
        type: PrayerType.asr,
        time: prayerTimes.asr.add(Duration(minutes: offsetFor(PrayerType.asr))),
      ),
      PrayerScheduleItem(
        type: PrayerType.maghrib,
        time: prayerTimes.maghrib.add(Duration(minutes: offsetFor(PrayerType.maghrib))),
      ),
      PrayerScheduleItem(
        type: PrayerType.isha,
        time: prayerTimes.isha.add(Duration(minutes: offsetFor(PrayerType.isha))),
      ),
    ];

    PrayerType? nextPrayer;
    Duration? timeUntilNext;

    for (final item in items) {
      if (item.time.isAfter(now)) {
        nextPrayer = item.type;
        timeUntilNext = item.time.difference(now);
        break;
      }
    }

    // If all prayer times today have passed, next prayer is Fajr tomorrow
    if (nextPrayer == null) {
      nextPrayer = PrayerType.fajr;
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowComponents = DateComponents.from(tomorrow);
      final tomorrowPrayerTimes = PrayerTimes(coordinates, tomorrowComponents, params);
      final tomorrowFajr = tomorrowPrayerTimes.fajr.add(Duration(minutes: offsetFor(PrayerType.fajr)));
      timeUntilNext = tomorrowFajr.difference(now);
    }

    return PrayerSchedule(
      date: now,
      items: items,
      nextPrayer: nextPrayer,
      timeUntilNextPrayer: timeUntilNext,
    );
  }
}
