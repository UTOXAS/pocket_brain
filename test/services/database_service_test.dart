import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pocket_brain/models/note.dart';
import 'package:pocket_brain/models/task.dart';
import 'package:pocket_brain/models/voice_memo.dart';
import 'package:pocket_brain/models/sync_status.dart';
import 'package:pocket_brain/services/database_service.dart';
import 'package:uuid/uuid.dart';

// Minimal fake PathProvider for unit tests (Windows-friendly)
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    // ADDED: Windows-compatible temp path
    return r'C:\Temp\pocket_brain_test';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService db;

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    // Open a temporary Isar instance for tests
    await DatabaseService.instance;
  });

  setUp(() {
    db = DatabaseService();
  });

  tearDownAll(() async {
    final isar = await DatabaseService.instance;
    await isar.close(deleteFromDisk: true);
  });

  group('DatabaseService – Notes', () {
    test('putNote + getAllNotes round-trip', () async {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final note = Note.create(
        uuid: uuid,
        title: 'Unit Test Note',
        content: 'Content of the note',
        createdAt: now,
        updatedAt: now,
      );

      await db.putNote(note);
      final all = await db.getAllNotes();

      expect(all.any((n) => n.uuid == uuid), isTrue);
      final saved = all.firstWhere((n) => n.uuid == uuid);
      expect(saved.title, 'Unit Test Note');
      expect(saved.content, 'Content of the note');
      expect(saved.syncStatus, SyncStatus.pending);
    });

    test('deleteNote removes the note', () async {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final note = Note.create(
        uuid: uuid,
        title: 'To Delete',
        content: '',
        createdAt: now,
        updatedAt: now,
      );
      await db.putNote(note);

      await db.deleteNote(uuid);
      final all = await db.getAllNotes();
      expect(all.any((n) => n.uuid == uuid), isFalse);
    });
  });

  group('DatabaseService – Tasks', () {
    test('putTask + getAllTasks round-trip', () async {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final task = Task.create(
        uuid: uuid,
        title: 'Unit Test Task',
        description: 'Desc',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      await db.putTask(task);
      final all = await db.getAllTasks();

      expect(all.any((t) => t.uuid == uuid), isTrue);
      final saved = all.firstWhere((t) => t.uuid == uuid);
      expect(saved.title, 'Unit Test Task');
      expect(saved.description, 'Desc');
      expect(saved.isCompleted, false);
    });

    test('deleteTask removes the task', () async {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final task = Task.create(
        uuid: uuid,
        title: 'Delete me',
        createdAt: now,
        updatedAt: now,
      );
      await db.putTask(task);

      await db.deleteTask(uuid);
      final all = await db.getAllTasks();
      expect(all.any((t) => t.uuid == uuid), isFalse);
    });
  });

  group('DatabaseService – VoiceMemos', () {
    test('putMemo + getAllMemos round-trip', () async {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final memo = VoiceMemo.create(
        uuid: uuid,
        localPath: r'C:\Temp\test.m4a',
        durationMs: 5000,
        createdAt: now,
        updatedAt: now,
      );

      await db.putMemo(memo);
      final all = await db.getAllMemos();

      expect(all.any((m) => m.uuid == uuid), isTrue);
      final saved = all.firstWhere((m) => m.uuid == uuid);
      expect(saved.localPath, r'C:\Temp\test.m4a');
      expect(saved.durationMs, 5000);
    });

    test('deleteMemo removes the memo', () async {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final memo = VoiceMemo.create(
        uuid: uuid,
        localPath: r'C:\Temp\del.m4a',
        durationMs: 1000,
        createdAt: now,
        updatedAt: now,
      );
      await db.putMemo(memo);

      await db.deleteMemo(uuid);
      final all = await db.getAllMemos();
      expect(all.any((m) => m.uuid == uuid), isFalse);
    });
  });

  group('DatabaseService – pendingCount', () {
    test('pendingCount returns non-negative integer', () async {
      final count = await db.pendingCount();
      expect(count, greaterThanOrEqualTo(0));
    });
  });
}
