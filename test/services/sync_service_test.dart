import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pocket_brain/services/database_service.dart';
import 'package:pocket_brain/services/sync_service.dart';
import 'package:pocket_brain/models/note.dart';
import 'package:pocket_brain/models/sync_status.dart';
import 'package:uuid/uuid.dart';

// ADDED: same fake path provider used by database tests
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return r'C:\Temp\pocket_brain_test';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService db;
  late SyncService syncService;

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    // ADDED: required for Isar in unit tests
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    db = DatabaseService();
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
      final future1 = syncService.syncNow();
      final future2 = syncService.syncNow();
      await Future.wait([future1, future2]);
    });

    test('dispose cancels connectivity subscription without error', () {
      expect(() => syncService.dispose(), returnsNormally);
    });
  });
}
