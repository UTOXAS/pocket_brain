import 'package:isar/isar.dart';
import 'sync_status.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  String? description;
  late bool isCompleted;
  late DateTime createdAt;
  late DateTime updatedAt;

  @enumerated
  late SyncStatus syncStatus;

  Task();

  Task.create({
    required this.uuid,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });
}
