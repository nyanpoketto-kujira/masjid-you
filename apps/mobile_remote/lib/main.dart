import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_models/shared_models.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'services/ws_client.dart';
import 'services/p2p_client_service.dart';

const List<String> _runningCategories = [
  'Pengumuman',
  'Kajian',
  'Kas',
  'Himbauan',
  'Infaq',
  'Umum',
];

void main() {
  runApp(const MasjidYouRemoteApp());
}

class MasjidYouRemoteApp extends StatelessWidget {
  const MasjidYouRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF006A60); // Emerald/Teal Material You

    return MaterialApp(
      title: 'Masjid Remote DKM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      home: const RemoteHomeScreen(),
    );
  }
}

class RemoteHomeScreen extends StatefulWidget {
  const RemoteHomeScreen({super.key});

  @override
  State<RemoteHomeScreen> createState() => _RemoteHomeScreenState();
}

class _RemoteHomeScreenState extends State<RemoteHomeScreen> {
  int _tabIndex = 0;

  final _ipController = TextEditingController(text: '192.168.1.');
  final _client = RemoteWsClient();
  final _p2pClient = P2pClientService();
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isScanning = false;
  bool _hasUnsyncedChanges = false;
  List<BleDiscoveredDevice> _p2pDevices = [];
  String? _p2pStatus;

  // Form State
  MosqueConfig _config = const MosqueConfig();
  final List<RunningTextMessage> _runningTexts = [
    const RunningTextMessage(
      id: '1',
      content: 'Kajian Rutin Subuh Setiap Hari Sabtu & Ahad',
      category: 'Kajian',
    ),
  ];

  final List<MediaBanner> _banners = [
    const MediaBanner(
      id: '1',
      header: 'INFO MASJID',
      title: 'Kajian Rutin Subuh',
      content: 'Setiap Hari Sabtu & Ahad bersama Dewan Asatidz',
      footer: 'Gratis & terbuka untuk umum',
    ),
  ];

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final Map<PrayerType, TextEditingController> _prayerOffsetControllers = {
    for (final type in kAllPrayerTypes) type: TextEditingController(),
  };
  bool _isFetchingLocation = false;
  final _runningTextController = TextEditingController();
  String _runningCategory = _runningCategories.first;
  final _bannerHeaderController = TextEditingController(text: 'INFO MASJID');
  final _bannerTitleController = TextEditingController();
  final _bannerContentController = TextEditingController();
  final _bannerFooterController = TextEditingController();
  final _kasAmountController = TextEditingController();
  final _kasDescriptionController = TextEditingController();
  KasType _kasType = KasType.masuk;

  final List<KasTransaction> _kasTransactions = [
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

  @override
  void initState() {
    super.initState();
    _nameController.text = _config.name;
    _addressController.text = _config.address;
    _latitudeController.text = _config.latitude.toStringAsFixed(6);
    _longitudeController.text = _config.longitude.toStringAsFixed(6);
    for (final type in kAllPrayerTypes) {
      _prayerOffsetControllers[type]!.text = _config.offsetFor(type).toString();
    }

    _p2pClient.stateStream.listen((state) {
      if (state == null || !state.isActive || !mounted) return;
      final ip = state.hostGatewayIpAddress;
      if (ip == null || ip.isEmpty) return;
      setState(() {
        _p2pStatus = 'Terhubung langsung ke TV ($ip)';
        _ipController.text = ip;
      });
      _connectToTv();
    });
  }

  Future<void> _connectToTv() async {
    setState(() {
      _isConnecting = true;
    });

    final ip = _ipController.text.trim();
    final success = await _client.connect(ip);

    setState(() {
      _isConnecting = false;
      _isConnected = success;
    });

    if (success) {
      _syncAllToTv();
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Terhubung ke Google TV Masjid!'
                : 'Gagal terhubung. Pastikan IP TV benar & berada di WiFi yang sama.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  MosqueConfig _buildConfigFromForm() {
    final latText = _latitudeController.text.trim().replaceAll(',', '.');
    final lngText = _longitudeController.text.trim().replaceAll(',', '.');
    final lat =
        ((double.tryParse(latText) ?? _config.latitude).clamp(-90.0, 90.0)).toDouble();
    final lng = ((double.tryParse(lngText) ?? _config.longitude)
            .clamp(-180.0, 180.0))
        .toDouble();
    return MosqueConfig(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      latitude: lat,
      longitude: lng,
      utcOffsetHours: _config.utcOffsetHours,
      iqamahDuration: _config.iqamahDuration,
      prayerOffsets: {
        for (final type in kAllPrayerTypes)
          type: int.tryParse(_prayerOffsetControllers[type]!.text.trim()) ?? 0,
      },
    );
  }

  void _syncAllToTv() {
    final config = _buildConfigFromForm();
    _config = config;
    _client.sendConfigUpdate(config);
    _client.sendRunningTextsUpdate(_runningTexts);
    _client.sendBannersUpdate(_banners);
    _client.sendKasUpdate(_kasTransactions);
  }

  void _pushAllToTv() {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Belum terhubung ke TV. Sambungkan dulu.')),
      );
      return;
    }
    _syncAllToTv();
    setState(() {
      _hasUnsyncedChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua perubahan terkirim ke TV!')),
    );
  }

  void _sendConfigUpdate() {
    final updatedConfig = _buildConfigFromForm();
    setState(() {
      _config = updatedConfig;
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendConfigUpdate(updatedConfig);
      setState(() {
        _hasUnsyncedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan Masjid Dikirim ke TV!')),
      );
    }
  }

  Future<void> _getLocationFromGps() async {
    setState(() {
      _isFetchingLocation = true;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aktifkan layanan lokasi (GPS) dulu')),
          );
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        _hasUnsyncedChanges = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koordinat GPS diambil')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil lokasi: $e')),
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

    final newItem = RunningTextMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      category: _runningCategory,
    );

    setState(() {
      _runningTexts.add(newItem);
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

  Future<void> _editRunningText(RunningTextMessage item) async {
    final textController = TextEditingController(text: item.content);
    var selectedCategory = item.category;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Teks Berjalan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Isi Teks',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _runningCategories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                FilledButton(
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
              ],
            );
          },
        );
      },
    );
  }

  void _removeRunningText(String id) {
    setState(() {
      _runningTexts.removeWhere((item) => item.id == id);
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendRunningTextsUpdate(_runningTexts);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _addBanner() {
    final header = _bannerHeaderController.text.trim();
    final title = _bannerTitleController.text.trim();
    final content = _bannerContentController.text.trim();
    final footer = _bannerFooterController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi minimal Judul atau Isi info masjid.')),
      );
      return;
    }

    final banner = MediaBanner(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      header: header.isEmpty ? 'INFO MASJID' : header,
      title: title,
      content: content,
      footer: footer,
    );

    setState(() {
      _banners.insert(0, banner);
      _bannerHeaderController.text = 'INFO MASJID';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Info Masjid Dikirim ke TV!')),
      );
    }
  }

  void _toggleBanner(String id) {
    setState(() {
      final index = _banners.indexWhere((b) => b.id == id);
      if (index >= 0) {
        final b = _banners[index];
        _banners[index] = MediaBanner(
          id: b.id,
          header: b.header,
          title: b.title,
          content: b.content,
          footer: b.footer,
          isActive: !b.isActive,
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
  }

  Future<void> _editBanner(MediaBanner banner) async {
    final headerController = TextEditingController(text: banner.header);
    final titleController = TextEditingController(text: banner.title);
    final contentController = TextEditingController(text: banner.content);
    final footerController = TextEditingController(text: banner.footer);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Info Masjid'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: headerController,
                  decoration: const InputDecoration(
                    labelText: 'Header / Kategori',
                    hintText: 'INFO MASJID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Isi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: footerController,
                  decoration: const InputDecoration(
                    labelText: 'Kaki / Catatan',
                    hintText: 'Amal Jariyah',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
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
          ],
        );
      },
    );
  }

  void _removeBanner(String id) {
    setState(() {
      _banners.removeWhere((item) => item.id == id);
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendBannersUpdate(_banners);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  void _addKasTransaction() {
    final amount = int.tryParse(_kasAmountController.text.trim()) ?? 0;
    final description = _kasDescriptionController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid (Rp).')),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Isi keterangan transaksi terlebih dahulu.')),
      );
      return;
    }

    final tx = KasTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _kasType,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    setState(() {
      _kasTransactions.insert(0, tx);
      _kasAmountController.clear();
      _kasDescriptionController.clear();
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendKasUpdate(_kasTransactions);
      setState(() {
        _hasUnsyncedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi Kas Dikirim ke TV!')),
      );
    }
  }

  void _removeKasTransaction(String id) {
    setState(() {
      _kasTransactions.removeWhere((item) => item.id == id);
      _hasUnsyncedChanges = true;
    });

    if (_isConnected) {
      _client.sendKasUpdate(_kasTransactions);
      setState(() {
        _hasUnsyncedChanges = false;
      });
    }
  }

  String _formatRupiah(int amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _p2pDevices = [];
      _p2pStatus = 'Memindai TV terdekat (WiFi Direct/BLE)...';
    });
    await _p2pClient.startScan((devices) {
      if (!mounted) return;
      setState(() {
        _p2pDevices = devices;
      });
    });
    if (mounted) {
      setState(() {
        _p2pStatus = 'Memindai... pilih TV yang muncul di bawah.';
      });
    }
  }

  Future<void> _stopScan() async {
    await _p2pClient.stopScan();
    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _connectP2p(BleDiscoveredDevice device) async {
    setState(() {
      _isScanning = false;
      _p2pStatus = 'Menghubungkan ke ${device.deviceName}...';
    });
    await _p2pClient.stopScan();
    final ok = await _p2pClient.connectTo(device);
    if (!mounted) return;
    setState(() {
      _p2pStatus = ok
          ? 'Terhubung WiFi Direct! Menunggu alamat IP TV...'
          : 'Gagal terhubung ke ${device.deviceName}. Coba lagi.';
    });
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
    _runningTextController.dispose();
    _bannerHeaderController.dispose();
    _bannerTitleController.dispose();
    _bannerContentController.dispose();
    _bannerFooterController.dispose();
    _kasAmountController.dispose();
    _kasDescriptionController.dispose();
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
      ),
      body: Column(
        children: [
          if (_hasUnsyncedChanges) _buildUnsyncedBanner(theme, colorScheme),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _buildConfigTab(theme, colorScheme),
                _buildRunningTextTab(theme, colorScheme),
                _buildInfoMasjidTab(theme, colorScheme),
                _buildKasTab(theme, colorScheme),
                _buildConnectivityTab(theme, colorScheme),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Running Text',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Info Masjid',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Kas',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_outlined),
            selectedIcon: Icon(Icons.wifi),
            label: 'Konektivitas',
          ),
        ],
      ),
    );
  }

  Widget _buildUnsyncedBanner(ThemeData theme, ColorScheme colorScheme) {
    return Material(
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 2, bottom: 2),
        child: Row(
          children: [
            Icon(
              Icons.sync_problem,
              size: 20,
              color: colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ada perubahan belum dikirim ke TV',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _pushAllToTv,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Kirim Ke TV'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTab(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Masjid',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Alamat Masjid',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Koordinat & Jadwal Sholat',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _latitudeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    hintText: '-6.2088',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _longitudeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    hintText: '106.8456',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isFetchingLocation ? null : _getLocationFromGps,
            icon: _isFetchingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: const Text('Ambil Koordinat dari GPS'),
          ),
          const SizedBox(height: 24),
          Text(
            'Koreksi (Offset) per Jadwal (menit)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jadwal dihitung offline dari koordinat. Isi offset untuk maju (+) atau mundur (-) tiap waktu.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in kAllPrayerTypes)
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _prayerOffsetControllers[type],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type.displayName,
                      suffixText: 'mnt',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _sendConfigUpdate,
            icon: const Icon(Icons.save),
            label: const Text('Simpan & Update Ke TV'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _showScheduleSimulation,
            icon: const Icon(Icons.calendar_month),
            label: const Text('Simulasi Jadwal'),
          ),
        ],
      ),
    );
  }

  void _showScheduleSimulation() {
    final config = _buildConfigFromForm();
    showDialog(
      context: context,
      builder: (context) {
        DateTime simDateTime = DateTime.now();
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final schedule = PrayerSchedule.calculate(config, simDateTime);
            return AlertDialog(
              title: const Text('Simulasi Jadwal'),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_month, size: 18),
                              label: Text(
                                DateFormat('dd MMM yyyy').format(simDateTime),
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
                          const SizedBox(width: 8),
                          Expanded(
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Lokasi: ${config.latitude.toStringAsFixed(4)}, ${config.longitude.toStringAsFixed(4)} (dihitung offline)',
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
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
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
          item.type.displayName,
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

  Widget _buildRunningTextTab(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _runningTextController,
                  decoration: const InputDecoration(
                    labelText: 'Tambah Teks Berjalan',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addRunningText,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _runningCategory,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
            items: _runningCategories
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _runningCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _runningTexts.length,
              itemBuilder: (context, index) {
                final item = _runningTexts[index];
                return Card(
                  child: ListTile(
                    title: Text(item.content),
                    subtitle: Text('Kategori: ${item.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editRunningText(item),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeRunningText(item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMasjidTab(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            'Tambah Info Masjid',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bannerHeaderController,
            decoration: const InputDecoration(
              labelText: 'Header / Kategori',
              hintText: 'INFO MASJID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bannerTitleController,
            decoration: const InputDecoration(
              labelText: 'Judul',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bannerContentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Isi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bannerFooterController,
            decoration: const InputDecoration(
              labelText: 'Kaki / Catatan',
              hintText: 'Amal Jariyah',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _addBanner,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Info Masjid'),
          ),
          const SizedBox(height: 24),
          Text(
            'Daftar Info Masjid',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_banners.isEmpty)
            Text(
              'Belum ada info masjid. Tambahkan di atas.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            )
          else
            ..._banners.map(
              (b) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.header,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.tertiary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Switch(
                            value: b.isActive,
                            onChanged: (_) => _toggleBanner(b.id),
                          ),
                        ],
                      ),
                      Text(
                        b.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (b.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(b.content),
                      ],
                      if (b.footer.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          b.footer,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _editBanner(b),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () => _removeBanner(b.id),
                            icon: const Icon(Icons.delete,
                                size: 18, color: Colors.red),
                            label: const Text('Hapus'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKasTab(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: _KasStatCard(
                  label: 'Saldo',
                  amount: _formatRupiah(
                    KasSummary.fromTransactions(_kasTransactions).saldo,
                  ),
                  icon: Icons.account_balance_wallet_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KasStatCard(
                  label: 'Pemasukan',
                  amount: _formatRupiah(
                    KasSummary.fromTransactions(_kasTransactions).totalMasuk,
                  ),
                  icon: Icons.arrow_downward_rounded,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KasStatCard(
                  label: 'Pengeluaran',
                  amount: _formatRupiah(
                    KasSummary.fromTransactions(_kasTransactions).totalKeluar,
                  ),
                  icon: Icons.arrow_upward_rounded,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tambah Transaksi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<KasType>(
                    segments: const [
                      ButtonSegment(
                        value: KasType.masuk,
                        label: Text('Masuk'),
                        icon: Icon(Icons.arrow_downward_rounded),
                      ),
                      ButtonSegment(
                        value: KasType.keluar,
                        label: Text('Keluar'),
                        icon: Icon(Icons.arrow_upward_rounded),
                      ),
                    ],
                    selected: {_kasType},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _kasType = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _kasAmountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Nominal (Rp)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                      hintText: '25000',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _kasDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(),
                      hintText: 'Infaq Jumat Berkah',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _addKasTransaction,
                    icon: const Icon(Icons.add),
                    label: const Text('Simpan Transaksi'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Riwayat Transaksi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._kasTransactions.map((tx) {
            final isMasuk = tx.type == KasType.masuk;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isMasuk
                      ? colorScheme.tertiaryContainer
                      : colorScheme.errorContainer,
                  child: Icon(
                    isMasuk
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isMasuk
                        ? colorScheme.onTertiaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                ),
                title: Text(tx.description),
                subtitle: Text(
                  DateFormat('d MMM yyyy, HH:mm').format(tx.date),
                ),
                trailing: Text(
                  '${isMasuk ? '+' : '-'}${_formatRupiah(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMasuk
                        ? colorScheme.tertiary
                        : colorScheme.error,
                  ),
                ),
                onLongPress: () => _removeKasTransaction(tx.id),
                dense: true,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConnectivityTab(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            color: _isConnected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koneksi Jaringan (WiFi/Router)',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ipController,
                          decoration: const InputDecoration(
                            labelText: 'IP Google TV Masjid',
                            hintText: '192.168.1.100',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isConnecting ? null : _connectToTv,
                        icon: _isConnecting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(_isConnected
                                ? Icons.check_circle
                                : Icons.connect_without_contact),
                        label:
                            Text(_isConnected ? 'Terhubung' : 'Sambungkan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_tethering, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'WiFi Direct (Tanpa Router)',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _isScanning ? _stopScan : _startScan,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.radar),
                        label: Text(_isScanning ? 'Stop' : 'Cari TV'),
                      ),
                    ],
                  ),
                  if (_isScanning) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                  if (_p2pStatus != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _p2pStatus!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                  if (_p2pDevices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ..._p2pDevices.map(
                      (d) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.tv),
                          title: Text(d.deviceName),
                          subtitle: Text(d.deviceAddress),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _connectP2p(d),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KasStatCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _KasStatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
