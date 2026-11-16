import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/models/voice_memo.dart';
import 'package:pocket_brain/models/sync_status.dart';

void main() {
  group('VoiceMemo', () {
    test('create factory sets required fields and defaults', () {
      final now = DateTime.now();
      final memo = VoiceMemo.create(
        uuid: 'memo-uuid-1',
        localPath: '/path/to/memo.m4a',
        durationMs: 12500,
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.uuid, 'memo-uuid-1');
      expect(memo.localPath, '/path/to/memo.m4a');
      expect(memo.transcription, isNull);
      expect(memo.durationMs, 12500);
      expect(memo.createdAt, now);
      expect(memo.updatedAt, now);
      expect(memo.syncStatus, SyncStatus.pending);
    });

    test('create factory accepts optional transcription and syncStatus', () {
      final now = DateTime.now();
      final memo = VoiceMemo.create(
        uuid: 'memo-uuid-2',
        localPath: '/tmp/test.m4a',
        transcription: 'Hello world',
        durationMs: 3000,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      );

      expect(memo.transcription, 'Hello world');
      expect(memo.syncStatus, SyncStatus.synced);
    });

    test('empty constructor works', () {
      final memo = VoiceMemo();
      expect(memo, isA<VoiceMemo>());
    });
  });
}
