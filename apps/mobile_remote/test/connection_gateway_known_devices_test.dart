import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/connection/connection_gateway_screen.dart';

/// Tes bagian "Perangkat Dikenal" di gerbang koneksi (ADR-029): TV yang
/// sudah pernah pairing tampil untuk koneksi langsung tanpa discovery.
void main() {
  const tv = BluetoothDeviceInfo(
    name: 'Masjid You TV',
    address: 'AA:BB:CC:DD:EE:01',
    bonded: true,
  );

  Widget harness({
    List<BluetoothDeviceInfo> devices = const [],
    List<BluetoothDeviceInfo> knownDevices = const [],
    ValueChanged<BluetoothDeviceInfo>? onConnect,
  }) {
    return MaterialApp(
      home: ConnectionGatewayScreen(
        ipController: TextEditingController(),
        isConnecting: false,
        onConnectIp: () {},
        btIsScanning: false,
        btDevices: devices,
        btKnownDevices: knownDevices,
        btStatus: 'Bluetooth: Stanby',
        onBtStartScan: () {},
        onBtStopScan: () {},
        onBtConnect: onConnect ?? (_) {},
      ),
    );
  }

  testWidgets('perangkat dikenal tampil dengan judul bagiannya',
      (tester) async {
    await tester.pumpWidget(harness(knownDevices: const [tv]));
    expect(find.text('Perangkat Dikenal'), findsOneWidget);
    expect(find.text('Masjid You TV'), findsOneWidget);
    expect(find.text('AA:BB:CC:DD:EE:01'), findsOneWidget);
    // Bukan lagi "belum ada perangkat" — daftar dikenal sudah terisi.
    expect(find.text('Belum ada perangkat ditemukan.'), findsNothing);
  });

  testWidgets('ketuk perangkat dikenal memanggil onBtConnect', (tester) async {
    BluetoothDeviceInfo? tapped;
    await tester.pumpWidget(
      harness(knownDevices: const [tv], onConnect: (d) => tapped = d),
    );
    await tester.tap(find.text('Masjid You TV'));
    expect(tapped?.address, tv.address);
  });

  testWidgets('tanpa perangkat dikenal: bagian tidak tampil', (tester) async {
    await tester.pumpWidget(harness());
    expect(find.text('Perangkat Dikenal'), findsNothing);
    expect(find.text('Belum ada perangkat ditemukan.'), findsOneWidget);
  });

  testWidgets('perangkat yang sama di hasil scan tidak tampil dua kali',
      (tester) async {
    await tester.pumpWidget(
      harness(devices: const [tv], knownDevices: const [tv]),
    );
    expect(find.text('Masjid You TV'), findsOneWidget);
  });
}
