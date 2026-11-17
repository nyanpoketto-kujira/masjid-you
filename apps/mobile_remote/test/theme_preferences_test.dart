import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/theme/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tes persistensi preferensi tampilan (mode tema + sumber warna).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemePreferences', () {
    test('default: mode sistem + warna dinamis bila belum ada simpanan',
        () async {
      SharedPreferences.setMockInitialValues({});

      expect(await ThemePreferences.loadMode(), ThemeMode.system);
      expect(
        await ThemePreferences.loadColorSource(),
        AppColorSource.dynamic,
      );
    });

    test('round-trip: nilai yang disimpan terbaca kembali', () async {
      SharedPreferences.setMockInitialValues({});

      await ThemePreferences.saveMode(ThemeMode.dark);
      await ThemePreferences.saveColorSource(AppColorSource.seed);

      expect(await ThemePreferences.loadMode(), ThemeMode.dark);
      expect(await ThemePreferences.loadColorSource(), AppColorSource.seed);
    });

    test('nilai simpanan tidak valid jatuh ke default', () async {
      SharedPreferences.setMockInitialValues({
        ThemePreferences.modeKey: 99,
        ThemePreferences.colorSourceKey: -1,
      });

      expect(await ThemePreferences.loadMode(), ThemeMode.system);
      expect(
        await ThemePreferences.loadColorSource(),
        AppColorSource.dynamic,
      );
    });
  });
}
