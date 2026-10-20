import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

/// Hasil impor backup.
///
/// Bila [success] `true`, [bundle] terisi dan [errorMessage] `null`.
/// Bila [success] `false`, [errorMessage] berisi pesan siap tampil ke user.
class BackupImportResult {
  final bool success;
  final BackupBundle? bundle;
  final String? errorMessage;

  const BackupImportResult._({
    required this.success,
    this.bundle,
    this.errorMessage,
  });

  /// Hasil berhasil — bundle terisi.
  factory BackupImportResult.ok(BackupBundle bundle) =>
      BackupImportResult._(success: true, bundle: bundle);

  /// Hasil gagal — pesan siap tampil ke user.
  factory BackupImportResult.failure(String message) =>
      BackupImportResult._(success: false, errorMessage: message);
}

/// Service export/import backup keadaan masjid ke/dari file JSON.
///
/// Export membungkus [StateSnapshot] ke dalam [BackupBundle] lalu menulis
/// file JSON lewat dialog save FilePicker. Import membaca file yang dipilih
/// user, memvalidasi format, dan mengembalikan [BackupImportResult].
class BackupService {
  /// Export [snapshot] ke file JSON.
  ///
  /// Mengembalikan path file hasil simpan, atau `null` bila user batal /
  /// terjadi error. Error dicetak ke `debugPrint`.
  Future<String?> exportToFile(
    StateSnapshot snapshot,
    String mosqueName,
  ) async {
    try {
      final now = DateTime.now();
      final slug = _slugify(mosqueName);
      final dateStr = '${now.year.toString().padLeft(4, '0')}'
          '-${now.month.toString().padLeft(2, '0')}'
          '-${now.day.toString().padLeft(2, '0')}';
      final fileName = '$slug-$dateStr.masjidyou.json';

      final bundle = BackupBundle(
        formatVersion: BackupBundle.currentFormatVersion,
        exportedAt: now,
        mosqueName: mosqueName,
        snapshot: snapshot,
      );

      final jsonStr =
          const JsonEncoder.withIndent('  ').convert(bundle.toMap());
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));

      final saved = await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/json',
        dialogTitle: 'Simpan backup data masjid',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (saved == null) return null;
      return saved.scheme == 'file' ? saved.toFilePath() : saved.toString();
    } catch (e, st) {
      debugPrint('BackupService.exportToFile error: $e\n$st');
      return null;
    }
  }

  /// Import backup dari file JSON yang dipilih user.
  ///
  /// Menampilkan dialog pilih file (ekstensi `.json`). Bila user batal atau
  /// file tidak valid, mengembalikan [BackupImportResult.failure] dengan
  /// pesan bahasa Indonesia siap tampil ke user.
  Future<BackupImportResult> importFromFile() async {
    List<PlatformFile> picked;
    try {
      picked = await FilePicker.pickFiles(
        dialogTitle: 'Pilih file backup',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
    } catch (e, st) {
      debugPrint('BackupService.importFromFile pickFiles error: $e\n$st');
      return BackupImportResult.failure('Gagal membuka pemilih file: $e');
    }

    // User batal / tidak memilih file apa pun.
    if (picked.isEmpty) {
      return BackupImportResult.failure('Impor dibatalkan.');
    }

    final file = picked.first;

    // Validasi ekstensi meskipun picker sudah memfilter.
    final name = file.name.toLowerCase();
    if (!name.endsWith('.json')) {
      return BackupImportResult.failure(
        'Ekstensi file salah. Hanya file .json yang didukung.',
      );
    }

    // Baca bytes: prioritas data inline, fallback baca dari path.
    Uint8List? bytes;
    final inline = await file.readAsBytes();
    if (inline.isNotEmpty) {
      bytes = inline;
    } else if (file.path != null) {
      try {
        bytes = await File(file.path!).readAsBytes();
      } catch (e, st) {
        debugPrint('BackupService.importFromFile readAsBytes error: $e\n$st');
        return BackupImportResult.failure('File tidak dapat dibaca: $e');
      }
    }

    if (bytes == null) {
      return BackupImportResult.failure('File tidak dapat dibaca.');
    }

    // Decode UTF-8.
    String jsonStr;
    try {
      jsonStr = utf8.decode(bytes);
    } catch (e, st) {
      debugPrint('BackupService.importFromFile utf8.decode error: $e\n$st');
      return BackupImportResult.failure(
        'File tidak dapat dibaca (encoding tidak dikenal): $e',
      );
    }

    // Parse JSON.
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonStr);
    } catch (e, st) {
      debugPrint('BackupService.importFromFile jsonDecode error: $e\n$st');
      return BackupImportResult.failure('File JSON rusak: $e');
    }

    if (decoded is! Map) {
      return BackupImportResult.failure(
        'File JSON rusak: format bukan objek.',
      );
    }

    // Parse BackupBundle — FormatException ditangkap khusus agar pesan
    // aslinya (mis. versi tidak didukung) langsung tampil ke user.
    try {
      final bundle = BackupBundle.fromMap(
        {for (final entry in decoded.entries) '${entry.key}': entry.value},
      );
      return BackupImportResult.ok(bundle);
    } on FormatException catch (e) {
      debugPrint('BackupService.importFromFile FormatException: $e');
      return BackupImportResult.failure(e.message);
    } catch (e, st) {
      debugPrint('BackupService.importFromFile error: $e\n$st');
      return BackupImportResult.failure('Gagal membaca backup: $e');
    }
  }

  /// Ubah nama masjid jadi slug aman untuk nama file.
  ///
  /// Lowercase, spasi jadi '-', buang karakter non-alfanumerik/dash.
  /// Bila kosong setelah proses, kembalikan `'masjid'`.
  String _slugify(String name) {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) return 'masjid';
    final slug = trimmed.replaceAll(' ', '-').replaceAll(
      RegExp(r'[^a-z0-9-]'),
      '',
    );
    return slug.isEmpty ? 'masjid' : slug;
  }
}