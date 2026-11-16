import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/models/task.dart';
import 'package:pocket_brain/models/sync_status.dart';

void main() {
  group('Task', () {
    test('create factory sets required fields and defaults', () {
      final now = DateTime.now();
      final task = Task.create(
        uuid: 'task-uuid-1',
        title: 'Buy milk',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.uuid, 'task-uuid-1');
      expect(task.title, 'Buy milk');
      expect(task.description, isNull);
      expect(task.isCompleted, false);
      expect(task.createdAt, now);
      expect(task.updatedAt, now);
      expect(task.syncStatus, SyncStatus.pending);
    });

    test('create factory accepts optional fields', () {
      final now = DateTime.now();
      final task = Task.create(
        uuid: 'task-uuid-2',
        title: 'Write tests',
        description: 'Cover all models',
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.conflict,
      );

      expect(task.description, 'Cover all models');
      expect(task.isCompleted, true);
      expect(task.syncStatus, SyncStatus.conflict);
    });

    test('empty constructor works', () {
      final task = Task();
      expect(task, isA<Task>());
    });
  });
}
