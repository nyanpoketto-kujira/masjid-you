import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

/// Manager siklus waktu shalat otomatis di sisi TV.
///
/// Urutan fase: `normal` -> `preAdhan` -> `adhan` -> `preIqomah` -> `shalat` -> `normal`.
/// Khusus hari Jumat saat shalat Dzuhur, `adhan` dilanjutkan ke `khutbah`
/// sebelum `preIqomah` (sesuai alur shalat Jumat di Indonesia).
/// - Auto-start dari `normal` ketika waktu shalat berikutnya <= `preAdhanMinutes`.
/// - Transisi antar fase otomatis berdasarkan durasi dari `MosqueConfig`.
/// - Remote dapat melewati fase lewat `skipAdhan()`, `startIqomah()`, `startShalat()`, `finishShalat()`.
///
/// Di-drive oleh clock timer 1 detik di `_MasjidDisplayScreenState` (via `tick`),
/// sehingga tidak ada timer internal sendiri — bebas drift & bebas resource.
class PrayerStateMachine extends ChangeNotifier {
  MosqueConfig _config = const MosqueConfig();
  PrayerPhase _phase = PrayerPhase.normal;
  PrayerType? _prayer;
  DateTime _deadline = DateTime.now();
  Duration _remaining = Duration.zero;
  Duration _total = Duration.zero;
  bool _autoCycle = true;

  PrayerPhase get phase => _phase;
  PrayerType? get prayer => _prayer;
  Duration get remaining => _remaining;
  Duration get total => _total;
  bool get autoCycle => _autoCycle;

  /// Waktu mutlak berakhirnya fase saat ini (sumber kebenaran `remaining`).
  ///
  /// Dipakai UI untuk menghitung progress sub-detik (mulus 60 FPS) tanpa
  /// menunggu tick 1 detik.
  DateTime get deadline => _deadline;

  double get progress {
    if (_total <= Duration.zero) return 0;
    return (_remaining.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Inisialisasi ulang ke fase normal.
  void initialize(MosqueConfig config, {bool autoCycle = true}) {
    _config = config;
    _autoCycle = autoCycle;
    _enter(PrayerPhase.normal, null, DateTime.now());
  }

  /// Dipanggil saat konfigurasi baru datang dari Remote.
  void updateConfig(MosqueConfig config, DateTime now) {
    _config = config;
    if (_phase != PrayerPhase.normal) {
      final maxForPhase = _phase.durationFor(config);
      if (maxForPhase > Duration.zero && _remaining > maxForPhase) {
        _deadline = now.add(maxForPhase);
        _remaining = maxForPhase;
        _total = maxForPhase;
      }
    }
    notifyListeners();
  }

  /// Tick 1 detik: auto-start dari normal, atau hitung sisa waktu & transisi.
  void tick(DateTime now, PrayerSchedule schedule) {
    if (_phase == PrayerPhase.normal) {
      if (_autoCycle) {
        final next = schedule.nextPrayer;
        final until = schedule.timeUntilNextPrayer;
        if (next != null &&
            next != PrayerType.sunrise &&
            until != null &&
            !until.isNegative) {
          if (until <= Duration.zero) {
            _enter(PrayerPhase.adhan, next, now);
          } else if (until <=
              Duration(minutes: _config.preAdhanMinutes)) {
            _enter(PrayerPhase.preAdhan, next, now);
          }
        }
      }
    } else {
      _remaining = _deadline.difference(now);
      if (_remaining.isNegative) _remaining = Duration.zero;
      if (_remaining <= Duration.zero) {
        _advance(now);
      }
    }
    notifyListeners();
  }

  /// Skip Azan: dari ADHAN.
  /// - Hari biasa: langsung ke PRE_IQOMAH.
  /// - Hari Jumat (Dzuhur): langsung ke KHUTBAH.
  void skipAdhan({DateTime? now}) {
    if (_phase == PrayerPhase.adhan) {
      final n = now ?? DateTime.now();
      if (_isFriday(n) && _prayer == PrayerType.dhuhr) {
        _enter(PrayerPhase.khutbah, _prayer, n);
      } else {
        _enter(PrayerPhase.preIqomah, _prayer, n);
      }
    }
  }

  /// Selesai Khutbah: dari KHUTBAH langsung ke PRE_IQOMAH (jeda ikamah).
  void startIqomah() {
    if (_phase == PrayerPhase.khutbah) {
      _enter(PrayerPhase.preIqomah, _prayer, DateTime.now());
    }
  }

  /// Skip Ikamah / Mulai Shalat: dari PRE_IQOMAH langsung ke SHALAT.
  void startShalat() {
    if (_phase == PrayerPhase.preIqomah) {
      _enter(PrayerPhase.shalat, _prayer, DateTime.now());
    }
  }

  /// Selesaikan mode shalat: dari SHALAT langsung kembali ke NORMAL.
  void finishShalat() {
    if (_phase == PrayerPhase.shalat) {
      _enter(PrayerPhase.normal, null, DateTime.now());
    }
  }

  /// Paksa masuk fase tertentu (dari Menu Tes di Remote).
  ///
  /// Fase non-`normal` masuk dengan durasi penuh dari konfigurasi; shalat yang
  /// ditampilkan memakai jadwal berikutnya (atau mempertahankan yang sedang
  /// berjalan bila jadwal tidak tersedia).
  void forcePhase(
    PrayerPhase phase, {
    DateTime? now,
    PrayerSchedule? schedule,
  }) {
    final n = now ?? DateTime.now();
    if (phase == PrayerPhase.normal) {
      _enter(PrayerPhase.normal, null, n);
    } else {
      final prayer = schedule?.nextPrayer ?? _prayer;
      if (prayer != null) {
        _enter(phase, prayer, n);
      } else {
        // No prayer available - default to first prayer type for display purposes
        // but don't start a real cycle
        _phase = phase;
        _prayer = PrayerType.fajr;
        _total = phase.durationFor(_config);
        _remaining = _total;
        _deadline = n.add(_total);
        notifyListeners();
      }
    }
  }

  void _advance(DateTime now) {
    switch (_phase) {
      case PrayerPhase.preAdhan:
        _enter(PrayerPhase.adhan, _prayer, now);
      case PrayerPhase.adhan:
        // Hari Jumat (Dzuhur): azan pertama dilanjutkan ke khutbah.
        if (_isFriday(now) && _prayer == PrayerType.dhuhr) {
          _enter(PrayerPhase.khutbah, _prayer, now);
        } else {
          _enter(PrayerPhase.preIqomah, _prayer, now);
        }
      case PrayerPhase.khutbah:
        _enter(PrayerPhase.preIqomah, _prayer, now);
      case PrayerPhase.preIqomah:
        _enter(PrayerPhase.shalat, _prayer, now);
      case PrayerPhase.shalat:
        _enter(PrayerPhase.normal, null, now);
      case PrayerPhase.normal:
        break;
    }
  }

  bool _isFriday(DateTime date) => date.weekday == DateTime.friday;

  void _enter(PrayerPhase phase, PrayerType? prayer, DateTime now) {
    _phase = phase;
    _prayer = prayer;
    if (phase == PrayerPhase.normal) {
      _remaining = Duration.zero;
      _total = Duration.zero;
    } else {
      _total = phase.durationFor(_config);
      _remaining = _total;
      _deadline = now.add(_total);
    }
    notifyListeners();
  }
}
