import 'package:isar/isar.dart';
import 'sync_status.dart';

part 'voice_memo.g.dart';

@collection
class VoiceMemo {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String localPath;
  String? transcription;
  late int durationMs;
  late DateTime createdAt;
  late DateTime updatedAt;

  @enumerated
  late SyncStatus syncStatus;

  VoiceMemo();

  VoiceMemo.create({
    required this.uuid,
    required this.localPath,
    this.transcription,
    required this.durationMs,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });
}
