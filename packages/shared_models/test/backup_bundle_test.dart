import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('BackupBundle (export/import backup)', () {
    final exportedAt = DateTime(2026, 10, 20, 12, 30);
    final snapshot = StateSnapshot(
      config: const MosqueConfig(name: 'Masjid Al-Hikmah'),
      runningTexts: [
        RunningTextMessage(
          id: 'rt1',
          content: 'Kajian Sabtu',
          category: 'Kajian',
        ),
      ],
      hasData: true,
    );

    BackupBundle buildSample() => BackupBundle(
          exportedAt: exportedAt,
          mosqueName: 'Masjid Al-Hikmah',
          snapshot: snapshot,
        );

    test('round-trip toMap -> fromMap mempertahankan semua field', () {
      final bundle = buildSample();
      final parsed = BackupBundle.fromMap(bundle.toMap());

      expect(parsed, equals(bundle));
      expect(parsed.hashCode, equals(bundle.hashCode));
      expect(parsed.formatVersion,
          equals(BackupBundle.currentFormatVersion));
      expect(parsed.exportedAt, equals(exportedAt));
      expect(parsed.mosqueName, equals('Masjid Al-Hikmah'));
      expect(parsed.snapshot, equals(snapshot));
      expect(parsed.snapshot.hasData, isTrue);
    });

    test('fromMap melempar FormatException saat formatVersion hilang', () {
      final noVersion = buildSample().toMap();
      noVersion.remove('formatVersion');
      expect(
        () => BackupBundle.fromMap(noVersion),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap melempar FormatException saat formatVersion tidak dikenal', () {
      final unknownVersion = buildSample().toMap();
      unknownVersion['formatVersion'] = 99;
      expect(
        () => BackupBundle.fromMap(unknownVersion),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap melempar FormatException saat snapshot hilang', () {
      final noSnapshot = buildSample().toMap();
      noSnapshot.remove('snapshot');
      expect(
        () => BackupBundle.fromMap(noSnapshot),
        throwsA(isA<FormatException>()),
      );
    });

    test('equality & hashCode membedakan isi bundle', () {
      final bundle = buildSample();
      expect(bundle, equals(BackupBundle.fromMap(bundle.toMap())));

      final differentName = BackupBundle(
        exportedAt: exportedAt,
        mosqueName: 'Masjid An-Nur',
        snapshot: snapshot,
      );
      expect(bundle, isNot(equals(differentName)));

      final differentSnapshot = BackupBundle(
        exportedAt: exportedAt,
        mosqueName: bundle.mosqueName,
        snapshot: const StateSnapshot(),
      );
      expect(bundle, isNot(equals(differentSnapshot)));
    });
  });
}