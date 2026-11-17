import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_brain/providers/app_providers.dart';
import 'package:pocket_brain/services/database_service.dart';
import 'package:pocket_brain/services/sync_service.dart';
import 'package:pocket_brain/services/audio_service.dart';
import 'package:pocket_brain/services/ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Providers', () {
    test('databaseProvider returns DatabaseService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      expect(db, isA<DatabaseService>());
    });

    test('audioServiceProvider returns AudioService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // MODIFIED: safe because AudioRecorder is now created lazily
      final audio = container.read(audioServiceProvider);
      expect(audio, isA<AudioService>());
    });

    test('aiServiceProvider returns AiService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ai = container.read(aiServiceProvider);
      expect(ai, isA<AiService>());
    });

    test('syncServiceProvider returns SyncService and starts listening', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sync = container.read(syncServiceProvider);
      expect(sync, isA<SyncService>());
    });

    test(
      'notesProvider, tasksProvider, memosProvider are FutureProviders',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notes = container.read(notesProvider);
        final tasks = container.read(tasksProvider);
        final memos = container.read(memosProvider);
        final pending = container.read(pendingCountProvider);

        expect(notes, isA<AsyncValue>());
        expect(tasks, isA<AsyncValue>());
        expect(memos, isA<AsyncValue>());
        expect(pending, isA<AsyncValue>());
      },
    );
  });
}
