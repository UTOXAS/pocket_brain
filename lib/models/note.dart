import 'package:isar/isar.dart';
import 'sync_status.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement; // local Isar id

  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  late String content;
  late DateTime createdAt;
  late DateTime updatedAt;

  @enumerated
  late SyncStatus syncStatus;

  Note();

  Note.create({
    required this.uuid,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });
}
