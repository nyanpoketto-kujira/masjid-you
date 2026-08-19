import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_models/shared_models.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import 'theme/app_theme.dart';
import 'widgets/header_clock.dart';
import 'widgets/prayer_cards.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/kas_summary_card.dart';
import 'widgets/friday_staff_card.dart';
import 'widgets/running_text_bar.dart';
import 'widgets/prayer_state_overlay.dart';
import 'widgets/material_blob_background.dart';
import 'state/prayer_state_machine.dart';
import 'server/local_ws_server.dart';
import 'server/p2p_host_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide status bar and enable full screen TV experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Prevent TV display from sleeping
  try {
    await WakelockPlus.enable();
  } catch (e) {
    print('Wakelock enable failed: $e');
  }

  runApp(const MasjidYouTVApp());
}

class MasjidYouTVApp extends StatelessWidget {
  const MasjidYouTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjid You Display',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MasjidDisplayScreen(),
    );
  }
}

class MasjidDisplayScreen extends StatefulWidget {
  const MasjidDisplayScreen({
    super.key,
    this.initialConfig,
    this.autoPrayerCycle = true,
  });

  /// Konfigurasi awal (untuk test deterministik / pratinjau).
  final MosqueConfig? initialConfig;

  /// Aktifkan siklus waktu shalat otomatis (NORMAL -> PRE_ADHAN -> ...).
  final bool autoPrayerCycle;

  @override
  State<MasjidDisplayScreen> createState() => _MasjidDisplayScreenState();
}

class _MasjidDisplayScreenState extends State<MasjidDisplayScreen> {
  DateTime _now = DateTime.now();
  Timer? _clockTimer;
  LocalServer? _localServer;
  String? _localIp;
  final P2pHostService _p2pHost = P2pHostService();
  HotspotHostState? _p2pState;

  MosqueConfig _config = const MosqueConfig(
    name: 'Masjid Agung Al-Hikmah',
    address: 'Jl. Pemuda No. 45, Jakarta Pusat',
    latitude: -6.1754,
    longitude: 106.8272,
  );

  final PrayerStateMachine _prayerStateMachine = PrayerStateMachine();

  /// Bergantian antara Kartu Kas & Kartu Petugas Jumat (hari Jumat).
  bool _showKasCard = true;
  int _rightCardTick = 0;

  List<RunningTextMessage> _runningTexts = const [
    RunningTextMessage(
        id: '1',
        content: 'Jumat Keliling Pekan Ini Bersama Ustadz H. Ahmad Ridwan',
        category: 'Kajian'),
    RunningTextMessage(
        id: '2',
        content: 'Saldo Kas Masjid Per Minggu Ini: Rp 42.500.000',
        category: 'Kas'),
    RunningTextMessage(
        id: '3',
        content: 'Mohon Merapatkan Shaf dan Mematikan Nada Dering HP',
        category: 'Himbauan'),
  ];

  List<MediaBanner> _banners = const [
    MediaBanner(
      id: '1',
      header: 'INFO MASJID',
      title: 'Kajian Rutin Subuh',
      content: 'Setiap Hari Sabtu & Ahad bersama Dewan Asatidz',
      footer: 'Gratis & terbuka untuk umum',
    ),
    MediaBanner(
      id: '2',
      header: 'DONASI',
      title: 'Mari Tunaikan Infaq & Shadaqah',
      content: 'Salurkan kepedulian Anda untuk Pembangunan Ruang Belajar',
      footer: 'Amal Jariyah • Bisa Via Kotak Amal',
    ),
  ];

  List<KasTransaction> _kasTransactions = [
    KasTransaction(
      id: '1',
      type: KasType.masuk,
      amount: 25000000,
      description: 'Infaq Jumat Berkah',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    KasTransaction(
      id: '2',
      type: KasType.keluar,
      amount: 7500000,
      description: 'Pembangunan Ruang Belajar',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    KasTransaction(
      id: '3',
      type: KasType.masuk,
      amount: 17500000,
      description: 'Kotak Amal & Infaq',
      date: DateTime.now(),
    ),
  ];

  late PrayerSchedule _prayerSchedule;

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _config = widget.initialConfig!;
    }
    _recalculateSchedule();
    _prayerStateMachine.initialize(
      _config,
      autoCycle: widget.autoPrayerCycle,
    );
    _prayerStateMachine.addListener(_onStateMachineChanged);

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
        _prayerSchedule = PrayerSchedule.calculate(_config, _now);
        // Hari Jumat: kartu kanan bergantian tiap 10 detik secara absolut.
        if (_now.weekday == DateTime.friday && _now.second % 10 == 0) {
          _showKasCard = !_showKasCard;
        }
      });
      _prayerStateMachine.tick(_now, _prayerSchedule);
    });

    _initLocalServer();
    _initP2pHost();
  }

  void _initP2pHost() {
    _p2pHost.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _p2pState = state;
        });
      }
    }, onError: (error) {
      // Handle P2P host errors gracefully
      debugPrint('P2P Host error: $error');
      if (mounted) {
        setState(() {
          _p2pState = null;
        });
      }
    });
    try {
      _p2pHost.start();
    } catch (e) {
      debugPrint('Failed to start P2P host: $e');
    }
  }

  void _recalculateSchedule() {
    _prayerSchedule = PrayerSchedule.calculate(_config, _now);
  }

  Future<void> _initLocalServer() async {
    _localServer = LocalServer(
      onPacketReceived: (packet) {
        setState(() {
          switch (packet.action) {
            case SyncAction.updateConfig:
              _config = MosqueConfig.fromMap(packet.payload);
              _recalculateSchedule();
              _prayerStateMachine.updateConfig(_config, _now);
              break;
            case SyncAction.updateRunningText:
              final list = (packet.payload['messages'] as List?)
                      ?.map((e) {
                        if (e is Map) {
                          return RunningTextMessage.fromMap(
                              Map<String, dynamic>.from(e));
                        }
                        return null;
                      })
                      .whereType<RunningTextMessage>()
                      .toList() ??
                  [];
              _runningTexts = list;
              break;
            case SyncAction.updateBanners:
              final list = (packet.payload['banners'] as List?)
                      ?.map((e) {
                        if (e is Map) {
                          return MediaBanner.fromMap(
                              Map<String, dynamic>.from(e));
                        }
                        return null;
                      })
                      .whereType<MediaBanner>()
                      .toList() ??
                  [];
              _banners = list;
              break;
            case SyncAction.updateKas:
              final list = (packet.payload['transactions'] as List?)
                      ?.map((e) {
                        if (e is Map) {
                          return KasTransaction.fromMap(
                              Map<String, dynamic>.from(e));
                        }
                        return null;
                      })
                      .whereType<KasTransaction>()
                      .toList() ??
                  [];
              _kasTransactions = list;
              break;
            case SyncAction.skipAdhan:
              _prayerStateMachine.skipAdhan(now: _now);
              break;
            case SyncAction.startIqomah:
              _prayerStateMachine.startIqomah();
              break;
            case SyncAction.startShalat:
              _prayerStateMachine.startShalat();
              break;
            case SyncAction.finishShalat:
              _prayerStateMachine.finishShalat();
              break;
            case SyncAction.forcePhase:
              _prayerStateMachine.forcePhase(
                PrayerPhase.fromName(packet.payload['phase'] as String?),
                now: _now,
                schedule: _prayerSchedule,
              );
              break;
            case SyncAction.getInitialState:
              _broadcastState();
              break;
            default:
              break;
          }
        });
      },
    );

    try {
      await _localServer?.start(port: 8080);
      _fetchLocalIp();
    } catch (e) {
      debugPrint('Failed to start local server: $e');
    }
  }

  Future<void> _fetchLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            setState(() {
              _localIp = addr.address;
            });
            return;
          }
        }
      }
      // No non-loopback IPv4 found
      debugPrint('No non-loopback IPv4 address found');
    } catch (e) {
      debugPrint('Failed to get IP: $e');
    }
  }

  /// Kirim status fase state machine ke Remote (untuk indikator tombol aksi cepat).
  void _broadcastState() {
    _localServer?.broadcast(SyncPacket(
      action: SyncAction.stateUpdate,
      payload: {
        'phase': _prayerStateMachine.phase.name,
        'prayer': _prayerStateMachine.prayer?.name,
        'remainingSeconds': _prayerStateMachine.remaining.inSeconds,
        'totalSeconds': _prayerStateMachine.total.inSeconds,
      },
    ));
  }

  void _onStateMachineChanged() {
    if (!mounted) return;
    _broadcastState();
  }

  @override
  void dispose() {
    _prayerStateMachine.removeListener(_onStateMachineChanged);
    _prayerStateMachine.dispose();
    _clockTimer?.cancel();
    _localServer?.stop();
    _p2pHost.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Mosque Wallpaper with dark overlay for readability
          Image.asset(
            'assets/images/bg_mosque.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: colorScheme.surfaceContainerLowest,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.85), // Soft dark filter for contrast
          ),

          // Material You Dynamic Blob Background — di atas overlay, di bawah konten
          const MaterialBlobBackground(),

          // Main Content Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Top Bar: Clock, Mosque Info & Server IP
                  HeaderClock(
                    config: _config,
                    currentTime: _now,
                    serverIp: _localIp,
                    p2pActive: _p2pState?.isActive ?? false,
                    p2pSsid: _p2pState?.ssid,
                    p2pIp: _p2pState?.hostIpAddress,
                  ),

                  const SizedBox(height: 6),

                  // Middle: Banner Carousel & Kas Summary
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: BannerCarousel(banners: _banners),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: _now.weekday == DateTime.friday
                              ? AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.06),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _showKasCard
                                      ? KasSummaryCard(
                                          key: const ValueKey('kas-summary'),
                                          transactions: _kasTransactions,
                                        )
                                      : FridayStaffCard(
                                          key: const ValueKey('friday-staff'),
                                          khatib: _config.fridayKhatib,
                                          muadzin: _config.fridayMuadzin,
                                        ),
                                )
                              : KasSummaryCard(
                                  transactions: _kasTransactions,
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Prayer Cards Row
                  PrayerCardsRow(schedule: _prayerSchedule),

                  const SizedBox(height: 6),

                  // Bottom Running Text Bar
                  RunningTextBar(messages: _runningTexts),
                ],
              ),
            ),
          ),

          // Prayer State Machine Overlay (PRE_ADHAN / ADHAN / PRE_IQOMAH / SHALAT)
          AnimatedBuilder(
            animation: _prayerStateMachine,
            builder: (context, _) {
              return PrayerStateOverlay(
                phase: _prayerStateMachine.phase,
                prayerName:
                    _prayerStateMachine.prayer?.displayNameForDate(_now),
                remaining: _prayerStateMachine.remaining,
                total: _prayerStateMachine.total,
                deadline: _prayerStateMachine.deadline,
                fridayKhatib: _config.fridayKhatib,
                fridayMuadzin: _config.fridayMuadzin,
              );
            },
          ),
        ],
      ),
    );
  }
}
