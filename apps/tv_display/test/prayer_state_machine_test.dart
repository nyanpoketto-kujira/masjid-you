import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/state/prayer_state_machine.dart';

PrayerSchedule _schedule({
  required DateTime now,
  required PrayerType nextPrayer,
  required Duration until,
}) {
  return PrayerSchedule(
    date: now,
    items: const [],
    nextPrayer: nextPrayer,
    timeUntilNextPrayer: until,
  );
}

void main() {
  const config = MosqueConfig(
    preAdhanMinutes: 15,
    adhanMinutes: 2,
    preIqomahMinutes: 1,
    shalatMinutes: 10,
  );

  final now = DateTime(2026, 8, 13, 17, 0); // Kamis — hari biasa

  group('PrayerStateMachine — Hari Biasa', () {
    test('auto-starts PRE_ADHAN when next prayer within preAdhan window', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)),
      );

      expect(machine.phase, PrayerPhase.preAdhan);
      expect(machine.prayer, PrayerType.maghrib);
      expect(machine.remaining, const Duration(minutes: 15));
    });

    test('does not auto-start when next prayer is far away', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 60)),
      );

      expect(machine.phase, PrayerPhase.normal);
    });

    test('does not auto-start for sunrise (Syuruq)', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.sunrise, until: const Duration(minutes: 5)),
      );

      expect(machine.phase, PrayerPhase.normal);
    });

    test('jumps straight to ADHAN when prayer time has arrived', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.isha, until: Duration.zero),
      );

      expect(machine.phase, PrayerPhase.adhan);
      expect(machine.prayer, PrayerType.isha);
    });

    test('auto-cycles through full ceremony back to NORMAL', () {
      final machine = PrayerStateMachine()..initialize(config);

      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)),
      );
      expect(machine.phase, PrayerPhase.preAdhan);

      machine.tick(now.add(const Duration(minutes: 15)),
          _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)));
      expect(machine.phase, PrayerPhase.adhan);

      machine.tick(now.add(const Duration(minutes: 17)),
          _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)));
      expect(machine.phase, PrayerPhase.preIqomah);

      machine.tick(now.add(const Duration(minutes: 18)),
          _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)));
      expect(machine.phase, PrayerPhase.shalat);

      machine.tick(now.add(const Duration(minutes: 28)),
          _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)));
      expect(machine.phase, PrayerPhase.normal);
    });

    test('skipAdhan jumps ADHAN -> PRE_IQOMAH', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(now, _schedule(now: now, nextPrayer: PrayerType.maghrib, until: Duration.zero));
      expect(machine.phase, PrayerPhase.adhan);

      machine.skipAdhan();

      expect(machine.phase, PrayerPhase.preIqomah);
    });

    test('startShalat jumps PRE_IQOMAH -> SHALAT', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.skipAdhan();
      expect(machine.phase, PrayerPhase.normal, reason: 'noop when not in ADHAN');

      // Manually walk into PRE_IQOMAH via skips.
      machine.tick(now, _schedule(now: now, nextPrayer: PrayerType.maghrib, until: Duration.zero));
      machine.skipAdhan();
      expect(machine.phase, PrayerPhase.preIqomah);

      machine.startShalat();
      expect(machine.phase, PrayerPhase.shalat);
    });

    test('finishShalat jumps SHALAT -> NORMAL', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(now, _schedule(now: now, nextPrayer: PrayerType.maghrib, until: Duration.zero));
      machine.skipAdhan();
      machine.startShalat();
      expect(machine.phase, PrayerPhase.shalat);

      machine.finishShalat();

      expect(machine.phase, PrayerPhase.normal);
      expect(machine.prayer, isNull);
      expect(machine.remaining, Duration.zero);
    });

    test('skip actions are no-ops when not in matching phase', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.skipAdhan();
      machine.startShalat();
      machine.finishShalat();
      expect(machine.phase, PrayerPhase.normal);
    });

    test('updateConfig clamps remaining to new shorter duration', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)),
      );
      machine.tick(now.add(const Duration(minutes: 5)),
          _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 10)));

      const shorter = MosqueConfig(preAdhanMinutes: 2);
      machine.updateConfig(shorter, now.add(const Duration(minutes: 5)));

      expect(machine.remaining, const Duration(minutes: 2));
    });

    test('autoCycle=false never auto-starts a ceremony', () {
      final machine = PrayerStateMachine()
        ..initialize(config, autoCycle: false);
      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.maghrib, until: const Duration(minutes: 1)),
      );

      expect(machine.phase, PrayerPhase.normal);
    });

    test('forcePhase enters target phase with full duration from config', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.forcePhase(
        PrayerPhase.preAdhan,
        now: now,
        schedule: _schedule(
          now: now,
          nextPrayer: PrayerType.maghrib,
          until: const Duration(minutes: 10),
        ),
      );

      expect(machine.phase, PrayerPhase.preAdhan);
      expect(machine.prayer, PrayerType.maghrib);
      expect(machine.remaining, const Duration(minutes: 15));
      expect(machine.total, const Duration(minutes: 15));
    });

    test('forcePhase(SHALAT) enters full-screen shalat phase', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.forcePhase(PrayerPhase.shalat, now: now);

      expect(machine.phase, PrayerPhase.shalat);
      expect(machine.remaining, const Duration(minutes: 10));
    });

    test('forcePhase(normal) resets to standby with zero remaining', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.forcePhase(PrayerPhase.adhan, now: now);
      expect(machine.phase, PrayerPhase.adhan);

      machine.forcePhase(PrayerPhase.normal, now: now);

      expect(machine.phase, PrayerPhase.normal);
      expect(machine.prayer, isNull);
      expect(machine.remaining, Duration.zero);
      expect(machine.total, Duration.zero);
    });

    test('forcePhase without schedule keeps current prayer', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.isha, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.adhan);
      expect(machine.prayer, PrayerType.isha);

      machine.forcePhase(PrayerPhase.preIqomah, now: now);

      expect(machine.phase, PrayerPhase.preIqomah);
      expect(machine.prayer, PrayerType.isha);
    });

    test('Dzuhur hari biasa melewati KHUTBAH (langsung ke PRE_IQOMAH)', () {
      final machine = PrayerStateMachine()..initialize(config);

      machine.tick(
        now,
        _schedule(now: now, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.adhan);

      machine.tick(
        now.add(const Duration(minutes: 2)),
        _schedule(now: now, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.preIqomah);
    });
  });

  group('PrayerStateMachine — Hari Jumat', () {
    final friday = DateTime(2026, 8, 14, 12, 0); // Hari Jumat

    test('auto-cycle Dzuhur menyisipkan KHUTBAH antara ADHAN dan PRE_IQOMAH', () {
      final machine = PrayerStateMachine()..initialize(config);

      machine.tick(
        friday,
        _schedule(now: friday, nextPrayer: PrayerType.dhuhr, until: const Duration(minutes: 10)),
      );
      expect(machine.phase, PrayerPhase.preAdhan);

      machine.tick(
        friday.add(const Duration(minutes: 15)),
        _schedule(now: friday, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.adhan);

      machine.tick(
        friday.add(const Duration(minutes: 17)),
        _schedule(now: friday, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.khutbah);
      expect(machine.prayer, PrayerType.dhuhr);
      expect(machine.remaining, const Duration(minutes: 20)); // khutbahMinutes default

      machine.tick(
        friday.add(const Duration(minutes: 37)),
        _schedule(now: friday, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.preIqomah);

      machine.tick(
        friday.add(const Duration(minutes: 38)),
        _schedule(now: friday, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.shalat);

      machine.tick(
        friday.add(const Duration(minutes: 48)),
        _schedule(now: friday, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.normal);
    });

    test('skipAdhan lanjut ke KHUTBAH dan startIqomah ke PRE_IQOMAH', () {
      final machine = PrayerStateMachine()..initialize(config);

      machine.tick(
        friday,
        _schedule(now: friday, nextPrayer: PrayerType.dhuhr, until: Duration.zero),
      );
      expect(machine.phase, PrayerPhase.adhan);

      machine.skipAdhan(now: friday);
      expect(machine.phase, PrayerPhase.khutbah);

      machine.startIqomah();
      expect(machine.phase, PrayerPhase.preIqomah);
    });

    test('startIqomah no-op di luar fase khutbah', () {
      final machine = PrayerStateMachine()..initialize(config);
      machine.forcePhase(PrayerPhase.preIqomah, now: friday);

      machine.startIqomah();

      expect(machine.phase, PrayerPhase.preIqomah);
    });
  });
}
