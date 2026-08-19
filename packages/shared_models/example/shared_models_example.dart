import 'package:shared_models/shared_models.dart';

void main() {
  final config = const MosqueConfig(
    name: 'Masjid Al-Ikhlas',
    preAdhanMinutes: 15,
    adhanMinutes: 2,
    preIqomahMinutes: 1,
    shalatMinutes: 10,
  );

  final packet = SyncPacket(
    action: SyncAction.updateConfig,
    payload: config.toMap(),
  );

  print('SyncPacket JSON: ${packet.toJson()}');
}
