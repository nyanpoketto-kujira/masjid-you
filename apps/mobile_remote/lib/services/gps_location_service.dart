import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Batas waktu menunggu sinyal GPS segar sebelum jatuh ke posisi
/// terakhir yang diketahui.
///
/// Dulu 15 detik dengan akurasi *high* (GPS murni): di dalam ruangan
/// sinyal satelit lambat/lemah sehingga hampir selalu timeout dan
/// error mentahnya (`TimeoutException ... Future not completed`)
/// tampil apa adanya ke pengguna. Untuk koordinat masjid, akurasi
/// medium (gabungan GPS + jaringan, ±100 m) lebih dari cukup —
/// jadwal sholat baru bergeser bila koordinat meleset berkilo-kilometer.
const Duration kGpsFixTimeLimit = Duration(seconds: 20);

/// Status hasil pengambilan koordinat GPS.
enum GpsLocationStatus {
  /// Posisi segar berhasil diambil dari GPS.
  success,

  /// GPS segar timeout/gagal, tetapi ada posisi terakhir yang
  /// diketahui sistem dan posisi itu yang dipakai.
  successLastKnown,

  /// Layanan lokasi (GPS) HP dalam keadaan mati.
  serviceDisabled,

  /// Izin lokasi ditolak pengguna (masih bisa diminta lagi).
  permissionDenied,

  /// Izin lokasi ditolak permanen; harus diaktifkan dari
  /// Pengaturan Android.
  permissionDeniedForever,

  /// GPS segar gagal dan tidak ada posisi terakhir sama sekali.
  unavailable,
}

/// Hasil pengambilan koordinat GPS: status + koordinat bila ada.
class GpsLocationResult {
  const GpsLocationResult(this.status, {this.latitude, this.longitude});

  final GpsLocationStatus status;
  final double? latitude;
  final double? longitude;

  /// True bila ada koordinat yang bisa dipakai (segar atau terakhir).
  bool get hasCoordinates =>
      status == GpsLocationStatus.success ||
      status == GpsLocationStatus.successLastKnown;
}

typedef GpsServiceEnabledCheck = Future<bool> Function();
typedef GpsPermissionCheck = Future<LocationPermission> Function();
typedef GpsCurrentPositionFetch = Future<Position> Function();
typedef GpsLastKnownPositionFetch = Future<Position?> Function();

/// Pengambil koordinat GPS untuk tombol "Ambil Koordinat dari GPS"
/// di Pengaturan.
///
/// Semua panggilan platform bisa disuntik (default: API statik
/// [Geolocator]) supaya alurnya teruji tanpa perangkat:
///
/// 1. Cek layanan lokasi aktif.
/// 2. Cek/minta izin lokasi.
/// 3. Ambil posisi segar (akurasi medium, batas
///    [kGpsFixTimeLimit]).
/// 4. Bila langkah 3 gagal (timeout sinyal lemah dsb.), jatuh ke
///    posisi terakhir yang diketahui — jangan langsung menyerah.
class GpsLocationService {
  GpsLocationService({
    GpsServiceEnabledCheck? isServiceEnabled,
    GpsPermissionCheck? checkPermission,
    GpsPermissionCheck? requestPermission,
    GpsCurrentPositionFetch? getCurrentPosition,
    GpsLastKnownPositionFetch? getLastKnownPosition,
  })  : _isServiceEnabled =
            isServiceEnabled ?? Geolocator.isLocationServiceEnabled,
        _checkPermission = checkPermission ?? Geolocator.checkPermission,
        _requestPermission =
            requestPermission ?? Geolocator.requestPermission,
        _getCurrentPosition = getCurrentPosition ??
            (() => Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.medium,
                    timeLimit: kGpsFixTimeLimit,
                  ),
                )),
        _getLastKnownPosition =
            getLastKnownPosition ?? Geolocator.getLastKnownPosition;

  final GpsServiceEnabledCheck _isServiceEnabled;
  final GpsPermissionCheck _checkPermission;
  final GpsPermissionCheck _requestPermission;
  final GpsCurrentPositionFetch _getCurrentPosition;
  final GpsLastKnownPositionFetch _getLastKnownPosition;

  /// Jalankan seluruh alur pengambilan koordinat. Tidak pernah
  /// melempar: semua kegagalan dipetakan ke [GpsLocationStatus].
  Future<GpsLocationResult> fetchCoordinates() async {
    if (!await _isServiceEnabled()) {
      return const GpsLocationResult(GpsLocationStatus.serviceDisabled);
    }

    var permission = await _checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _requestPermission();
      if (permission == LocationPermission.denied) {
        return const GpsLocationResult(GpsLocationStatus.permissionDenied);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return const GpsLocationResult(
        GpsLocationStatus.permissionDeniedForever,
      );
    }

    try {
      final pos = await _getCurrentPosition();
      return GpsLocationResult(
        GpsLocationStatus.success,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    } catch (_) {
      // Sinyal GPS segar gagal (paling sering: timeout di dalam
      // ruangan). Coba posisi terakhir yang diketahui sistem.
      try {
        final last = await _getLastKnownPosition();
        if (last != null) {
          return GpsLocationResult(
            GpsLocationStatus.successLastKnown,
            latitude: last.latitude,
            longitude: last.longitude,
          );
        }
      } catch (_) {
        // Abaikan: tetap laporkan unavailable di bawah.
      }
      return const GpsLocationResult(GpsLocationStatus.unavailable);
    }
  }
}
