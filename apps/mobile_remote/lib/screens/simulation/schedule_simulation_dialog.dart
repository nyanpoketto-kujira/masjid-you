import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

import '../home/home_tab.dart' show formatTanggalId;

/// Dialog "Simulasi Perhitungan Jadwal" (Pengaturan → Simulasi Jadwal).
///
/// Menampilkan jadwal shalat hasil [PrayerSchedule.calculate] untuk
/// tanggal/jam pilihan DKM, dengan baris shalat berikutnya disorot.
///
/// Label tanggal memakai [formatTanggalId] (format manual, konvensi
/// yang sama dengan Beranda) dan BUKAN `DateFormat(..., 'id_ID')`:
/// data locale intl tidak terinisialisasi di app ini, sehingga versi
/// lama dialog melempar `LocaleDataException` saat dibangun dan
/// dialog tampil kosong/blank (ADR-033). Berkat format manual,
/// dialog ini tidak bergantung pada inisialisasi locale sama sekali.
class ScheduleSimulationDialog extends StatefulWidget {
  /// Konfigurasi dari form Pengaturan (koordinat + offset terkini).
  final MosqueConfig config;

  /// Apakah label Dzuhur di hari Jumat diganti "Jumat".
  final bool hasFridayPrayer;

  /// Waktu awal simulasi; default `DateTime.now()`. Diisi eksplisit
  /// oleh test agar hasilnya deterministik.
  final DateTime? initialDateTime;

  const ScheduleSimulationDialog({
    super.key,
    required this.config,
    required this.hasFridayPrayer,
    this.initialDateTime,
  });

  @override
  State<ScheduleSimulationDialog> createState() =>
      _ScheduleSimulationDialogState();
}

class _ScheduleSimulationDialogState extends State<ScheduleSimulationDialog> {
  late DateTime _simDateTime;

  @override
  void initState() {
    super.initState();
    _simDateTime = widget.initialDateTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = PrayerSchedule.calculate(widget.config, _simDateTime);

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
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(formatTanggalId(_simDateTime)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _simDateTime,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _simDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              _simDateTime.hour,
                              _simDateTime.minute,
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
                        DateFormat('HH:mm').format(_simDateTime),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_simDateTime),
                        );
                        if (picked != null) {
                          setState(() {
                            _simDateTime = DateTime(
                              _simDateTime.year,
                              _simDateTime.month,
                              _simDateTime.day,
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
                'Lokasi: ${widget.config.latitude.toStringAsFixed(4)}, ${widget.config.longitude.toStringAsFixed(4)} (dihitung offline)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final item in schedule.items)
                _buildSimulationRow(context, schedule, item),
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
  }

  Widget _buildSimulationRow(
    BuildContext context,
    PrayerSchedule schedule,
    PrayerScheduleItem item,
  ) {
    final isNext = schedule.nextPrayer == item.type;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isNext ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          isNext ? Icons.alarm_on : Icons.schedule,
          color:
              isNext ? Theme.of(context).colorScheme.onPrimaryContainer : null,
        ),
        title: Text(
          item.type.displayNameForDate(
            item.time,
            hasFridayPrayer: widget.hasFridayPrayer,
          ),
          style: isNext ? const TextStyle(fontWeight: FontWeight.bold) : null,
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
}
