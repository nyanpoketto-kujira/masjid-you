import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_models/shared_models.dart';

import 'theme/app_theme.dart';
import 'widgets/header_clock.dart';
import 'widgets/prayer_cards.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/side_card_rotator.dart';
import 'widgets/running_text_bar.dart';
import 'widgets/prayer_state_overlay.dart';
import 'widgets/material_blob_background.dart';
import 'widgets/admin_menu_overlay.dart';
import 'widgets/background_slideshow.dart';
import 'state/prayer_state_machine.dart';
import 'state/tv_store.dart';
import 'state/local_ip.dart';
import 'server/local_ws_server.dart';
import 'server/bluetooth_host_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Data tanggal locale id_ID untuk intl — tanpa inisialisasi ini,
  // DateFormat('...', 'id_ID') di HeaderClock selalu jatuh ke
  // fallback bahasa Inggris (ADR-033).
  await initializeDateFormatting('id_ID', null);

  // Hide status bar and enable full screen TV experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Prevent TV display from sleeping
  try {
    await WakelockPlus.enable();
  } catch (e) {
    debugPrint('Wakelock enable failed: $e');
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

  /// Host Bluetooth Classic (RFCOMM) — jalur sync langsung tanpa router.
  BluetoothHostService? _btHost;
  BluetoothHostState? _btState;

  /// Koneksi Bluetooth dimulai manual dari menu admin (toggle), bukan otomatis
  /// saat app dibuka — supaya tidak ada popup discoverable sistem.
  bool _btEnabled = false;

  /// Overlay menu admin tampil saat tombol Back remote ditekan.
  bool _showAdminMenu = false;

  /// Alamat IPv4 lokal TV untuk menu admin (ADR-029); di-refresh tiap
  /// menu admin dibuka. `null` = belum dimuat / tidak ada jaringan.
  String? _localIp;

  MosqueConfig _config = const MosqueConfig(
    name: 'Masjid Agung Al-Hikmah',
    address: 'Jl. Pemuda No. 45, Jakarta Pusat',
    latitude: -6.1754,
    longitude: 106.8272,
  );

  final PrayerStateMachine _prayerStateMachine = PrayerStateMachine();

  /// Kartu gambar khusus slot samping (dikelola dari Remote).
  List<SpecialImage> _sideImages = const [];

  /// Gambar latar slideshow (dikelola dari Remote, ADR-031).
  List<BackgroundImage> _backgroundImages = const [];

  /// Logo masjid untuk header (dikelola dari Remote, ADR-032).
  /// [_mosqueLogoBytes] adalah hasil decode [_mosqueLogoBase64] yang
  /// di-cache: HeaderClock me-rebuild tiap detik untuk jam, jadi
  /// decode base64 tidak boleh terjadi di jalur build. Base64 rusak
  /// -> bytes `null` -> header tampil tanpa logo (fail-soft).
  String? _mosqueLogoBase64;
  Uint8List? _mosqueLogoBytes;

  /// Pasang logo baru (atau hapus dengan `null`/kosong) + decode
  /// sekali di sini. Dipanggil dalam konteks setState oleh pemanggil.
  void _applyMosqueLogo(String? logoBase64) {
    _mosqueLogoBase64 =
        (logoBase64 == null || logoBase64.isEmpty) ? null : logoBase64;
    if (_mosqueLogoBase64 == null) {
      _mosqueLogoBytes = null;
      return;
    }
    try {
      _mosqueLogoBytes = base64Decode(_mosqueLogoBase64!);
    } catch (_) {
      _mosqueLogoBytes = null;
    }
  }

  /// Perangkai transfer ter-chunk Bluetooth (ADR-031): paket gambar
  /// besar tiba sebagai rangkaian `chunkedData` dan baru diterapkan
  /// setelah lengkap.
  final ChunkReassembler _chunkReassembler = ChunkReassembler();

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

  /// Penyimpanan lokal data resmi TV (trust source).
  final TvStore _store = TvStore();

  /// `true` bila TV sudah punya data resmi (hasil persist lokal atau kiriman
  /// DKM). Selama `false`, Remote boleh mengirim datanya sekali (bootstrap).
  bool _hasStoredData = false;

  /// Kontrol tampilan dari Remote (Beranda): mode senyap & standby.
  /// Dilaporkan balik ke Remote lewat `stateUpdate`.
  bool _muted = false;
  bool _standby = false;

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

    // Tombol OK remote TV = skip fase (ADR-030). Handler tingkat
    // HardwareKeyboard agar tetap bekerja walau fokus sedang di konten
    // utama; handler mengembalikan false saat menu admin terbuka supaya
    // OK tetap memilih item menu (lihat _handleTvRemoteKey).
    HardwareKeyboard.instance.addHandler(_handleTvRemoteKey);

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
        _prayerSchedule = PrayerSchedule.calculate(_config, _now);
      });
      _prayerStateMachine.tick(_now, _prayerSchedule);
    });

    // Muat data resmi lebih dulu, baru nyalakan jalur sync: TV harus jadi
    // trust source yang sudah berisi data sebelum Remote menyambung.
    _initFromStore();
  }

  /// Muat data tersimpan (bila ada), lalu hidupkan server/host sync.
  Future<void> _initFromStore() async {
    StateSnapshot? loaded;
    try {
      loaded = await _store.load();
    } catch (e) {
      debugPrint('Failed to load stored TV data: $e');
    }
    if (loaded != null && mounted) {
      final snapshot = loaded;
      setState(() {
        _config = snapshot.config;
        _runningTexts = snapshot.runningTexts;
        _banners = snapshot.banners;
        _kasTransactions = snapshot.kasTransactions;
        _sideImages = snapshot.sideImages;
        _backgroundImages = snapshot.backgroundImages;
        _applyMosqueLogo(snapshot.mosqueLogo);
        _hasStoredData = true;
      });
      _recalculateSchedule();
      _prayerStateMachine.updateConfig(_config, _now);
    }

    final display = await _store.loadDisplayState();
    if (mounted) {
      setState(() {
        _muted = display.muted;
        _standby = display.standby;
      });
    }

    await _initLocalServer();
    // Bluetooth HOST TIDAK dimulai di sini. Koneksi hanya aktif setelah
    // admin menyalakan toggle di menu admin (lihat `_toggleBluetooth`),
    // agar tidak ada popup discoverable sistem saat app pertama dibuka.
    await _initBluetoothHost();
  }

  void _recalculateSchedule() {
    _prayerSchedule = PrayerSchedule.calculate(_config, _now);
  }

  Future<void> _initLocalServer() async {
    _localServer = LocalServer(
      onPacketReceived: _handleSyncPacket,
    );

    try {
      await _localServer?.start(port: 8080);
    } catch (e) {
      debugPrint('Failed to start local server: $e');
    }
  }

  /// Aplikasi paket sync yang masuk (via WebSocket LAN atau Bluetooth).
  void _handleSyncPacket(SyncPacket packet) {
    if (!mounted) return;
    // Transfer ter-chunk (ADR-031): rangkai dulu; paket aslinya baru
    // diproses setelah lengkap. Chunk yang gagal dirangkai dibuang —
    // gambar korup tidak pernah diterapkan.
    if (packet.action == SyncAction.chunkedData) {
      final assembled = _chunkReassembler.addChunk(packet);
      if (assembled != null) {
        _handleSyncPacket(assembled);
      } else if (_chunkReassembler.lastError != null) {
        debugPrint(
            'Chunk transfer dibuang: ${_chunkReassembler.lastError}');
      }
      return;
    }
    switch (packet.action) {
      case SyncAction.updateConfig:
        _config = MosqueConfig.fromMap(packet.payload);
        _recalculateSchedule();
        _prayerStateMachine.updateConfig(_config, _now);
        _hasStoredData = true;
        _store.saveConfig(_config);
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
        _hasStoredData = true;
        _store.saveRunningTexts(list);
        break;
      case SyncAction.updateBanners:
        final list = (packet.payload['banners'] as List?)
                ?.map((e) {
                  if (e is Map) {
                    return MediaBanner.fromMap(Map<String, dynamic>.from(e));
                  }
                  return null;
                })
                .whereType<MediaBanner>()
                .toList() ??
            [];
        _banners = list;
        _hasStoredData = true;
        _store.saveBanners(list);
        break;
      case SyncAction.updateKas:
        final list = (packet.payload['transactions'] as List?)
                ?.map((e) {
                  if (e is Map) {
                    return KasTransaction.fromMap(Map<String, dynamic>.from(e));
                  }
                  return null;
                })
                .whereType<KasTransaction>()
                .toList() ??
            [];
        _kasTransactions = list;
        _hasStoredData = true;
        _store.saveKas(list);
        break;
      case SyncAction.updateSideImages:
        final list = (packet.payload['images'] as List?)
                ?.map((e) {
                  if (e is Map) {
                    return SpecialImage.fromMap(Map<String, dynamic>.from(e));
                  }
                  return null;
                })
                .whereType<SpecialImage>()
                .toList() ??
            [];
        _sideImages = list;
        _hasStoredData = true;
        _store.saveSideImages(list);
        break;
      case SyncAction.updateBackgroundImages:
        final list = (packet.payload['images'] as List?)
                ?.map((e) {
                  if (e is Map) {
                    return BackgroundImage.fromMap(
                        Map<String, dynamic>.from(e));
                  }
                  return null;
                })
                .whereType<BackgroundImage>()
                .toList() ??
            [];
        _backgroundImages = list;
        _hasStoredData = true;
        _store.saveBackgroundImages(list);
        break;
      case SyncAction.updateLogo:
        // Payload `logoBase64`: string base64 gambar asli; null /
        // kosong / bukan string = logo dihapus (ADR-032).
        final rawLogo = packet.payload['logoBase64'];
        _applyMosqueLogo(rawLogo is String ? rawLogo : null);
        _hasStoredData = true;
        _store.saveMosqueLogo(_mosqueLogoBase64);
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
      case SyncAction.setMuted:
        _muted = packet.payload['muted'] == true;
        _store.saveMuted(_muted);
        _broadcastState();
        break;
      case SyncAction.setStandby:
        _standby = packet.payload['standby'] == true;
        _store.saveStandby(_standby);
        _broadcastState();
        break;
      case SyncAction.getInitialState:
        // Remote minta keadaan awal: kirim snapshot lengkap (data resmi TV)
        // DITAMBAH stateUpdate agar tombol aksi cepat Remote tetap hidup.
        _broadcastSnapshot();
        _broadcastState();
        break;
      default:
        break;
    }
  }

  StreamSubscription<BluetoothHostState>? _btStateSub;

  Future<void> _initBluetoothHost() async {
    _btHost = BluetoothHostService(
      onPacketReceived: _handleSyncPacket,
    );
    _btStateSub?.cancel();
    _btStateSub = _btHost!.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _btState = state;
        });
      }
    });
    _btState = _btHost!.currentState;

    // Host TIDAK di-start di sini — menunggu toggle admin.
    // Hanya dipakai pada perangkat non-Android (test/web) agar host siap.
    if (!kIsWeb && !Platform.isAndroid) {
      await _btHost!.start();
      if (mounted) {
        setState(() {
          _btState = _btHost!.currentState;
        });
      }
      await _maybeRunIntroPairing();
    }
  }

  /// Jendela Mode Pairing otomatis SATU kali untuk instalasi baru
  /// (ADR-029): setelah host start, bila flag permanen belum terpasang,
  /// pasang flag lebih dulu (reboot di tengah jendela tidak mengulang),
  /// lalu buka Mode Pairing 300 detik agar pairing pertama gampang.
  /// Setelah itu TV tidak pernah membuka discoverable sendiri lagi.
  Future<void> _maybeRunIntroPairing() async {
    final host = _btHost;
    if (host == null || !host.isRunning) return;
    bool done;
    try {
      done = await _store.loadPairingIntroDone();
    } catch (_) {
      done = false;
    }
    if (done) return;
    await _store.savePairingIntroDone();
    await host.startPairingMode();
    if (mounted) {
      setState(() {
        _btState = host.currentState;
      });
    }
  }

  /// Pemicu manual Mode Pairing dari menu admin TV (ADR-029).
  Future<void> _startPairingMode() async {
    final host = _btHost;
    if (host == null || !mounted) return;
    await host.startPairingMode();
    if (mounted) {
      setState(() {
        _btState = host.currentState;
      });
    }
  }

  /// Muat ulang alamat IP lokal TV (untuk teks IP di menu admin).
  Future<void> _refreshLocalIp() async {
    final ip = await loadLocalIpv4();
    if (mounted) {
      setState(() {
        _localIp = ip;
      });
    }
  }

  /// Nyalakan/matikan koneksi Bluetooth dari menu admin.
  ///
  /// Saat ON: regenerate PIN (dilakukan di dalam service) dan mulai host.
  /// Host tidak lagi meminta discoverable berkala (ADR-029); satu-satunya
  /// discoverable otomatis adalah jendela intro instalasi baru lewat
  /// [_maybeRunIntroPairing]. Saat OFF: stop host dan putuskan koneksi.
  Future<void> _toggleBluetooth(bool enable) async {
    final host = _btHost;
    if (host == null || !mounted) return;

    if (enable) {
      // PIN di-regenerate tiap ON agar PIN lama tidak dipakai ulang.
      setState(() {
        _btEnabled = true;
        _btState = host.currentState;
      });
      await host.start();
      if (mounted) {
        setState(() {
          _btState = host.currentState;
        });
      }
      await _maybeRunIntroPairing();
    } else {
      await host.stop();
      if (mounted) {
        setState(() {
          _btEnabled = false;
          _btState = host.currentState;
        });
      }
    }
  }

  /// Kirim snapshot lengkap TV (config + teks berjalan + banner + kas) ke
  /// Remote — TV sebagai sumber kebenaran data.
  void _broadcastSnapshot() {
    final packet = SyncPacket(
      action: SyncAction.stateSnapshot,
      payload: StateSnapshot(
        config: _config,
        runningTexts: _runningTexts,
        banners: _banners,
        kasTransactions: _kasTransactions,
        sideImages: _sideImages,
        backgroundImages: _backgroundImages,
        mosqueLogo: _mosqueLogoBase64,
        hasData: _hasStoredData,
      ).toMap(),
    );
    _localServer?.broadcast(packet);
    _btHost?.broadcast(packet);
  }

  /// Kirim status fase state machine ke Remote (untuk indikator tombol aksi cepat).
  void _broadcastState() {
    final packet = SyncPacket(
      action: SyncAction.stateUpdate,
      payload: {
        'phase': _prayerStateMachine.phase.name,
        'prayer': _prayerStateMachine.prayer?.name,
        'remainingSeconds': _prayerStateMachine.remaining.inSeconds,
        'totalSeconds': _prayerStateMachine.total.inSeconds,
        'muted': _muted,
        'standby': _standby,
      },
    );
    _localServer?.broadcast(packet);
    _btHost?.broadcast(packet);
  }

  /// Handler tombol remote TV fisik (ADR-030).
  ///
  /// OK (`select`/`enter`, DPAD_CENTER) saat menu admin TERTUTUP dan ada
  /// fase shalat aktif -> lewati ke fase berikutnya. Di luar kondisi itu
  /// handler mengembalikan `false` agar event diteruskan ke rantai fokus:
  /// menu admin yang terbuka tetap memakai OK untuk memilih item, dan
  /// fase `normal` tidak terpengaruh.
  bool _handleTvRemoteKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_showAdminMenu) return false;
    if (event.logicalKey != LogicalKeyboardKey.select &&
        event.logicalKey != LogicalKeyboardKey.enter) {
      return false;
    }
    if (_prayerStateMachine.phase == PrayerPhase.normal) return false;
    _prayerStateMachine.skipToNextPhase(now: _now);
    return true;
  }

  void _onStateMachineChanged() {
    if (!mounted) return;
    _broadcastState();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleTvRemoteKey);
    _prayerStateMachine.removeListener(_onStateMachineChanged);
    _prayerStateMachine.dispose();
    _clockTimer?.cancel();
    _localServer?.stop();
    _btStateSub?.cancel();
    _btStateSub = null;
    _btHost?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Status Mode Bluetooth untuk chip header.
    late String? btStatus;
    late bool btError;
    final bt = _btState;
    if (bt == null) {
      btStatus = null;
      btError = false;
    } else {
      switch (bt.status) {
        case BluetoothHostStatus.connected:
          // Connected tapi belum autentikasi = Remote belum memasukkan PIN.
          btStatus = bt.isAuthenticated
              ? 'Mode Bluetooth: aktif (${bt.peerName ?? 'TV'})'
              : 'Mode Bluetooth: menunggu PIN dari Remote...';
          btError = false;
          break;
        case BluetoothHostStatus.error:
          btStatus = 'Mode Bluetooth: ${bt.error ?? 'gagal — cek Bluetooth'}';
          btError = true;
          break;
        case BluetoothHostStatus.idle:
          btStatus = 'Mode Bluetooth: tidak aktif';
          btError = false;
          break;
        case BluetoothHostStatus.listening:
          btStatus = 'Mode Bluetooth: siap — tunggu Remote menyambung';
          btError = false;
          break;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Tombol Back remote: buka menu admin. Bila panel sudah terbuka,
        // PopScope milik panel (di dalamnya) yang menangani Back untuk
        // menutup — root tidak melakukan apa pun agar tidak dobel-toggle.
        // TV tidak boleh exit dari Back.
        if (!_showAdminMenu) {
          setState(() {
            _showAdminMenu = true;
          });
          // Segarkan alamat IP yang ditampilkan di menu admin (ADR-029).
          unawaited(_refreshLocalIp());
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Latar TV: slideshow gambar dari Remote (ADR-031); kosong ->
            // fallback wallpaper masjid bawaan. Overlay gelap 0.60 di
            // atasnya menjaga keterbacaan teks (diterangkan dari 0.85
            // agar latar lebih hidup, ADR-031).
            BackgroundSlideshow(
              images: _backgroundImages,
              intervalSeconds: _config.backgroundSlideSeconds,
              fallback: Image.asset(
                'assets/images/bg_mosque.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colorScheme.surfaceContainerLowest,
                ),
              ),
            ),
            Container(
              color: Colors.black
                  .withValues(alpha: 0.60), // Filter gelap keterbacaan
            ),

            // Material You Dynamic Blob Background — di atas overlay, di bawah konten
            const MaterialBlobBackground(),

            // Main Content Layer
            SafeArea(
              child: Column(
                children: [
                  // Konten atas (header, banner/kas, jadwal) diberi padding;
                  // running text di bawah TANPA padding agar full-width.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                      child: Column(
                        children: [
                          // Top Bar: Clock, Mosque Info (chip status sync dihapus —
                          // ruang vertikal dipakai konten utama)
                          HeaderClock(
                            config: _config,
                            currentTime: _now,
                            logoBytes: _mosqueLogoBytes,
                          ),

                          const SizedBox(height: 6),

                          // Middle: Banner Carousel & rotasi kartu samping
                          // [Kas -> Petugas Jumat -> Gambar khusus 1..n -> ulang]
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
                                  child: SideCardRotator(
                                    config: _config,
                                    transactions: _kasTransactions,
                                    images: _sideImages,
                                    date: _now,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Prayer Cards Row
                          PrayerCardsRow(
                            schedule: _prayerSchedule,
                            hasFridayPrayer: _config.hasFridayPrayer,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Running Text Bar — full-width, menempel dasar layar.
                  RunningTextBar(messages: _runningTexts),
                ],
              ),
            ),

            // Prayer State Machine Overlay (PRE_ADHAN / ADHAN / PRE_IQOMAH / SHALAT)
            AnimatedBuilder(
              animation: _prayerStateMachine,
              builder: (context, _) {
                return PrayerStateOverlay(
                  phase: _prayerStateMachine.phase,
                  prayerName: _prayerStateMachine.prayer?.displayNameForDate(
                    _now,
                    hasFridayPrayer: _config.hasFridayPrayer,
                  ),
                  remaining: _prayerStateMachine.remaining,
                  total: _prayerStateMachine.total,
                  deadline: _prayerStateMachine.deadline,
                  fridayKhatib: _config.fridayKhatib,
                  fridayMuadzin: _config.fridayMuadzin,
                );
              },
            ),

            // Indikator mode senyap (dari Remote): ikon kecil pojok kanan
            // bawah, di atas running text, tidak mengganggu konten.
            if (_muted && !_standby)
              const Positioned(
                right: 16,
                bottom: 44,
                child: Icon(Icons.volume_off, color: Colors.white54, size: 28),
              ),

            // Standby (dari Remote): layar hitam penuh. Di bawah menu admin
            // agar admin lokal tetap bisa membuka panel.
            if (_standby)
              Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.power_settings_new,
                  color: Colors.white10,
                  size: 64,
                ),
              ),

            // Menu Admin (dibuka dengan tombol Back remote). Paling atas agar
            // menutupi seluruh konten & overlay shalat.
            if (_showAdminMenu)
              AdminMenuOverlay(
                btEnabled: _btEnabled,
                pin: _btHost?.pin,
                statusText: btStatus,
                isError: btError,
                ipText: formatTvIpText(_localIp),
                pairingActive: _btHost?.pairingActive ?? false,
                pairingRemainingSeconds:
                    _btHost?.pairingRemaining.inSeconds ?? 0,
                onStartPairingMode: _startPairingMode,
                onToggleBluetooth: _toggleBluetooth,
                onClose: () {
                  setState(() {
                    _showAdminMenu = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
