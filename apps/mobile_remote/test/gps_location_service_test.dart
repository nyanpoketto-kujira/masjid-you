import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_remote/services/gps_location_service.dart';

/// Tes perbaikan GPS: dulu akurasi high + timeLimit 15 dtk tanpa
/// fallback, sehingga di dalam ruangan selalu timeout dan error
/// mentah "TimeoutException ... Future not completed" tampil ke
/// pengguna. Sekarang: akurasi medium, fallback posisi terakhir,
/// dan semua kegagalan dipetakan ke status yang jelas.
Position _pos(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime(2026, 11, 17, 12),
      accuracy: 12,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

GpsLocationService _service({
  bool serviceEnabled = true,
  LocationPermission checkResult = LocationPermission.whileInUse,
  LocationPermission requestResult = LocationPermission.whileInUse,
  Future<Position> Function()? current,
  Future<Position?> Function()? lastKnown,
  void Function(String step)? onStep,
}) {
  return GpsLocationService(
    isServiceEnabled: () async {
      onStep?.call('service');
      return serviceEnabled;
    },
    checkPermission: () async {
      onStep?.call('check');
      return checkResult;
    },
    requestPermission: () async {
      onStep?.call('request');
      return requestResult;
    },
    getCurrentPosition: current ??
        () async {
          onStep?.call('current');
          return _pos(-6.1754, 106.8272);
        },
    getLastKnownPosition: lastKnown ??
        () async {
          onStep?.call('lastKnown');
          return null;
        },
  );
}

void main() {
  group('GpsLocationService.fetchCoordinates', () {
    test('layanan lokasi mati -> serviceDisabled, GPS tidak dipanggil',
        () async {
      final steps = <String>[];
      final result = await _service(
        serviceEnabled: false,
        onStep: steps.add,
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.serviceDisabled);
      expect(result.hasCoordinates, isFalse);
      expect(steps, ['service']);
    });

    test('izin ditolak lalu ditolak lagi saat diminta -> permissionDenied',
        () async {
      final result = await _service(
        checkResult: LocationPermission.denied,
        requestResult: LocationPermission.denied,
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.permissionDenied);
      expect(result.hasCoordinates, isFalse);
    });

    test('izin awal ditolak, diberikan saat diminta -> lanjut ambil posisi',
        () async {
      final result = await _service(
        checkResult: LocationPermission.denied,
        requestResult: LocationPermission.whileInUse,
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.success);
      expect(result.latitude, -6.1754);
      expect(result.longitude, 106.8272);
    });

    test('izin ditolak permanen -> permissionDeniedForever, tidak meminta',
        () async {
      final steps = <String>[];
      final result = await _service(
        checkResult: LocationPermission.deniedForever,
        onStep: steps.add,
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.permissionDeniedForever);
      expect(steps, isNot(contains('request')));
      expect(steps, isNot(contains('current')));
    });

    test('posisi segar berhasil -> success + koordinat', () async {
      final result = await _service(
        current: () async => _pos(-6.2, 106.8),
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.success);
      expect(result.hasCoordinates, isTrue);
      expect(result.latitude, -6.2);
      expect(result.longitude, 106.8);
    });

    test('GPS segar timeout -> fallback posisi terakhir (successLastKnown)',
        () async {
      final result = await _service(
        current: () async => throw TimeoutException('sinyal lambat'),
        lastKnown: () async => _pos(-6.1754, 106.8272),
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.successLastKnown);
      expect(result.hasCoordinates, isTrue);
      expect(result.latitude, -6.1754);
      expect(result.longitude, 106.8272);
    });

    test('GPS segar error umum -> tetap coba posisi terakhir', () async {
      final result = await _service(
        current: () async => throw Exception('provider mati'),
        lastKnown: () async => _pos(-6.3, 106.9),
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.successLastKnown);
      expect(result.latitude, -6.3);
    });

    test('GPS gagal dan tidak ada posisi terakhir -> unavailable', () async {
      final result = await _service(
        current: () async => throw TimeoutException('sinyal lambat'),
        lastKnown: () async => null,
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.unavailable);
      expect(result.hasCoordinates, isFalse);
      expect(result.latitude, isNull);
    });

    test('posisi terakhir ikut error -> unavailable, tidak melempar',
        () async {
      final result = await _service(
        current: () async => throw TimeoutException('sinyal lambat'),
        lastKnown: () async => throw Exception('db rusak'),
      ).fetchCoordinates();
      expect(result.status, GpsLocationStatus.unavailable);
    });
  });
}
