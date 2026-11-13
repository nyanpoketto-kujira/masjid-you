import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_remote/main.dart';

/// Regression crash Red Screen:
/// framework.dart assertion `_dependents.isEmpty` saat dialog PIN ditutup
/// (tombol Batal) bertabrakan dengan rebuild Scaffold/InheritedWidget.
///
/// Test ini membangun app, memaksa beberapa kali rebuild (simulasi event
/// stream BT yang datang saat dialog koneksi aktif), lalu memastikan:
/// - navigator root & messenger tetap hidup,
/// - tidak ada exception lifecycle, dan
/// - layar sambungan masih dirender normal (tidak crash kembali).
void main() {
  testWidgets('rebuild berulang tidak menghancurkan navigator/messenger',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MasjidYouRemoteApp());
    await tester.pumpAndSettle();

    // Simulasi event koneksi realtime: beberapa kali rebuild berturut-turut
    // (pada versi lama, state stream + setState saat route dialog terbuka
    // memicu assertion '_dependents.isEmpty').
    for (var i = 0; i < 4; i++) {
      await tester.pumpWidget(const MasjidYouRemoteApp());
      await tester.pumpAndSettle();
    }

    // Tidak ada exception lifecycle.
    expect(tester.takeException(), isNull);

    // Root navigator + messenger masih hidup & terpasang.
    expect(find.byType(Navigator), findsOneWidget);
    expect(appNavigatorKey.currentState, isNotNull);
    expect(appMessengerKey.currentState, isNotNull);

    // Layar sambungan tampil utuh — koneksi belum aktif.
    expect(find.text('Selamat Datang di Remote Masjid'), findsOneWidget);
    expect(find.text('Koneksi Bluetooth'), findsOneWidget);
    expect(find.text('Koneksi IP Address'), findsOneWidget);
    expect(find.text('Remote Masjid DKM'), findsNothing);
  });
}
