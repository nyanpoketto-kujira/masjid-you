import 'package:flutter/material.dart';

/// Side panel menu admin TV — slide-in dari sisi KANAN, full height.
///
/// Dibuka dengan menekan tombol Back pada remote. Berisi:
/// - Toggle "Nyalakan Koneksi" (baru di sini Bluetooth discoverable
///   diminta, sehingga tidak ada popup sistem saat app pertama dibuka).
/// - PIN 4 digit acak yang harus dimasukkan Remote agar bisa terhubung.
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

  /// Dipanggil saat PIN diketuk (salin ke clipboard).
  final VoidCallback onCopyPin;

  const AdminMenuOverlay({
    super.key,
    required this.btEnabled,
    required this.pin,
    required this.statusText,
    required this.isError,
    required this.onToggleBluetooth,
    required this.onClose,
    required this.onCopyPin,
  });

  @override
  State<AdminMenuOverlay> createState() => _AdminMenuOverlayState();
}

class _AdminMenuOverlayState extends State<AdminMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideIn;
  late final Animation<Offset> _slideOut;

  /// `true` saat animasi keluar sedang berjalan (hindari double-close).
  bool _closing = false;

  @override
  void initState() {
    super.initState();
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dim background — ketuk untuk menutup.
          GestureDetector(
            onTap: _close,
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
                        child: Row(
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
                            IconButton(
                              onPressed: _close,
                              tooltip: 'Tutup',
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Aktifkan koneksi hanya saat diperlukan. PIN '
                          'ditampilkan agar hanya Remote yang tahu PIN yang '
                          'bisa terhubung.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Konten scrollable agar aman di layar pendek.
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Toggle Nyalakan Koneksi — kotak rounded biasa.
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: SwitchListTile(
                                  value: widget.btEnabled,
                                  onChanged: widget.onToggleBluetooth,
                                  title: Text(
                                    'Nyalakan Koneksi',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Bluetooth Classic (RFCOMM) siap '
                                    'menerima Remote',
                                  ),
                                  secondary: Icon(
                                    widget.btEnabled
                                        ? Icons.bluetooth_connected
                                        : Icons.bluetooth_disabled,
                                    color: widget.btEnabled
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    size: 28,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Status koneksi
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
                                              ? 'Koneksi aktif — tunggu Remote '
                                                  'menyambung'
                                              : 'Koneksi nonaktif'),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: widget.isError
                                            ? colorScheme.error
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // PIN (hanya tampil saat koneksi aktif)
                              if (widget.btEnabled && widget.pin != null) ...[
                                const SizedBox(height: 20),
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
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.pin!,
                                            style: theme.textTheme.displayMedium
                                                ?.copyWith(
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 12,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: widget.onCopyPin,
                                            tooltip: 'Salin PIN',
                                            icon: Icon(
                                              Icons.copy,
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Masukkan PIN ini di aplikasi Remote '
                                        'untuk terhubung.',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),

                              // Tombol navigasi
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FilledButton.icon(
                                    onPressed: _close,
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('Kembali'),
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
        ],
      ),
    );
  }
}
