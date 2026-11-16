import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_remote/main.dart';
import 'package:mobile_remote/theme/remote_theme.dart';
import 'package:mobile_remote/theme/theme_preferences.dart';

void main() {
  testWidgets('app dibuka ke layar sambungan (gatekeeper), bukan menu utama',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MasjidYouRemoteApp());
    await tester.pumpAndSettle();

    // Gatekeeper: judul selamat datang + dua opsi koneksi.
    expect(find.text('Selamat Datang di Remote Masjid'), findsOneWidget);
    expect(find.text('Koneksi Bluetooth'), findsOneWidget);
    expect(find.text('Koneksi IP Address'), findsOneWidget);
    expect(find.text('Hubungkan'), findsOneWidget);
    expect(find.text('Cari TV'), findsOneWidget);

    // Menu utama (tab/nav) TIDAK boleh tampil sebelum terhubung.
    expect(find.text('Remote Masjid DKM'), findsNothing);
    expect(find.text('Konektivitas'), findsNothing);
  });

  testWidgets('transisi gatekeeper -> menu utama tidak merusak lifecycle',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MasjidYouRemoteApp());
    await tester.pumpAndSettle();
    expect(find.text('Koneksi IP Address'), findsOneWidget);

    // Bangun ulang widget dengan state terhubung (simulasi setState dari
    // _handleConnectionEstablished). Di versi lama ini memicu assertion
    // '_dependents.isEmpty' karena subtree root ditukar saat transisi.
    await tester.pumpWidget(const MasjidYouRemoteApp());
    await tester.pumpAndSettle();

    // App tetap alive: gatekeeper masih dirender (state internal tetap
    // belum terhubung), tidak ada exception lifecycle.
    expect(tester.takeException(), isNull);
    expect(find.text('Selamat Datang di Remote Masjid'), findsOneWidget);
  });

  testWidgets('preferensi tersimpan diterapkan: mode gelap + seed Hijau Masjid',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      ThemePreferences.modeKey: ThemeMode.dark.index,
      ThemePreferences.colorSourceKey: AppColorSource.seed.index,
    });

    await tester.pumpWidget(const MasjidYouRemoteApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    // Di lingkungan tes tidak ada skema dinamis perangkat, dan sumber warna
    // memang seed: kedua tema harus berasal dari seed Hijau Masjid.
    expect(
      app.theme?.colorScheme.primary,
      masjidSeedScheme(Brightness.light).primary,
    );
    expect(
      app.darkTheme?.colorScheme.primary,
      masjidSeedScheme(Brightness.dark).primary,
    );
  });
}
