import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/models/sync_status.dart';

void main() {
  group('SyncStatus', () {
    test('has expected values', () {
      expect(SyncStatus.values.length, 3);
      expect(SyncStatus.pending.index, 0);
      expect(SyncStatus.synced.index, 1);
      expect(SyncStatus.conflict.index, 2);
    });

    test('toString returns correct names', () {
      expect(SyncStatus.pending.toString(), 'SyncStatus.pending');
      expect(SyncStatus.synced.toString(), 'SyncStatus.synced');
      expect(SyncStatus.conflict.toString(), 'SyncStatus.conflict');
    });
  });
}
