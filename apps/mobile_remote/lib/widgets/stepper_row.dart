import 'package:flutter/material.dart';

/// Baris stepper M3 (− nilai +) untuk angka menit di Pengaturan.
///
/// Nilai ditulis ke [controller] yang sama seperti field angka lama, jadi
/// alur simpan ([MosqueConfig] yang dibangun dari controller) tidak berubah.
/// Nilai ditampilkan lewat [ValueListenableBuilder] sehingga perubahan
/// controller dari luar (mis. sinkronisasi ulang dari `_config`) langsung
/// tercermin tanpa state tambahan.
class StepperRow extends StatelessWidget {
  const StepperRow({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.min = 0,
    this.max = 180,
    this.unit = 'mnt',
  });

  /// Label baris (mis. 'Subuh', 'Jelang Azan', 'Durasi Khutbah').
  final String label;

  /// Controller sumber kebenaran nilai (dipakai juga saat menyimpan).
  final TextEditingController controller;

  /// `false` menonaktifkan kedua tombol (mis. field Jumat saat Jumatan mati).
  final bool enabled;

  /// Batas bawah & atas nilai (inklusif).
  final int min;
  final int max;

  /// Satuan yang ditampilkan di samping nilai.
  final String unit;

  void _setValue(int value) {
    controller.text = value.clamp(min, max).toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final current = int.tryParse(value.text.trim()) ?? 0;
        return Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            IconButton(
              tooltip: 'Kurangi $label',
              icon: const Icon(Icons.remove),
              onPressed:
                  enabled && current > min ? () => _setValue(current - 1) : null,
            ),
            SizedBox(
              width: 76,
              child: Text(
                '$current $unit',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'Tambah $label',
              icon: const Icon(Icons.add),
              onPressed:
                  enabled && current < max ? () => _setValue(current + 1) : null,
            ),
          ],
        );
      },
    );
  }
}
