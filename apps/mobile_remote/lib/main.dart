import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_models/shared_models.dart';
import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ws_client.dart';
import '../services/bluetooth_client_service.dart';
import '../services/remote_cache_store.dart';
import '../services/backup_service.dart';
import '../theme/remote_theme.dart';

import 'screens/settings/settings_tab.dart';
import 'screens/content/running_text_subtab.dart';
import 'screens/content/banners_subtab.dart';
import 'screens/content/kas_subtab.dart';
import 'screens/connection/connection_gateway_screen.dart';
import 'screens/simulation/simulation_tab.dart';

import '../widgets/m3_pressable.dart';
import '../widgets/playful_nav_icon.dart';

const List<String> _runningCategories = [
  'Pengumuman',
  'Kajian',
  'Kas',
  'Himbauan',
  'Infaq',
  'Umum',
];

class RemoteHomeScreen extends StatefulWidget {
  const RemoteHomeScreen({super.key});

  @override
  State<RemoteHomeScreen> createState() => _RemoteHomeScreenState();
}

/// Global navigator key — dipakai dialog koneksi (PIN, resolusi sinkronisasi)
/// agar tetap punya context yang valid walau body sedang bertransisi dari
/// layar sambungan ke menu utama (menghindari dependensi pada subtree yang
/// dihancurkan di tengah transisi).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Global messenger key — SnackBar harus dipasang ke state yang stabil
/// (di atas root Scaffold) supaya tidak mereferensi ScaffoldState dari
/// subtree yang sedang dibongkar saat transisi gatekeeper <-> menu utama.
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Dialog input PIN 4-digit untuk autentikasi Bluetooth.
///
/// Widget ini MEMILIKI [TextEditingController]-nya sendiri dan membuangnya
/// di [State.dispose]. Pada versi sebelumnya controller dibuat di pemanggil
/// lalu di-dispose manual dari `.then()` milik `showDialog` — controller itu
/// masih dipakai TextField saat route dialog sedang animasi keluar, sehingga
/// muncul exception "TextEditingController was used after being disposed".
class _PinDialog extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;

  const _PinDialog({required this.onSubmit, required this.onCancel});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _pinController.text.trim();
    if (pin.length != 4) return;
    widget.onSubmit(pin);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.password, size: 40),
      title: const Text('Masukkan PIN TV'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TV meminta PIN untuk mengizinkan koneksi ini. Lihat PIN '
              'di Menu Admin TV (tekan tombol Back pada remote).',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              autofocus: true,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, letterSpacing: 12),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                counterText: '',
                hintText: '••••',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Hubungkan'),
        ),
      ],
    );
  }
}

class _RemoteHomeScreenState extends State<RemoteHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _tabIndex = 0;

  late final TabController _mainTabController;
  late final TabController _subTabController;
  bool _syncingControllers = false;

  final _ipController = TextEditingController(text: '192.168.1.');
  final _client = RemoteWsClient();
  final _btClient = BluetoothClientService();
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _wasConnected = false;
  bool _showDisconnectedNotice = false;
  bool _syncDialogOpen = false;
  String? _lastConnectionKind;
  BluetoothDeviceInfo? _lastBtDevice;

  // Status Bluetooth (Mode Direct sul pandana).
  bool _btIsScanning = false;
  bool _btConnected = false;
  List<BluetoothDeviceInfo> _btDevices = [];
  String _btStatus = 'Bluetooth: Stanby';
  StreamSubscription<BluetoothClientState>? _btStateSub;

  bool _hasUnsyncedChanges = false;

  /// `true` bila dialog PIN sedang terbuka (dipakai `_closePinDialog`).
  bool _pinDialogOpen = false;

  /// State Bluetooth tertunda selama dialog PAIRing terbuka; diterapkan
  /// setelah dialog ditutup agar rebuild tidak membongkar route dialog.
  BluetoothClientState? _pendingBtState;

  /// Cache lokal snapshot TV (trust source) — nilai awal form saat startup.
  final RemoteCacheStore _cacheStore = RemoteCacheStore();

  /// Export/import backup data masjid ke/dari file JSON.
  final BackupService _backupService = BackupService();

  /// Penjaga agar bootstrap (Remote -> TV) hanya terjadi sekali per sesi,
  /// dan hanya bila TV masih kosong.
  bool _didBootstrapPush = false;

  MosqueConfig _config = const MosqueConfig(
    name: 'Masjid Agung Al-Hikmah',
    address: 'Jl. Pemuda No. 45, Jakarta Pusat',
    latitude: -6.1754,
    longitude: 106.8272,
  );

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final Map<PrayerType, TextEditingController> _prayerOffsetControllers = {
    for (final type in kAllPrayerTypes) type: TextEditingController(),
  };
  final _preAdhanController = TextEditingController();
  final _adhanController = TextEditingController();
  final _preIqomahController = TextEditingController();
  final _shalatController = TextEditingController();
  final _khutbahController = TextEditingController();
  final _fridayKhatibController = TextEditingController();
  final _fridayMuadzinController = TextEditingController();
  bool _isFetchingLocation = false;
  final _runningTextController = TextEditingController();
  String _runningCategory = _runningCategories.first;

  final _bannerHeaderController = TextEditingController();
  final _bannerTitleController = TextEditingController();
  final _bannerContentController = TextEditingController();
  final _bannerFooterController = TextEditingController();

  final _kasAmountController = TextEditingController();
  final _kasDescriptionController = TextEditingController();
  KasType _kasType = KasType.masuk;

  /// Status fase TV terakhir yang diterima lewat `SyncAction.stateUpdate`.
  PrayerPhase _tvPhase = PrayerPhase.normal;

  final List<KasTransaction> _kasTransactions = [
    KasTransaction(
      id: '1',
      type: KasType.masuk,
      amount: 5000000,
      description: 'Kotak Amal Jumat Utama',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    KasTransaction(
      id: '2',
      type: KasType.keluar,
      amount: 750000,
      description: 'Kebersihan & Listrik Masjid',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<RunningTextMessage> _runningTexts = [
    const RunningTextMessage(
        id: '1',
        content: 'Jumat Keliling Pekan Ini Bersama Ustadz H. Ahmad Ridwan',
        category: 'Kajian'),
    const RunningTextMessage(
        id: '2',
        content: 'Saldo Kas Masjid Per Minggu Ini: Rp 42.500.000',
        category: 'Kas'),
    const RunningTextMessage(
        id: '3',
        content: 'Mohon Merapatkan Shaf dan Mematikan Nada Dering HP',
        category: 'Himbauan'),
  ];

  final List<MediaBanner> _banners = [
    const MediaBanner(
      id: '1',
      header: 'INFO MASJID',
      title: 'Kajian Rutin Subuh',
      content: 'Setiap Hari Sabtu & Ahad bersama Dewan Asatidz',
      footer: 'Gratis & terbuka untuk umum',
    ),
    const MediaBanner(
      id: '2',
      header: 'DONASI',
      title: 'Mari Tunaikan Infaq & Shadaqah',
      content: 'Salurkan kepedulian Anda untuk Pembangunan Ruang Belajar',
      footer: 'Amal Jariyah • Bisa Via Kotak Amal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 5, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);
    _mainTabController.addListener(_handleMainTabChange);
    _subTabController.addListener(_handleSubTabChange);
    _syncConfigControllers();

    WidgetsBinding.instance.addObserver(this);
    _client.onPacket = _handleTvPacket;
    _client.onConnected = () => _handleConnectionEstablished('ip');
    _client.onDisconnected = _handleTransportDisconnected;
    _btClient.onPacket = _handleTvPacket;
    // Pasrik bacak keluar WS -> mirror ke Bluetooth (agar jalur BT saja
    // yang tersambung, paket tetap terkirim).
    _client.onSendPacket = (packet) {
      _btClient.sendPacket(packet);
    };
    // TV meminta PIN: tampilkan dialog PIN.
    _btClient.onAuthChallenge = (challenge) {
      _showPinDialog();
    };
    // PIN benar: jalur siap — minta keadaan awal TV (trust source).
    _btClient.onAuthenticated = () {
      _closePinDialog();
      _handleConnectionEstablished('bluetooth');
    };
    // PIN salah / sesi tidak valid.
    _btClient.onAuthFailure = (failure) {
      if (mounted) {
        final message = failure.payload['error'] as String?;
        // Biarkan dialog PIN terbuka agar user bisa mengulang; tampilkan
        // pesan kesalahan.
        _showSnack(
          message ?? 'PIN salah — periksa PIN di menu admin TV.',
          background: Theme.of(context).colorScheme.error,
        );
      }
    };
    _btStateSub = _btClient.stateStream.listen((state) {
      if (!mounted) return;
      // Saat dialog PAIRing (PIN) terbuka, event state masih boleh masuk
      // (mis. status connecting -> error saat koneksi gagal/pembatalan).
      // Rebuild subtree di saat itu bisa membongkar route dialog yang masih
      // menjadi dependent tree -> assertion '_dependents.isEmpty'.
      // Tahan sampai dialog benar-benar tertutup, lalu terapkan state terakhir.
      if (_pinDialogOpen) {
        _pendingBtState = state;
        return;
      }
      final wasBtConnected = _btConnected;
      setState(() {
        _btConnected = state.isConnected;
        _btDevices = state.devices;
        _btIsScanning = state.isScanning;
        switch (state.status) {
          case BluetoothClientStatus.connected:
            _btStatus = 'Bluetooth: Terhubung ke TV (${state.peerName ?? 'TV'})';
            break;
          case BluetoothClientStatus.error:
            _btStatus = 'Bluetooth: ${state.error ?? 'gagal'}';
            break;
          case BluetoothClientStatus.discovering:
            _btStatus = 'Bluetooth: Mencari TV... (${state.devices.length} ditemukan)';
            break;
          case BluetoothClientStatus.reconnecting:
            _btStatus = 'Bluetooth: Menyambung ulang...';
            break;
          case BluetoothClientStatus.connecting:
            _btStatus = 'Bluetooth: Menyambung...';
            break;
          case BluetoothClientStatus.idle:
            _btStatus = state.devices.isEmpty
                ? 'Bluetooth: Stanby'
                : 'Bluetooth: Scan selesai. ${state.devices.length} perangkat.';
            break;
        }
      });
      if (wasBtConnected && !state.isConnected) {
        _handleTransportDisconnected();
      }
    });
    _loadStartupData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Hanya putus koneksi BT saat app benar-benar ditutup (detached).
    // paused/hidden terjadi pada aktivitas normal seperti image_picker,
    // dan tidak boleh memutus koneksi Bluetooth yang sedang digunakan.
    if (BluetoothClientService.shouldDisconnectBluetoothOnLifecycle(state)) {
      if (_btClient.isConnected || _btIsScanning || _btConnected) {
        _btClient.disconnect();
      }
      return;
    }
    
    // resumed: cek status BT nyata daripada asumsikan terhubung.
    if (state == AppLifecycleState.resumed) {
      // Tidak ada yang perlu dilakukan di sini—state stream akan
      // memberitahu jika ada perubahan koneksi. Jangan paksa apapun.
    }
  }

  /// Sinkronkan dua `TabController` agar swipe antar halaman menyatu.
  ///
  /// `_mainTabController` (5 halaman) menggerakkan seluruh aplikasi, sedangkan
  /// `_subTabController` (3 sub-tab Konten) hanya menggerakkan indikator
  /// Top Tab Bar. `_syncingControllers` memutus loop antar-listener.
  int _bottomNavIndexForPage(int page) {
    if (page >= 1 && page <= 3) return 1; // Konten
    if (page == 4) return 2; // Tes
    return 0; // Pengaturan
  }

  int _mainPageForBottomNav(int bottom, int currentSub) {
    switch (bottom) {
      case 1:
        return currentSub + 1; // Konten -> sub-tab terakhir dilihat
      case 2:
        return 4;
      default:
        return 0;
    }
  }

  void _handleMainTabChange() {
    if (_syncingControllers) return;
    _syncingControllers = true;
    final main = _mainTabController.index;
    if (main >= 1 && main <= 3) {
      _subTabController.index = main - 1;
    }
    if (mounted) {
      setState(() {
        _tabIndex = _bottomNavIndexForPage(main);
      });
    }
    _syncingControllers = false;
  }

  void _handleSubTabChange() {
    if (_syncingControllers) return;
    if (_subTabController.indexIsChanging) return;
    _syncingControllers = true;
    _mainTabController.animateTo(_subTabController.index + 1);
    _syncingControllers = false;
  }

  /// Isi seluruh field form dari [_config] (dipakai saat startup & setelah
  /// snapshot TV masuk).
  void _syncConfigControllers() {
    _nameController.text = _config.name;
    _addressController.text = _config.address;
    _latitudeController.text = _config.latitude.toStringAsFixed(6);
    _longitudeController.text = _config.longitude.toStringAsFixed(6);
    for (final type in kAllPrayerTypes) {
      _prayerOffsetControllers[type]!.text = _config.offsetFor(type).toString();
    }
    _preAdhanController.text = _config.preAdhanMinutes.toString();
    _adhanController.text = _config.adhanMinutes.toString();
    _preIqomahController.text = _config.preIqomahMinutes.toString();
    _shalatController.text = _config.shalatMinutes.toString();
    _khutbahController.text = _config.khutbahMinutes.toString();
    _fridayKhatibController.text = _config.fridayKhatib;
    _fridayMuadzinController.text = _config.fridayMuadzin;
  }

  /// Nilai awal form saat startup.
  ///
  /// Cache snapshot TV diprioritaskan karena TV adalah trust source; prefs
  /// durasi lama hanya dipakai bila cache belum pernah ada.
  Future<void> _loadStartupData() async {
    final cached = await _cacheStore.load();
    if (cached != null && mounted) {
      setState(() {
        _applySnapshot(cached);
      });
      return;
    }
    await _loadSavedDurations();
  }

  /// Terapkan isi snapshot TV ke state (config + konten).
  void _applySnapshot(StateSnapshot snapshot) {
    _config = snapshot.config;
    _runningTexts
      ..clear()
      ..addAll(snapshot.runningTexts);
    _banners
      ..clear()
      ..addAll(snapshot.banners);
    _kasTransactions
      ..clear()
      ..addAll(snapshot.kasTransactions);
    _syncConfigControllers();
  }

  /// Minta keadaan awal ke TV (TV sebagai trust source).
  void _requestTvState() {
    _client.sendPacket(const SyncPacket(
      action: SyncAction.getInitialState,
      payload: {},
    ));
  }

  /// Tampilkan SnackBar lewat messenger global (stabil lintas transisi
  /// gatekeeper <-> menu utama). Hindari menahan ScaffoldState lama yang
  /// bisa menjadi dependent subtree yang sedang dibongkar.
  ///
  /// Pesan selalu dipasang ke [appMessengerKey] — jangan menulis pola
  /// `appMessengerKey.currentState ?? ScaffoldMessenger.of(context)...`:
  /// operator `??` mengembalikan operand kiri bila non-null sehingga
  /// `showSnackBar(...)` tidak pernah dievaluasi (umpan balik hilang).
   void _showSnack(String message, {Color? background}) {
     final messenger = appMessengerKey.currentState;
     if (messenger == null) return;
     messenger.showSnackBar(
       SnackBar(
         content: Text(message),
         backgroundColor: background,
       ),
     );
   }
 
  /// Tampilkan dialog input PIN 4 digit yang diminta TV. PIN dikirim via
  /// [BluetoothClientService.respondWithPin]; dialog menutup sendiri saat
  /// TV mengirim `authSuccess`.
  void _showPinDialog() {
    if (_pinDialogOpen) return;
    final navigatorContext = appNavigatorKey.currentContext;
    if (!mounted || navigatorContext == null) return;
    _pinDialogOpen = true;
    showDialog<void>(
      context: navigatorContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return _PinDialog(
          onSubmit: (pin) => _btClient.respondWithPin(pin),
          onCancel: () {
            // Tutup snackbar sisa kesalahan lebih dulu, lalu tutup dialog
            // lewat navigator root. Jangan setState di sini: route dialog
            // masih aktif dan subtree-nya sedang dibaca — itulah sumber
            // assertion '_dependents.isEmpty' pada crash Red Screen.
            appMessengerKey.currentState?.hideCurrentSnackBar();
            appNavigatorKey.currentState?.pop();
            // Putus sesi BT setelah dialog tertutup; state yang masuk
            // ditahan (_pendingBtState) lalu diterapkan setelah route lepas.
            unawaited(_btClient.cancelAuth());
          },
        );
      },
    ).then((_) {
      // Dialog ditutup (auth sukses / batal / TV memutus). Route sudah
      // dilepas, jadi aman menerapkan state yang tertahan tadi.
      if (mounted) {
        _pinDialogOpen = false;
        _drainPendingBtState();
      }
    });
  }

  /// Tutup dialog PIN bila sedang terbuka (dipanggil saat auth sukses).
  void _closePinDialog() {
    if (!_pinDialogOpen) return;
    appMessengerKey.currentState?.hideCurrentSnackBar();
    appNavigatorKey.currentState?.pop();
  }

  /// Terapkan state BT yang tertahan selama dialog PIN terbuka. Dipanggil
  /// setelah route dialog tertutup (bukan selagi dialog masih aktif).
  void _drainPendingBtState() {
    if (!mounted) return;
    final pending = _pendingBtState;
    _pendingBtState = null;
    if (pending == null) return;
    final wasBtConnected = _btConnected;
    setState(() {
      _btConnected = pending.isConnected;
      _btDevices = pending.devices;
      _btIsScanning = pending.isScanning;
      switch (pending.status) {
        case BluetoothClientStatus.connected:
          _btStatus =
              'Bluetooth: Terhubung ke TV (${pending.peerName ?? 'TV'})';
          break;
        case BluetoothClientStatus.error:
          _btStatus = 'Bluetooth: ${pending.error ?? 'gagal'}';
          break;
        case BluetoothClientStatus.discovering:
          _btStatus =
              'Bluetooth: Mencari TV... (${pending.devices.length} ditemukan)';
          break;
        case BluetoothClientStatus.reconnecting:
          _btStatus = 'Bluetooth: Menyambung ulang...';
          break;
        case BluetoothClientStatus.connecting:
          _btStatus = 'Bluetooth: Menyambung...';
          break;
        case BluetoothClientStatus.idle:
          _btStatus = pending.devices.isEmpty
              ? 'Bluetooth: Stanby'
              : 'Bluetooth: Scan selesai. ${pending.devices.length} perangkat.';
          break;
      }
    });
    if (wasBtConnected && !pending.isConnected) {
      _handleTransportDisconnected();
    }
  }

  /// Muat durasi siklus waktu shalat dari SharedPreferences (persist lokal).
  Future<void> _loadSavedDurations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt('preAdhanMinutes');
      if (saved == null || !mounted) return;
      setState(() {
        _config = _config.copyWith(
          preAdhanMinutes:
              prefs.getInt('preAdhanMinutes') ?? _config.preAdhanMinutes,
          adhanMinutes: prefs.getInt('adhanMinutes') ?? _config.adhanMinutes,
          preIqomahMinutes:
              prefs.getInt('preIqomahMinutes') ?? _config.preIqomahMinutes,
          shalatMinutes:
              prefs.getInt('shalatMinutes') ?? _config.shalatMinutes,
          khutbahMinutes:
              prefs.getInt('khutbahMinutes') ?? _config.khutbahMinutes,
          fridayKhatib:
              prefs.getString('fridayKhatib') ?? _config.fridayKhatib,
          fridayMuadzin:
              prefs.getString('fridayMuadzin') ?? _config.fridayMuadzin,
        );
        _preAdhanController.text = _config.preAdhanMinutes.toString();
        _adhanController.text = _config.adhanMinutes.toString();
        _preIqomahController.text = _config.preIqomahMinutes.toString();
        _shalatController.text = _config.shalatMinutes.toString();
        _khutbahController.text = _config.khutbahMinutes.toString();
        _fridayKhatibController.text = _config.fridayKhatib;
        _fridayMuadzinController.text = _config.fridayMuadzin;
      });
    } catch (_) {
      // Plugin tidak tersedia (mis. test) -> gunakan default.
    }
  }

  /// Simpan durasi siklus waktu shalat ke SharedPreferences.
  Future<void> _persistDurations(MosqueConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('preAdhanMinutes', config.preAdhanMinutes);
      await prefs.setInt('adhanMinutes', config.adhanMinutes);
      await prefs.setInt('preIqomahMinutes', config.preIqomahMinutes);
      await prefs.setInt('shalatMinutes', config.shalatMinutes);
      await prefs.setInt('khutbahMinutes', config.khutbahMinutes);
      await prefs.setString('fridayKhatib', config.fridayKhatib);
      await prefs.setString('fridayMuadzin', config.fridayMuadzin);
    } catch (_) {
      // Plugin tidak tersedia (mis. test) -> abaikan.
    }
  }

  /// Terima paket dari TV: `stateUpdate` (fase siklus shalat) dan
  /// `stateSnapshot` (data resmi lengkap, TV -> Remote).
  void _handleTvPacket(SyncPacket packet) {
    switch (packet.action) {
      case SyncAction.stateUpdate:
        _applyTvPhase(packet);
        break;
      case SyncAction.stateSnapshot:
        _applyTvSnapshot(StateSnapshot.fromMap(packet.payload));
        break;
      default:
        break;
    }
  }

  /// Perbarui indikator fase TV dari `SyncAction.stateUpdate`.
  void _applyTvPhase(SyncPacket packet) {
    final phaseName = packet.payload['phase'] as String?;
    if (phaseName == null || !mounted) return;
    setState(() {
      _tvPhase = PrayerPhase.values.firstWhere(
        (p) => p.name == phaseName,
        orElse: () => PrayerPhase.normal,
      );
    });
  }

  /// Terapkan snapshot TV: isi form & konten dari TV, simpan sebagai cache
  /// lokal. Bila TV masih kosong (belum pernah diisi DKM), Remote boleh
  /// mengirim datanya SEKALI sebagai bootstrap.
  ///
  /// Catatan: snapshot dari TV yang belum berisi data resmi (`hasData: false`)
  /// hanya memuat data contoh bawaan TV, sehingga TIDAK diterapkan ke form —
  /// Remote mempertahankan datanya lalu mengirimkannya sekali ke TV.
  void _applyTvSnapshot(StateSnapshot snapshot) {
    if (!mounted) return;
    if (!snapshot.hasData) {
      if (!_didBootstrapPush) {
        _didBootstrapPush = true;
        _pushLocalDataToTv();
      }
      return;
    }

    setState(() {
      _applySnapshot(snapshot);
      _hasUnsyncedChanges = false;
    });
    _cacheStore.save(snapshot);
    _persistDurations(snapshot.config);
  }

  /// Kirim data lokal ke TV tanpa menyentuh form (dipakai bootstrap TV kosong).
  void _pushLocalDataToTv() {
    _client.sendConfigUpdate(_config);
    _client.sendRunningTextsUpdate(_runningTexts);
    _client.sendBannersUpdate(_banners);
    _client.sendKasUpdate(_kasTransactions);
  }

  /// Export snapshot keadaan saat ini ke file backup JSON.
  Future<void> _exportBackup() async {
    final snapshot = StateSnapshot(
      config: _config,
      runningTexts: List.of(_runningTexts),
      banners: List.of(_banners),
      kasTransactions: List.of(_kasTransactions),
      hasData: true,
    );
    final savedPath = await _backupService.exportToFile(
      snapshot,
      _config.name,
    );
    if (!mounted) return;
    if (savedPath == null) {
      _showSnack('Export dibatalkan.');
      return;
    }
    _showSnack('Backup disimpan: $savedPath');
  }

  /// Import backup dari file JSON yang dipilih user, dengan konfirmasi.
  Future<void> _importBackup() async {
    final result = await _backupService.importFromFile();
    if (!mounted) return;
    final bundle = result.bundle;
    if (!result.success || bundle == null) {
      _showSnack(result.errorMessage ?? 'Impor gagal.');
      return;
    }

    final snapshot = bundle.snapshot;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Impor Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Backup siap diterapkan. Data saat ini akan disimpan ke cache lokal sebagai cadangan.',
              ),
              const SizedBox(height: 12),
              Text('Masjid: ${bundle.mosqueName}'),
              Text('Running Text: ${snapshot.runningTexts.length}'),
              Text('Banner: ${snapshot.banners.length}'),
              Text('Transaksi Kas: ${snapshot.kasTransactions.length}'),
              const SizedBox(height: 12),
              const Text('Sure ingin terapkan backup ini?'),
            ],
          ),
          actions: [
            M3Pressable(
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
            ),
            M3Pressable(
              child: FilledButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _applyImportedBackup(bundle);
                },
                child: const Text('Terapkan'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Terapkan [bundle] hasil impor: simpan snapshot lama ke cache sebagai
  /// cadangan, isi state dari bundle, refresh form, lalu kirim ke TV.
  Future<void> _applyImportedBackup(BackupBundle bundle) async {
    // Cadangan: snapshot lama disimpan ke cache lokal sebelum state diubah.
    final oldSnapshot = StateSnapshot(
      config: _config,
      runningTexts: List.of(_runningTexts),
      banners: List.of(_banners),
      kasTransactions: List.of(_kasTransactions),
      hasData: true,
    );
    await _cacheStore.save(oldSnapshot);

    final snapshot = bundle.snapshot;
    if (!mounted) return;
    setState(() {
      _applySnapshot(snapshot);
      _hasUnsyncedChanges = true;
    });

    // Kirim data backup ke TV lewat jalur push manual yang sudah ada
    // (menampilkan snackbar sesuai — sukses atau perlu koneksi ulang).
    _pushAllToTv();
  }

  Future<void> _connectToTv() async {
    setState(() {
      _isConnecting = true;
    });
    try {
      final ok = await _client.connect(_ipController.text.trim());
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _isConnected = _btConnected;
        });
        _showSnack('Koneksi gagal: alamat IP tidak valid atau TV tidak terhubung');
      }
      // Sukses: `_handleConnectionEstablished('ip')` dipanggil oleh
      // callback `onConnected` dari RemoteWsClient.
    } catch (e) {
      if (mounted) {
        _showSnack('Koneksi gagal: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  /// Dipanggil setiap kali transport berhasil tersambung & terverifikasi
  /// (WS `onConnected` / BT `onAuthenticated`). Reconnect memunculkan dialog
  /// resolusi sinkronisasi; koneksi pertama langsung masuk menu utama.
  void _handleConnectionEstablished(String kind) {
    if (!mounted) return;
    final isReconnect = _wasConnected || _showDisconnectedNotice;
    _lastConnectionKind = kind;
    setState(() {
      _isConnected = true;
      _showDisconnectedNotice = false;
      _hasUnsyncedChanges = false;
    });
    if (isReconnect) {
      _showSyncConflictDialog();
    } else {
      _wasConnected = true;
      _requestTvState();
    }
  }

  /// Transport putus tiba-tiba (WS `onDisconnected` / BT stream kehilangan
  /// koneksi). Tampilkan banner dengan aksi sambungkan ulang.
  void _handleTransportDisconnected() {
    if (!mounted || !_isConnected) return;
    setState(() {
      _isConnected = false;
      _showDisconnectedNotice = true;
    });
  }

  /// Coba sambungkan ulang memakai transport terakhir yang diketahui.
  Future<void> _reconnectLast() async {
    if (_lastConnectionKind == 'bluetooth' && _lastBtDevice != null) {
      _connectBt(_lastBtDevice!);
      return;
    }
    if (_lastBtDevice != null) {
      _connectBt(_lastBtDevice!);
      return;
    }
    await _connectToTv();
  }

  /// Dialog resolusi konflik sinkronisasi setelah reconnect: pilih sumber
  /// kebenaran (TV atau data lokal HP yang sedang diedit).
  void _showSyncConflictDialog() {
    if (_syncDialogOpen || !mounted) return;
    _syncDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.sync, size: 40),
          title: const Text('Sinkronisasi Data'),
          content: const Text(
            'Koneksi terhubung kembali. Pilih sumber pengaturan yang '
            'ingin digunakan:',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // TV sebagai sumber: minta snapshot resmi, terapkan ke HP.
                _requestTvState();
              },
              child: const Text('Gunakan Data TV'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // HP sebagai sumber: kirim seluruh data lokal ke TV.
                _pushAllToTv();
              },
              child: const Text('Gunakan Data HP'),
            ),
          ],
        );
      },
    ).then((_) {
      _syncDialogOpen = false;
    });
  }

  /// Putuskan koneksi aktif dan kembalikan pengguna ke layar sambungan.
  Future<void> _disconnectFromTv() async {
    _lastConnectionKind = null;
    await _btClient.disconnect();
    _client.disconnect();
    if (!mounted) return;
    setState(() {
      _isConnected = false;
      _btConnected = false;
      _showDisconnectedNotice = false;
    });
  }

  MosqueConfig _buildConfigFromForm() {
    return MosqueConfig(
      name: _nameController.text.trim().isEmpty
          ? _config.name
          : _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? _config.address
          : _addressController.text.trim(),
      latitude: double.tryParse(_latitudeController.text.trim()) ??
          _config.latitude,
      longitude: double.tryParse(_longitudeController.text.trim()) ??
          _config.longitude,
      prayerOffsets: {
        for (final type in kAllPrayerTypes)
          type: int.tryParse(_prayerOffsetControllers[type]!.text.trim()) ?? 0,
      },
      preAdhanMinutes: _minutesFrom(_preAdhanController, _config.preAdhanMinutes),
      adhanMinutes: _minutesFrom(_adhanController, _config.adhanMinutes),
      preIqomahMinutes:
          _minutesFrom(_preIqomahController, _config.preIqomahMinutes),
      shalatMinutes: _minutesFrom(_shalatController, _config.shalatMinutes),
      khutbahMinutes:
          _minutesFrom(_khutbahController, _config.khutbahMinutes),
      fridayKhatib: _fridayKhatibController.text.trim().isEmpty
          ? _config.fridayKhatib
          : _fridayKhatibController.text.trim(),
      fridayMuadzin: _fridayMuadzinController.text.trim().isEmpty
          ? _config.fridayMuadzin
          : _fridayMuadzinController.text.trim(),
    );
  }

  /// Parse menit dari field; fallback ke nilai lama; jangan pernah negatif.
  int _minutesFrom(TextEditingController controller, int fallback) {
    final value = int.tryParse(controller.text.trim());
    if (value == null) return fallback;
    return value < 0 ? 0 : value;
  }

  void _syncAllToTv() {
    final config = _buildConfigFromForm();
    _config = config;
    _persistDurations(config);
    _client.sendConfigUpdate(config);
    _client.sendRunningTextsUpdate(_runningTexts);
    _client.sendBannersUpdate(_banners);
    _client.sendKasUpdate(_kasTransactions);
  }

  void _pushAllToTv() {
    if (!_isConnected) {
      _showSnack('Belum terhubung ke TV. Menyambungkan ulang...');
      _connectToTv();
      return;
    }
    _syncAllToTv();
    setState(() {
      _hasUnsyncedChanges = false;
    });
    _showSnack('Semua data berhasil dikirim ke TV!');
  }

  void _sendConfigUpdate() {
    final updatedConfig = _buildConfigFromForm();
    _config = updatedConfig;
    _persistDurations(updatedConfig);

    if (_isConnected) {
      _client.sendConfigUpdate(updatedConfig);
      setState(() {
        _hasUnsyncedChanges = false;
      });
      _showSnack('Pengaturan berhasil diperbarui di TV!');
    } else {
      setState(() {
        _hasUnsyncedChanges = true;
      });
      _showSnack('Pengaturan disimpan lokal (belum dikirim).');
    }
  }

  /// Kirim aksi cepat (skip) ke TV. Valid hanya saat TV berada di fase terkait.
  void _sendQuickAction(SyncAction action) {
    if (!_isConnected) {
      _showSnack('Belum terhubung ke TV. Sambungkan dulu.');
      return;
    }
    switch (action) {
      case SyncAction.skipAdhan:
        _client.sendSkipAdhan();
      case SyncAction.startIqomah:
        _client.sendStartIqomah();
      case SyncAction.startShalat:
        _client.sendStartShalat();
      case SyncAction.finishShalat:
        _client.sendFinishShalat();
      default:
        break;
    }
  }

  /// Kirim perintah paksa fase ke TV (dari Menu Tes).
  void _sendForcePhase(PrayerPhase phase) {
    if (!_isConnected) {
      _showSnack('Belum terhubung ke TV. Sambungkan dulu.');
      return;
    }
    _client.sendForcePhase(phase);
  }

  Future<void> _getLocationFromGps() async {
    setState(() {
      _isFetchingLocation = true;
    });
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        if (mounted) {
          _showSnack('Layanan lokasi (GPS) tidak aktif.');
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showSnack('Izin lokasi GPS ditolak.');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showSnack('Izin GPS ditolak permanen.');
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (mounted) {
        setState(() {
          _latitudeController.text = pos.latitude.toStringAsFixed(6);
          _longitudeController.text = pos.longitude.toStringAsFixed(6);
          _hasUnsyncedChanges = true;
        });
        _showSnack('Koordinat GPS berhasil diambil!');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Gagal mengambil GPS: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  void _addRunningText() {
    final text = _runningTextController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _runningTexts.add(RunningTextMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        category: _runningCategory,
      ));
      _runningTextController.clear();
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendRunningTextsUpdate(_runningTexts);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _removeRunningText(String id) {
    setState(() {
      _runningTexts.removeWhere((t) => t.id == id);
      _hasUnsyncedChanges = true;
    });
    if (_isConnected) {
      _client.sendRunningTextsUpdate(_runningTexts);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _editRunningText(RunningTextMessage item) {
    final textController = TextEditingController(text: item.content);
    String selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Teks Berjalan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Isi Pesan'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Kategori: '),
                      DropdownButton<String>(
                        value: selectedCategory,
                        items: _runningCategories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() {
                              selectedCategory = v;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                M3Pressable(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Batal'),
                  ),
                ),
                M3Pressable(
                  child: FilledButton(
                    onPressed: () {
                      final newContent = textController.text.trim();
                      if (newContent.isEmpty) return;
                      setState(() {
                        final index =
                            _runningTexts.indexWhere((t) => t.id == item.id);
                        if (index >= 0) {
                          _runningTexts[index] = RunningTextMessage(
                            id: item.id,
                            content: newContent,
                            category: selectedCategory,
                            isActive: item.isActive,
                          );
                        }
                        _hasUnsyncedChanges = true;
                      });
                      if (_isConnected) {
                        _client.sendRunningTextsUpdate(_runningTexts);
                        setState(() {
                          _hasUnsyncedChanges = false;
                        });
                      }
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addBanner(String? base64Image) {
    final title = _bannerTitleController.text.trim();
    final content = _bannerContentController.text.trim();
    if (title.isEmpty && content.isEmpty && (base64Image == null || base64Image.isEmpty)) return;

    setState(() {
      _banners.add(MediaBanner(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        header: _bannerHeaderController.text.trim().isEmpty
            ? 'INFO MASJID'
            : _bannerHeaderController.text.trim(),
        title: title,
        content: content,
        footer: _bannerFooterController.text.trim(),
        base64Image: base64Image,
      ));
      _bannerHeaderController.clear();
      _bannerTitleController.clear();
      _bannerContentController.clear();
      _bannerFooterController.clear();
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendBannersUpdate(_banners);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _removeBanner(String id) {
    setState(() {
      _banners.removeWhere((b) => b.id == id);
      _hasUnsyncedChanges = true;
    });
    if (_isConnected) {
      _client.sendBannersUpdate(_banners);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _toggleBanner(String id, bool val) {
    setState(() {
      final index = _banners.indexWhere((b) => b.id == id);
      if (index >= 0) {
        _banners[index] = _banners[index].copyWith(isActive: val);
      }
      _hasUnsyncedChanges = true;
    });
    if (_isConnected) {
      _client.sendBannersUpdate(_banners);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _editBanner(MediaBanner banner) {
    final headerController = TextEditingController(text: banner.header);
    final titleController = TextEditingController(text: banner.title);
    final contentController = TextEditingController(text: banner.content);
    final footerController = TextEditingController(text: banner.footer);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Banner Informasi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: headerController,
                  decoration: const InputDecoration(labelText: 'Header/Kategori'),
                ),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul Utama'),
                ),
                TextFormField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Konten/Isi'),
                ),
                TextFormField(
                  controller: footerController,
                  decoration: const InputDecoration(labelText: 'Catatan Kaki'),
                ),
              ],
            ),
          ),
          actions: [
            M3Pressable(
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
            ),
            M3Pressable(
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    final index = _banners.indexWhere((b) => b.id == banner.id);
                    if (index >= 0) {
                      _banners[index] = MediaBanner(
                        id: banner.id,
                        header: headerController.text.trim().isEmpty
                            ? 'INFO MASJID'
                            : headerController.text.trim(),
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        footer: footerController.text.trim(),
                        isActive: banner.isActive,
                      );
                    }
                    _hasUnsyncedChanges = true;
                  });
                  if (_isConnected) {
                    _client.sendBannersUpdate(_banners);
                    setState(() {
                      _hasUnsyncedChanges = false;
                    });
                  }
                  Navigator.pop(dialogContext);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addKasTransaction() {
    final amtText = _kasAmountController.text.trim();
    final desc = _kasDescriptionController.text.trim();
    final amt = int.tryParse(amtText);
    if (amt == null || amt <= 0 || desc.isEmpty) return;

    setState(() {
      _kasTransactions.add(KasTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _kasType,
        amount: amt,
        description: desc,
        date: DateTime.now(),
      ));
      _kasAmountController.clear();
      _kasDescriptionController.clear();
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendKasUpdate(_kasTransactions);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _removeKasTransaction(String id) {
    setState(() {
      _kasTransactions.removeWhere((t) => t.id == id);
      _hasUnsyncedChanges = true;
    });
    if (_isConnected) {
      _client.sendKasUpdate(_kasTransactions);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _startBtScan() {
    setState(() {
      _btIsScanning = true;
      _btStatus = 'Bluetooth: Mencari TV...';
    });
    _btClient.startDiscovery();
  }

  void _stopBtScan() {
    _btClient.stopDiscovery();
    setState(() {
      _btIsScanning = false;
      _btStatus = 'Bluetooth: Scan berhenti.';
    });
  }

  void _connectBt(BluetoothDeviceInfo device) {
    _lastBtDevice = device;
    _btClient.stopDiscovery();
    setState(() {
      _btIsScanning = false;
      _btStatus = 'Bluetooth: Menyambung ke ${device.name}...';
    });
    _btClient.connectTo(device);
  }

  void _showScheduleSimulation(MosqueConfig formConfig) {
    var simDateTime = DateTime.now();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final schedule = PrayerSchedule.calculate(formConfig, simDateTime);
            final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

            return AlertDialog(
              title: const Text('Simulasi Perhitungan Jadwal'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pilih tanggal dan jam di bawah untuk mensimulasikan countdown shalat berikutnya.',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: M3Pressable(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 18),
                                label: Text(
                                  dateFormat.format(simDateTime),
                                ),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: simDateTime,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      simDateTime = DateTime(
                                        picked.year,
                                        picked.month,
                                        picked.day,
                                        simDateTime.hour,
                                        simDateTime.minute,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: M3Pressable(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.access_time, size: 18),
                                label: Text(
                                  DateFormat('HH:mm').format(simDateTime),
                                ),
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      simDateTime,
                                    ),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      simDateTime = DateTime(
                                        simDateTime.year,
                                        simDateTime.month,
                                        simDateTime.day,
                                        picked.hour,
                                        picked.minute,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Lokasi: ${formConfig.latitude.toStringAsFixed(4)}, ${formConfig.longitude.toStringAsFixed(4)} (dihitung offline)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      for (final item in schedule.items)
                        _buildSimulationRow(
                          context,
                          schedule,
                          item,
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                M3Pressable(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSimulationRow(
    BuildContext context,
    PrayerSchedule schedule,
    PrayerScheduleItem item,
  ) {
    final isNext = schedule.nextPrayer == item.type;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isNext
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          isNext ? Icons.alarm_on : Icons.schedule,
          color: isNext
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : null,
        ),
        title: Text(
          item.type.displayNameForDate(item.time),
          style: isNext
              ? const TextStyle(fontWeight: FontWeight.bold)
              : null,
        ),
        trailing: isNext
            ? Text(
                '${item.formattedTime}\nSELANJUTNYA · ${_formatDurationShort(schedule.timeUntilNextPrayer)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(item.formattedTime),
      ),
    );
  }

  String _formatDurationShort(Duration? duration) {
    if (duration == null || duration.isNegative) return '00:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ipController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    for (final controller in _prayerOffsetControllers.values) {
      controller.dispose();
    }
    _preAdhanController.dispose();
    _adhanController.dispose();
    _preIqomahController.dispose();
    _shalatController.dispose();
    _khutbahController.dispose();
    _fridayKhatibController.dispose();
    _fridayMuadzinController.dispose();
    _runningTextController.dispose();
    _bannerHeaderController.dispose();
    _bannerTitleController.dispose();
    _bannerContentController.dispose();
    _bannerFooterController.dispose();
    _kasAmountController.dispose();
    _kasDescriptionController.dispose();
    _mainTabController.dispose();
    _subTabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _btClient.disconnect();
    _btStateSub?.cancel();
    _btStateSub = null;
    _btClient.dispose();
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Gatekeeper: pengguna hanya bisa masuk ke menu utama setelah koneksi
    // sukses & terverifikasi (WS terhubung / BT ter-autentikasi). Body diganti
    // per status, tetapi Scaffold/AppBar/bottomNavigation tetap satu pohon
    // yang sama agar context & navigator tidak hancur di tengah transisi.
    final body = !_isConnected
        ? ConnectionGatewayScreen(
            ipController: _ipController,
            isConnecting: _isConnecting,
            onConnectIp: _connectToTv,
            btIsScanning: _btIsScanning,
            btDevices: _btDevices,
            btStatus: _btStatus,
            onBtStartScan: _startBtScan,
            onBtStopScan: _stopBtScan,
            onBtConnect: _connectBt,
          )
        : Column(
            children: [
          if (_showDisconnectedNotice)
            _buildDisconnectedBanner(theme, colorScheme),
          if (_hasUnsyncedChanges) _buildUnsyncedBanner(theme, colorScheme),
          AnimatedBuilder(
            animation: _mainTabController.animation!,
            builder: (context, child) {
              final val = _mainTabController.animation!.value;
              double factor;
              if (val < 1) {
                factor = val;
              } else if (val <= 3) {
                factor = 1;
              } else if (val < 4) {
                factor = 4 - val;
              } else {
                factor = 0;
              }
              factor = factor.clamp(0.0, 1.0);
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: factor,
                  child: Opacity(
                    opacity: factor,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildContentTabBar(theme, colorScheme),
          ),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                SettingsTab(
                  config: _config,
                  nameController: _nameController,
                  addressController: _addressController,
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                  prayerOffsetControllers: _prayerOffsetControllers,
                  preAdhanController: _preAdhanController,
                  adhanController: _adhanController,
                  preIqomahController: _preIqomahController,
                  shalatController: _shalatController,
                  khutbahController: _khutbahController,
                  fridayKhatibController: _fridayKhatibController,
                  fridayMuadzinController: _fridayMuadzinController,
                  isFetchingLocation: _isFetchingLocation,
                  isConnected: _isConnected,
                  tvPhase: _tvPhase,
                  onFetchLocation: _getLocationFromGps,
                  onSaveConfig: _sendConfigUpdate,
                  onSendQuickAction: _sendQuickAction,
                  onShowSimulation: _showScheduleSimulation,
                  onExportBackup: _exportBackup,
                  onImportBackup: _importBackup,
                ),
                RunningTextSubtab(
                  runningTexts: _runningTexts,
                  runningTextController: _runningTextController,
                  selectedCategory: _runningCategory,
                  categories: _runningCategories,
                  onCategoryChanged: (cat) {
                    setState(() {
                      _runningCategory = cat;
                    });
                  },
                  onAddMessage: _addRunningText,
                  onEditMessage: _editRunningText,
                  onRemoveMessage: _removeRunningText,
                ),
                BannersSubtab(
                  banners: _banners,
                  headerController: _bannerHeaderController,
                  titleController: _bannerTitleController,
                  contentController: _bannerContentController,
                  footerController: _bannerFooterController,
                  onAddBanner: _addBanner,
                  onEditBanner: _editBanner,
                  onRemoveBanner: _removeBanner,
                  onToggleBanner: _toggleBanner,
                ),
                KasSubtab(
                  transactions: _kasTransactions,
                  amountController: _kasAmountController,
                  descriptionController: _kasDescriptionController,
                  kasType: _kasType,
                  onTypeChanged: (type) {
                    setState(() {
                      _kasType = type;
                    });
                  },
                  onAddTransaction: _addKasTransaction,
                  onRemoveTransaction: _removeKasTransaction,
                ),
                SimulationTab(
                  isConnected: _isConnected,
                  tvPhase: _tvPhase,
                  onSendForcePhase: _sendForcePhase,
                ),
              ],
            ),
          ),
        ],
      );
    final connected = _isConnected;
    return Scaffold(
      appBar: connected
          ? AppBar(
              title: const Text('Remote Masjid DKM'),
              centerTitle: true,
              backgroundColor: colorScheme.surfaceContainer,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildConnectionBadge(colorScheme),
                ),
              ],
            )
          : null,
      body: body,
      bottomNavigationBar: connected
          ? NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          _mainTabController.animateTo(
            _mainPageForBottomNav(index, _subTabController.index),
          );
        },
        destinations: [
          NavigationDestination(
            icon: PlayfulNavIcon(
              unselectedIcon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              isSelected: _tabIndex == 0,
              shouldRotate: true,
            ),
            label: 'Pengaturan',
          ),
          NavigationDestination(
            icon: PlayfulNavIcon(
              unselectedIcon: Icons.collections_bookmark_outlined,
              selectedIcon: Icons.collections_bookmark,
              isSelected: _tabIndex == 1,
              shouldRotate: true,
            ),
            label: 'Konten',
          ),
          NavigationDestination(
            icon: PlayfulNavIcon(
              unselectedIcon: Icons.science_outlined,
              selectedIcon: Icons.science,
              isSelected: _tabIndex == 2,
              shouldRotate: true,
            ),
            label: 'Tes',
          ),
        ],
      )
          : null,
    );
  }

  /// Badge status koneksi di AppBar. Diketuk untuk membuka menu
  /// "Putuskan Koneksi" (kembali ke layar sambungan).
  Widget _buildConnectionBadge(ColorScheme colorScheme) {
    final viaBt = _lastConnectionKind == 'bluetooth';
    final label = viaBt ? 'Terhubung via Bluetooth' : 'Terhubung via IP';
    final icon = viaBt ? Icons.bluetooth_connected : Icons.wifi_rounded;
    return PopupMenuButton<String>(
      tooltip: 'Status koneksi',
      onSelected: (value) {
        if (value == 'disconnect') {
          _disconnectFromTv();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'disconnect',
          child: Row(
            children: [
              Icon(Icons.link_off),
              SizedBox(width: 8),
              Text('Putuskan Koneksi'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner peringatan koneksi terputus dengan aksi sambungkan ulang.
  Widget _buildDisconnectedBanner(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Koneksi ke TV terputus.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          M3Pressable(
            child: TextButton.icon(
              onPressed: _reconnectLast,
              icon: const Icon(Icons.refresh),
              label: const Text('Sambungkan Ulang'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTabBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainer,
      child: TabBar(
        controller: _subTabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.campaign),
            text: 'Running Text',
          ),
          Tab(
            icon: Icon(Icons.newspaper),
            text: 'Info Masjid',
          ),
          Tab(
            icon: Icon(Icons.account_balance_wallet),
            text: 'Kas',
          ),
        ],
      ),
    );
  }

  Widget _buildUnsyncedBanner(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.sync_problem, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ada perubahan belum dikirim ke TV',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          M3Pressable(
            child: TextButton.icon(
              onPressed: _pushAllToTv,
              icon: const Icon(Icons.sync),
              label: const Text('Kirim ke TV'),
            ),
          ),
        ],
      ),
    );
  }
}

class MasjidYouRemoteApp extends StatelessWidget {
  const MasjidYouRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF006A60); // Emerald/Teal Material You

    return MaterialApp(
      title: 'Masjid Remote DKM',
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: buildRemoteTheme(Brightness.light, seedColor),
      darkTheme: buildRemoteTheme(Brightness.dark, seedColor),
      home: const RemoteHomeScreen(),
    );
  }
}

void main() {
  runApp(const MasjidYouRemoteApp());
}
