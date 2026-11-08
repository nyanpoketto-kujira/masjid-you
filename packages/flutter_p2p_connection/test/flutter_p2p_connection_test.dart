import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection_platform_interface.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterP2pConnectionPlatform
    with MockPlatformInterfaceMixin
    implements FlutterP2pConnectionPlatform {
  @override
  Future<String> getPlatformVersion() => Future.value('42');

  @override
  Future<String> getPlatformModel() => Future.value('Test Model');

  // Concrete stubs required by the analyzer when overriding interface methods.
  // Unused methods delegate to their base throwing stub so no extra logic is
  // needed here.
  @override
  Future<void> initialize({String? serviceUuid, bool? bondingRequired, bool? encryptionRequired}) async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> createHotspot() async {}

  @override
  Future<void> removeHotspot() async {}

  @override
  Future<void> connectToHotspot(String ssid, String psk) async {}

  @override
  Future<void> disconnectFromHotspot() async {}

  @override
  Future<void> startBleAdvertising(String ssid, String psk) async {}

  @override
  Future<void> stopBleAdvertising() async {}

  @override
  Future<void> startBleScan() async {}

  @override
  Future<void> stopBleScan() async {}

  @override
  Future<void> connectBleDevice(String deviceAddress) async {}

  @override
  Future<void> disconnectBleDevice(String deviceAddress) async {}

  @override
  Future<bool> checkP2pPermissions() async => false;

  @override
  Future<void> askP2pPermissions() async {}

  @override
  Future<bool> checkLocationEnabled() async => false;

  @override
  Future<void> enableLocationServices() async {}

  @override
  Future<bool> checkWifiEnabled() async => false;

  @override
  Future<void> enableWifiServices() async {}

  @override
  Future<bool> checkBluetoothEnabled() async => false;

  @override
  Future<void> enableBluetoothServices() async {}

  @override
  Stream<HotspotHostState> streamHotspotInfo() => Stream.empty();

  @override
  Stream<HotspotClientState> streamHotspotClientState() => Stream.empty();

  @override
  Stream<BleConnectionState> streamBleConnectionState() => Stream.empty();

  @override
  Stream<List<BleDiscoveredDevice>> streamBleScanResult() => Stream.empty();

  @override
  Stream<BleReceivedData> streamBleReceivedData() => Stream.empty();
}

void main() {
  final FlutterP2pConnectionPlatform initialPlatform =
      FlutterP2pConnectionPlatform.instance;

  test('$MethodChannelFlutterP2pConnection is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterP2pConnection>());
  });

  test('getDeviceModel', () async {
    FlutterP2pClient flutterP2pConnectionPlugin = FlutterP2pClient();
    MockFlutterP2pConnectionPlatform fakePlatform =
        MockFlutterP2pConnectionPlatform();
    FlutterP2pConnectionPlatform.instance = fakePlatform;

    expect(await flutterP2pConnectionPlugin.getDeviceModel(), 'Test Model');
  });
}
