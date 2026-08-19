import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_models/shared_models.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ws_client.dart';
import '../services/p2p_client_service.dart';
import '../theme/remote_theme.dart';

import 'screens/settings/settings_tab.dart';
import 'screens/content/running_text_subtab.dart';
import 'screens/content/banners_subtab.dart';
import 'screens/content/kas_subtab.dart';
import 'screens/connectivity/connectivity_tab.dart';
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

class _RemoteHomeScreenState extends State<RemoteHomeScreen>
    with TickerProviderStateMixin {
  int _tabIndex = 0;

  late final TabController _mainTabController;
  late final TabController _subTabController;
  bool _syncingControllers = false;

  final _ipController = TextEditingController(text: '192.168.1.');
  final _client = RemoteWsClient();
  final _p2pClient = P2pClientService();
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isScanning = false;
  List<BleDiscoveredDevice> _p2pDevices = [];
  String _p2pStatus = 'WiFi Direct: Stanby';

  bool _hasUnsyncedChanges = false;

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
    _mainTabController = TabController(length: 6, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);
    _mainTabController.addListener(_handleMainTabChange);
    _subTabController.addListener(_handleSubTabChange);
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

    _client.onPacket = _handleTvPacket;
    _loadSavedDurations();

    _p2pClient.stateStream.listen((state) {
      if (state == null || !state.isActive || !mounted) return;
      final hostIp = state.hostGatewayIpAddress;
      if (hostIp != null && hostIp.isNotEmpty && hostIp != _ipController.text) {
        setState(() {
          _ipController.text = hostIp;
          _p2pStatus = 'WiFi Direct: Terhubung ke TV!';
        });
        _connectToTv();
      }
    });
  }

  /// Sinkronkan dua `TabController` agar swipe antar halaman menyatu.
  ///
  /// `_mainTabController` (6 halaman) menggerakkan seluruh aplikasi, sedangkan
  /// `_subTabController` (3 sub-tab Konten) hanya menggerakkan indikator
  /// Top Tab Bar. `_syncingControllers` memutus loop antar-listener.
  int _bottomNavIndexForPage(int page) {
    if (page >= 1 && page <= 3) return 1; // Konten
    if (page == 4) return 2; // Konektivitas
    if (page == 5) return 3; // Tes
    return 0; // Pengaturan
  }

  int _mainPageForBottomNav(int bottom, int currentSub) {
    switch (bottom) {
      case 1:
        return currentSub + 1; // Konten -> sub-tab terakhir dilihat
      case 2:
        return 4;
      case 3:
        return 5;
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

  /// Terima status fase TV (`SyncAction.stateUpdate`) untuk indikator tombol.
  void _handleTvPacket(SyncPacket packet) {
    if (packet.action != SyncAction.stateUpdate) return;
    final phaseName = packet.payload['phase'] as String?;
    if (phaseName == null || !mounted) return;
    setState(() {
      _tvPhase = PrayerPhase.values.firstWhere(
        (p) => p.name == phaseName,
        orElse: () => PrayerPhase.normal,
      );
    });
  }

  Future<void> _connectToTv() async {
    setState(() {
      _isConnecting = true;
    });
    try {
      await _client.connect(_ipController.text.trim());
      setState(() {
        _isConnected = true;
        _hasUnsyncedChanges = false;
      });
      _syncAllToTv();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Koneksi gagal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Belum terhubung ke TV. Menyambungkan ulang...')),
      );
      _connectToTv();
      return;
    }
    _syncAllToTv();
    setState(() {
      _hasUnsyncedChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua data berhasil dikirim ke TV!')),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan berhasil diperbarui di TV!')),
      );
    } else {
      setState(() {
        _hasUnsyncedChanges = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pengaturan disimpan lokal (belum dikirim).')),
      );
    }
  }

  /// Kirim aksi cepat (skip) ke TV. Valid hanya saat TV berada di fase terkait.
  void _sendQuickAction(SyncAction action) {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum terhubung ke TV. Sambungkan dulu.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum terhubung ke TV. Sambungkan dulu.')),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan lokasi (GPS) tidak aktif.')),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi GPS ditolak.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin GPS ditolak permanen.')),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Koordinat GPS berhasil diambil!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil GPS: $e')),
        );
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

  void _startScan() {
    setState(() {
      _isScanning = true;
      _p2pDevices.clear();
      _p2pStatus = 'WiFi Direct: Mencari TV...';
    });
    _p2pClient.startScan((devices) {
      if (mounted) {
        setState(() {
          _p2pDevices = devices;
        });
      }
    });
  }

  void _stopScan() {
    _p2pClient.stopScan();
    setState(() {
      _isScanning = false;
      _p2pStatus = 'WiFi Direct: Scan berhenti.';
    });
  }

  void _connectP2p(BleDiscoveredDevice dev) {
    _stopScan();
    setState(() {
      _p2pStatus = 'WiFi Direct: Menyambung...';
    });
    _p2pClient.connectTo(dev);
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
    _p2pClient.disconnect();
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Masjid DKM'),
        centerTitle: true,
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 0,
      ),
      body: Column(
        children: [
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
                ConnectivityTab(
                  ipController: _ipController,
                  isConnecting: _isConnecting,
                  isConnected: _isConnected,
                  isScanning: _isScanning,
                  p2pDevices: _p2pDevices,
                  p2pStatus: _p2pStatus,
                  onConnectWifi: _connectToTv,
                  onStartScan: _startScan,
                  onStopScan: _stopScan,
                  onConnectP2p: _connectP2p,
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
      ),
      bottomNavigationBar: NavigationBar(
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
              unselectedIcon: Icons.wifi_outlined,
              selectedIcon: Icons.wifi,
              isSelected: _tabIndex == 2,
              shouldRotate: true,
            ),
            label: 'Konektivitas',
          ),
          NavigationDestination(
            icon: PlayfulNavIcon(
              unselectedIcon: Icons.science_outlined,
              selectedIcon: Icons.science,
              isSelected: _tabIndex == 3,
              shouldRotate: true,
            ),
            label: 'Tes',
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
