import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tv_display/state/local_ip.dart';

/// Tes pemilih IP lokal TV (ADR-029, item D): alamat yang ditampilkan di
/// menu admin agar DKM bisa menyambung Remote lewat jalur IP/Wi-Fi.
void main() {
  group('pickLocalIpv4', () {
    test('daftar kosong -> null (tidak ada jaringan)', () {
      expect(pickLocalIpv4(const []), isNull);
    });

    test('hanya loopback/link-local -> null', () {
      expect(
        pickLocalIpv4([
          (name: 'lo', addresses: [InternetAddress('127.0.0.1')]),
          (name: 'wlan0', addresses: [InternetAddress('169.254.1.9')]),
        ]),
        isNull,
      );
    });

    test('memilih IPv4 non-loopback pertama', () {
      expect(
        pickLocalIpv4([
          (name: 'eth0', addresses: [InternetAddress('192.168.1.23')]),
        ]),
        '192.168.1.23',
      );
    });

    test('Wi-Fi diutamakan atas antarmuka lain', () {
      expect(
        pickLocalIpv4([
          (name: 'rmnet0', addresses: [InternetAddress('10.0.0.2')]),
          (name: 'wlan0', addresses: [InternetAddress('192.168.1.23')]),
          (name: 'eth0', addresses: [InternetAddress('192.168.1.24')]),
        ]),
        '192.168.1.23',
      );
    });

    test('ethernet diutamakan atas antarmuka generik', () {
      expect(
        pickLocalIpv4([
          (name: 'rmnet0', addresses: [InternetAddress('10.0.0.2')]),
          (name: 'eth0', addresses: [InternetAddress('192.168.1.24')]),
        ]),
        '192.168.1.24',
      );
    });

    test('alamat IPv6 diabaikan', () {
      expect(
        pickLocalIpv4([
          (name: 'wlan0', addresses: [InternetAddress('fe80::1')]),
        ]),
        isNull,
      );
    });
  });

  group('formatTvIpText', () {
    test('dengan alamat', () {
      expect(formatTvIpText('192.168.1.23'), 'IP TV: 192.168.1.23');
    });

    test('tanpa jaringan', () {
      expect(formatTvIpText(null), 'IP TV: tidak ada jaringan');
      expect(formatTvIpText(''), 'IP TV: tidak ada jaringan');
    });
  });
}
