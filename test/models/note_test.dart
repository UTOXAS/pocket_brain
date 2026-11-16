import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/models/note.dart';
import 'package:pocket_brain/models/sync_status.dart';

void main() {
  group('Note', () {
    test('create factory sets required fields and default syncStatus', () {
      final now = DateTime.now();
      final note = Note.create(
        uuid: 'test-uuid-123',
        title: 'Test Title',
        content: 'Test content',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.uuid, 'test-uuid-123');
      expect(note.title, 'Test Title');
      expect(note.content, 'Test content');
      expect(note.createdAt, now);
      expect(note.updatedAt, now);
      expect(note.syncStatus, SyncStatus.pending);
      expect(note.id, Isar.autoIncrement); // default
    });

    test('create factory accepts explicit syncStatus', () {
      final now = DateTime.now();
      final note = Note.create(
        uuid: 'uuid-2',
        title: 'Title',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      );
      expect(note.syncStatus, SyncStatus.synced);
    });

    test('empty constructor works', () {
      final note = Note();
      expect(note, isA<Note>());
    });
  });
}
