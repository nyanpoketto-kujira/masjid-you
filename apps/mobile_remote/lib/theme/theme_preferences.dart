import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sumber skema warna aplikasi remote.
enum AppColorSource {
  /// Ikuti wallpaper perangkat (dynamic color Material You, Android 12+).
  /// Bila perangkat tidak mendukung, otomatis jatuh ke [seed].
  dynamic,

  /// Seed tetap identitas aplikasi ("Hijau Masjid").
  seed,
}

/// Preferensi tampilan aplikasi (mode tema + sumber warna) yang tersimpan
/// lokal via SharedPreferences.
///
/// Default sesuai keputusan D1 plan refaktor UI: mode mengikuti sistem dan
/// warna mengikuti wallpaper, dengan fallback seed "Hijau Masjid".
class ThemePreferences {
  ThemePreferences._();

  static const String modeKey = 'theme_mode_preference';
  static const String colorSourceKey = 'color_source_preference';

  static Future<ThemeMode> loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(modeKey);
    if (index == null || index < 0 || index >= ThemeMode.values.length) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }

  static Future<AppColorSource> loadColorSource() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(colorSourceKey);
    if (index == null || index < 0 || index >= AppColorSource.values.length) {
      return AppColorSource.dynamic;
    }
    return AppColorSource.values[index];
  }

  static Future<void> saveMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(modeKey, mode.index);
  }

  static Future<void> saveColorSource(AppColorSource source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(colorSourceKey, source.index);
  }
}
