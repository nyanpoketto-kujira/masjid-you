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
import 'widgets/running_text_bar.dart';
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
  const MasjidDisplayScreen({super.key});

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
    _recalculateSchedule();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
        _prayerSchedule = PrayerSchedule.calculate(_config, _now);
      });
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
    });
    _p2pHost.start();
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
              break;
            case SyncAction.updateRunningText:
              final list = (packet.payload['messages'] as List?)
                      ?.map((e) => RunningTextMessage.fromMap(
                          Map<String, dynamic>.from(e)))
                      .toList() ??
                  [];
              _runningTexts = list;
              break;
            case SyncAction.updateBanners:
              final list = (packet.payload['banners'] as List?)
                      ?.map((e) =>
                          MediaBanner.fromMap(Map<String, dynamic>.from(e)))
                      .toList() ??
                  [];
              _banners = list;
              break;
            case SyncAction.updateKas:
              final list = (packet.payload['transactions'] as List?)
                      ?.map((e) =>
                          KasTransaction.fromMap(Map<String, dynamic>.from(e)))
                      .toList() ??
                  [];
              _kasTransactions = list;
              break;
            default:
              break;
          }
        });
      },
    );

    await _localServer?.start(port: 8080);
    _fetchLocalIp();
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
    } catch (e) {
      print('Failed to get IP: $e');
    }
  }

  @override
  void dispose() {
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
          Image.network(
            'https://images.unsplash.com/photo-1564507592333-c60657eea523?q=80&w=1920',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: colorScheme.surfaceContainerLowest,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.85), // Soft dark filter for contrast
          ),

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
                          child: KasSummaryCard(
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
        ],
      ),
    );
  }
}
