import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Side panel menu admin TV — slide-in dari sisi KANAN, full height.
///
/// Dibuka dengan menekan tombol Back pada remote. Berisi:
/// - Toggle "Nyalakan Koneksi" (baru di sini Bluetooth discoverable
///   diminta, sehingga tidak ada popup sistem saat app pertama dibuka).
/// - PIN 4 digit acak yang harus dimasukkan Remote agar bisa terhubung.
///   Kartu PIN ditampilkan besar di bagian atas panel.
///
/// Ramah remote D-Pad (Android TV):
/// - Fokus dikelola manual: daftar aksi (toggle → kembali)
///   dinavigasikan dengan D-Pad Atas/Bawah; OK memicu aksi aktif.
/// - Fokus pertama (toggle) di-autofocus saat panel terbuka agar kursor
///   remote tidak nyasar ke konten latar belakang.
/// - Indikator fokus kontras: border teal 2px + glow halus pada item aktif.
/// - Tombol Back menutup panel (PopScope internal + pemetaan tombol back).
///
/// Semua container memakai [RoundedRectangleBorder] eksplisit (radius 12/16)
/// untuk menimpa `cardTheme` global yang memakai M3ShapeBorder puffy —
/// bentuk scalloped yang rusak saat di-stretch di panel sempit.
class AdminMenuOverlay extends StatefulWidget {
  /// Status koneksi Bluetooth aktif (toggle ON/OFF).
  final bool btEnabled;

  /// PIN 4 digit yang ditampilkan; `null` bila koneksi belum aktif.
  final String? pin;

  /// Teks status Bluetooth dari host (idle/listening/connected/error).
  final String? statusText;

  /// `true` bila status host menandakan error (untuk warna status).
  final bool isError;

  /// Dipanggil saat toggle koneksi diubah.
  final ValueChanged<bool> onToggleBluetooth;

  /// Dipanggil setelah animasi slide-out selesai (panel benar-benar tertutup).
  final VoidCallback onClose;
  const AdminMenuOverlay({
    super.key,
    required this.btEnabled,
    required this.pin,
    required this.statusText,
    required this.isError,
    required this.onToggleBluetooth,
    required this.onClose,
  });


  @override
  State<AdminMenuOverlay> createState() => _AdminMenuOverlayState();
}

class _AdminMenuOverlayState extends State<AdminMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideIn;
  late final Animation<Offset> _slideOut;

  /// Scope fokus panel: saat panel terbuka, scope ini mengambil alih fokus
  /// dari layar utama; saat panel tertutup, fokus otomatis kembali.
  late final FocusScopeNode _panelScope;

  /// `true` saat animasi keluar sedang berjalan (hindari double-close).
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _panelScope = FocusScopeNode(debugLabel: 'adminPanelScope');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slideIn = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(curve);
    _slideOut = Tween<Offset>(begin: Offset.zero, end: const Offset(1, 0))
        .animate(curve);
    // Mulai animasi slide-in dari kanan.
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _panelScope.dispose();
    super.dispose();
  }

  /// Tutup panel dengan animasi slide-out, lalu panggil [AdminMenuOverlay.onClose].
  void _close() {
    if (_closing) return;
    _closing = true;
    _controller.reverse().whenComplete(() {
      if (mounted) widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Daftar aksi D-Pad: toggle di awal (autofocus), kembali di akhir.
    final showPin = widget.btEnabled && widget.pin != null;
    final actions = <_AdminAction>[
      _AdminAction(
        icon: widget.btEnabled
            ? Icons.bluetooth_connected
            : Icons.bluetooth_disabled,
        label: 'Nyalakan Koneksi',
        subtitle: 'Bluetooth Classic (RFCOMM) siap menerima Remote',
        selected: widget.btEnabled,
        onActivate: () => widget.onToggleBluetooth(!widget.btEnabled),
      ),
      _AdminAction(
        icon: Icons.arrow_back,
        label: 'Kembali',
        subtitle: 'Tutup menu admin',
        onActivate: _close,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: FocusScope(
        node: _panelScope,
        // Autofocus scope: fokus jatuh ke item pertama (lihat _FocusableAction).
        autofocus: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Scrim gelap pekat — ketuk untuk menutup.
            GestureDetector(
              onTap: _close,
              child: Container(color: Colors.black.withValues(alpha: 0.85)),
            ),

            // Slide-in side panel dari kanan, full height.
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: _closing ? _slideOut : _slideIn,
                child: Container(
                  width: 400,
                  height: double.infinity,
                  color: colorScheme.surfaceContainerHigh,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(Icons.admin_panel_settings,
                                  size: 28, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Menu Admin',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aktifkan koneksi hanya saat diperlukan. PIN '
                            'ditampilkan agar hanya Remote yang tahu PIN yang '
                            'bisa terhubung.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Kartu PIN 4-digit — PALING ATAS agar langsung
                          // terbaca dari jarak jauh tanpa navigasi D-Pad.
                          if (showPin) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    'PIN Koneksi',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.pin!,
                                    style: theme.textTheme.displayMedium
                                        ?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 12,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Masukkan PIN ini di aplikasi Remote '
                                    'untuk terhubung.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Daftar aksi D-Pad (scrollable agar aman di layar pendek).
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < actions.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 12),
                                    _FocusableAction(
                                      action: actions[i],
                                      autofocus: i == 0,
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  // Status koneksi (display-only).
                                  Row(
                                    children: [
                                      Icon(
                                        widget.isError
                                            ? Icons.error_outline
                                            : (widget.btEnabled
                                                ? Icons.check_circle_outline
                                                : Icons.info_outline),
                                        size: 18,
                                        color: widget.isError
                                            ? colorScheme.error
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.statusText ??
                                              (widget.btEnabled
                                                  ? 'Koneksi aktif — tunggu '
                                                      'Remote menyambung'
                                                  : 'Koneksi nonaktif'),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: widget.isError
                                                ? colorScheme.error
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Definisi satu aksi di daftar menu admin.
class _AdminAction {
  final IconData icon;
  final String label;
  final String subtitle;

  /// `true` bila aksi menandakan keadaan ON (ikon berwarna primary).
  final bool selected;
  final VoidCallback onActivate;

  const _AdminAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.selected = false,
    required this.onActivate,
  });
}

/// Item aksi yang bisa difokuskan remote D-Pad: border teal 2px + glow
/// saat disorot, OK/Enter memicu [onActivate].
class _FocusableAction extends StatefulWidget {
  final _AdminAction action;

  /// `true` pada item pertama agar fokus awal panel tidak nyasar.
  final bool autofocus;

  const _FocusableAction({required this.action, this.autofocus = false});

  @override
  State<_FocusableAction> createState() => _FocusableActionState();
}

class _FocusableActionState extends State<_FocusableAction> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final action = widget.action;

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // OK remote / Enter keyboard = aktifkan aksi.
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            action.onActivate();
            return KeyEventResult.handled;
          }
          // Back remote (beberapa TV mengirim goBack sebagai key) = tutup panel.
          if (event.logicalKey == LogicalKeyboardKey.goBack) {
            context
                .findAncestorStateOfType<_AdminMenuOverlayState>()
                ?._close();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: action.onActivate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _focused
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focused
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: _focused ? 2 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ListTile(
            leading: Icon(
              action.icon,
              color: action.selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 28,
            ),
            title: Text(
              action.label,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(action.subtitle),
            trailing: action.selected
                ? Icon(Icons.toggle_on, color: colorScheme.primary, size: 32)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }
}
