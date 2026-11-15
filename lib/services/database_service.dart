import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import '../models/task.dart';
import '../models/voice_memo.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [NoteSchema, TaskSchema, VoiceMemoSchema],
      directory: dir.path,
      name: 'pocket_brain',
    );
    return _isar!;
  }

  // Notes
  Future<List<Note>> getAllNotes() async {
    final isar = await instance;
    return isar.notes.where().sortByUpdatedAtDesc().findAll();
  }

  Future<void> putNote(Note note) async {
    final isar = await instance;
    await isar.writeTxn(() => isar.notes.put(note));
  }

  Future<void> deleteNote(String uuid) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      final note = await isar.notes.filter().uuidEqualTo(uuid).findFirst();
      if (note != null) await isar.notes.delete(note.id);
    });
  }

  // Tasks
  Future<List<Task>> getAllTasks() async {
    final isar = await instance;
    return isar.tasks.where().sortByUpdatedAtDesc().findAll();
  }

  Future<void> putTask(Task task) async {
    final isar = await instance;
    await isar.writeTxn(() => isar.tasks.put(task));
  }

  Future<void> deleteTask(String uuid) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      final task = await isar.tasks.filter().uuidEqualTo(uuid).findFirst();
      if (task != null) await isar.tasks.delete(task.id);
    });
  }

  // Voice Memos
  Future<List<VoiceMemo>> getAllMemos() async {
    final isar = await instance;
    return isar.voiceMemos.where().sortByUpdatedAtDesc().findAll();
  }

  Future<void> putMemo(VoiceMemo memo) async {
    final isar = await instance;
    await isar.writeTxn(() => isar.voiceMemos.put(memo));
  }

  Future<void> deleteMemo(String uuid) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      final memo = await isar.voiceMemos.filter().uuidEqualTo(uuid).findFirst();
      if (memo != null) await isar.voiceMemos.delete(memo.id);
    });
  }

  Future<int> pendingCount() async {
    final isar = await instance;
    final notes = await isar.notes
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .count();
    final tasks = await isar.tasks
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .count();
    final memos = await isar.voiceMemos
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .count();
    return notes + tasks + memos;
  }
}
