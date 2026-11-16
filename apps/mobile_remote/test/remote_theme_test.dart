import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/theme/remote_theme.dart';
import 'package:mobile_remote/theme/theme_preferences.dart';

/// Tes fondasi tema Material You (Fase 0 refaktor UI remote):
/// resolusi skema warna dinamis vs seed + kelengkapan tema komponen.
void main() {
  group('resolveRemoteColorScheme', () {
    final dynamicLight = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    );
    final dynamicDark = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );

    test('sumber dinamis memakai skema wallpaper sesuai brightness', () {
      expect(
        resolveRemoteColorScheme(
          brightness: Brightness.light,
          source: AppColorSource.dynamic,
          dynamicLight: dynamicLight,
          dynamicDark: dynamicDark,
        ),
        same(dynamicLight),
      );
      expect(
        resolveRemoteColorScheme(
          brightness: Brightness.dark,
          source: AppColorSource.dynamic,
          dynamicLight: dynamicLight,
          dynamicDark: dynamicDark,
        ),
        same(dynamicDark),
      );
    });

    test('sumber dinamis tanpa skema perangkat jatuh ke seed Hijau Masjid',
        () {
      final light = resolveRemoteColorScheme(
        brightness: Brightness.light,
        source: AppColorSource.dynamic,
      );
      final dark = resolveRemoteColorScheme(
        brightness: Brightness.dark,
        source: AppColorSource.dynamic,
      );

      expect(light.primary, masjidSeedScheme(Brightness.light).primary);
      expect(dark.primary, masjidSeedScheme(Brightness.dark).primary);
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    test('sumber seed mengabaikan skema dinamis yang tersedia', () {
      final scheme = resolveRemoteColorScheme(
        brightness: Brightness.light,
        source: AppColorSource.seed,
        dynamicLight: dynamicLight,
        dynamicDark: dynamicDark,
      );

      expect(scheme.primary, masjidSeedScheme(Brightness.light).primary);
      expect(scheme.primary, isNot(dynamicLight.primary));
    });
  });

  group('buildRemoteTheme', () {
    final scheme = masjidSeedScheme(Brightness.light);
    final theme = buildRemoteTheme(scheme);

    test('Material 3 aktif dan skema diteruskan apa adanya', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, same(scheme));
    });

    test('shape standar ADR-012: kartu r16, dialog & sheet r28', () {
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, BorderRadius.circular(16));

      final dialogShape = theme.dialogTheme.shape as RoundedRectangleBorder;
      expect(dialogShape.borderRadius, BorderRadius.circular(28));

      final sheetShape =
          theme.bottomSheetTheme.shape as RoundedRectangleBorder;
      expect(sheetShape.borderRadius, BorderRadius.circular(28));
    });

    test('indikator NavigationBar pill dan tombol pill', () {
      expect(theme.navigationBarTheme.indicatorShape, isA<StadiumBorder>());
      final filledShape =
          theme.filledButtonTheme.style?.shape?.resolve({});
      expect(filledShape, isA<StadiumBorder>());
    });

    test('FAB r16 dan SnackBar floating (fondasi Fase 0)', () {
      final fabShape =
          theme.floatingActionButtonTheme.shape as RoundedRectangleBorder;
      expect(fabShape.borderRadius, BorderRadius.circular(16));
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
    });

    test('input field outline r16 dengan fokus primary', () {
      final border = theme.inputDecorationTheme.border as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(16));
      final focused =
          theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(focused.borderSide.color, scheme.primary);
    });
  });
}
