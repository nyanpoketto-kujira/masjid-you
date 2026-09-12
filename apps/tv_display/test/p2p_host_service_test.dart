import 'package:flutter_test/flutter_test.dart';

import 'package:tv_display/server/p2p_host_service.dart';

/// Helper: buat prasyarat dengan nilai default "semua siap".
P2pPrerequisites _prereq({
  bool wifi = true,
  bool bluetooth = true,
  bool location = true,
  bool p2pPerm = true,
  bool btPerm = true,
}) =>
    P2pPrerequisites(
      wifiEnabled: wifi,
      bluetoothEnabled: bluetooth,
      locationEnabled: location,
      p2pPermissionsGranted: p2pPerm,
      bluetoothPermissionsGranted: btPerm,
    );

void main() {
  group('P2pPrerequisites (TV host) isReady', () {
    test('siap penuh ketika semua prasyarat terpenuhi', () {
      expect(_prereq().isReady(locationRequired: true), isTrue);
      expect(_prereq().isReady(locationRequired: false), isTrue);
      expect(_prereq().allPermissionsGranted, isTrue);
    });

    test('lokasi hanya wajib bila locationRequired=true (Android < 12)', () {
      expect(_prereq(location: false).isReady(locationRequired: true), isFalse);
      expect(_prereq(location: false).isReady(locationRequired: false), isTrue);
    });

    test('gagal bila WiFi atau Bluetooth mati', () {
      expect(_prereq(wifi: false).isReady(locationRequired: true), isFalse);
      expect(_prereq(bluetooth: false).isReady(locationRequired: true), isFalse);
    });

    test('gagal bila salah satu izin belum diberikan', () {
      expect(_prereq(p2pPerm: false).isReady(locationRequired: true), isFalse);
      expect(_prereq(btPerm: false).isReady(locationRequired: true), isFalse);
    });

    test('truth table lengkap (5 boolean) konsisten dengan aturan gate', () {
      for (var wifi = 0; wifi <= 1; wifi++) {
        for (var bt = 0; bt <= 1; bt++) {
          for (var loc = 0; loc <= 1; loc++) {
            for (var p2p = 0; p2p <= 1; p2p++) {
              for (var btp = 0; btp <= 1; btp++) {
                final preq = _prereq(
                  wifi: wifi == 1,
                  bluetooth: bt == 1,
                  location: loc == 1,
                  p2pPerm: p2p == 1,
                  btPerm: btp == 1,
                );
                final expectedWithLoc =
                    wifi == 1 && bt == 1 && (p2p == 1 && btp == 1) && loc == 1;
                final expectedNoLoc =
                    wifi == 1 && bt == 1 && (p2p == 1 && btp == 1);
                expect(
                  preq.isReady(locationRequired: true),
                  expectedWithLoc,
                  reason:
                      'wifi=$wifi bt=$bt loc=$loc p2p=$p2p btp=$btp (loc wajib)',
                );
                expect(
                  preq.isReady(locationRequired: false),
                  expectedNoLoc,
                  reason:
                      'wifi=$wifi bt=$bt loc=$loc p2p=$p2p btp=$btp (loc opsional)',
                );
              }
            }
          }
        }
      }
    });
  });
}
