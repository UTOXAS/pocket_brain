import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/services/database_service.dart';
import 'package:pocket_brain/services/sync_service.dart';
import 'package:pocket_brain/models/note.dart';
import 'package:pocket_brain/models/sync_status.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService db;
  late SyncService syncService;

  setUp(() async {
    db = DatabaseService();
    // Ensure Isar is open
    await DatabaseService.instance;
    syncService = SyncService(db);
  });

  tearDown(() {
    syncService.dispose();
  });

  group('SyncService', () {
    test('syncNow marks pending notes as synced', () async {
      final uuid = const Uuid().v4();
      final now = DateTime.now();
      final note = Note.create(
        uuid: uuid,
        title: 'Pending Note',
        content: 'Will be synced',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );
      await db.putNote(note);

      await syncService.syncNow();

      final all = await db.getAllNotes();
      final updated = all.firstWhere((n) => n.uuid == uuid);
      expect(updated.syncStatus, SyncStatus.synced);
    });

    test('syncNow is idempotent when already syncing', () async {
      // Calling twice in quick succession should not throw
      final future1 = syncService.syncNow();
      final future2 = syncService.syncNow();
      await Future.wait([future1, future2]);
      // No exception = success
    });

    test('dispose cancels connectivity subscription without error', () {
      expect(() => syncService.dispose(), returnsNormally);
    });
  });
}
