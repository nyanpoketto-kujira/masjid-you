import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'theme_preferences.dart';

/// Seed warna identitas aplikasi ("Hijau Masjid").
const Color kMasjidSeedColor = Color(0xFF006A60);

/// Skema warna dari seed "Hijau Masjid" untuk [brightness] tertentu.
ColorScheme masjidSeedScheme(Brightness brightness) {
  return ColorScheme.fromSeed(
    seedColor: kMasjidSeedColor,
    brightness: brightness,
  );
}

/// Memilih skema warna efektif untuk [brightness].
///
/// Bila sumber warna [AppColorSource.dynamic] dan perangkat menyediakan
/// skema dinamis (wallpaper, Android 12+), skema dinamis yang dipakai.
/// Selain itu selalu jatuh ke seed "Hijau Masjid" (keputusan D1).
ColorScheme resolveRemoteColorScheme({
  required Brightness brightness,
  required AppColorSource source,
  ColorScheme? dynamicLight,
  ColorScheme? dynamicDark,
}) {
  if (source == AppColorSource.dynamic) {
    final dynamicScheme =
        brightness == Brightness.light ? dynamicLight : dynamicDark;
    if (dynamicScheme != null) {
      return dynamicScheme;
    }
  }
  return masjidSeedScheme(brightness);
}

/// Tema Material 3 standar untuk aplikasi remote.
///
/// Shape mengikuti ADR-012 (standar, bukan Expressive): kartu r16,
/// dialog & bottom sheet r28, tombol/chip/indikator navigasi pill.
ThemeData buildRemoteTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 3),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: scheme.outlineVariant),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        // Target sentuh utama >=48dp (Fase 4, aksesibilitas).
        minimumSize: const Size(64, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(64, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
      ),
    ),
    segmentedButtonTheme: const SegmentedButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(StadiumBorder())),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    // Transisi antar halaman (Fase 4): shared-axis horizontal di Android,
    // sesuai panduan motion M3 (fade-through dipakai untuk pergantian
    // gate -> menu utama di RemoteHomeScreen).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      },
    ),
  );
}
