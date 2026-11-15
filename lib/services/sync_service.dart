import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../models/task.dart';
import '../models/voice_memo.dart';
import '../models/sync_status.dart';
import 'database_service.dart';

class SyncService {
  final DatabaseService _db;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  SyncService(this._db);

  void startListening() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        // Debounced automatic sync
        Future.delayed(const Duration(seconds: 2), () => syncNow());
      }
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      // TODO: Replace with real backend calls in next step
      // POST /sync/push  (send all pending items)
      // GET  /sync/pull  (receive updates, last-write-wins by updatedAt)

      // For now we only mark local pending items as synced
      // so the UI works end-to-end offline + online indicator.
      final isar = await DatabaseService.instance;

      await isar.writeTxn(() async {
        final pendingNotes = await isar.notes
            .filter()
            .syncStatusEqualTo(SyncStatus.pending)
            .findAll();
        for (final n in pendingNotes) {
          n.syncStatus = SyncStatus.synced;
          await isar.notes.put(n);
        }

        final pendingTasks = await isar.tasks
            .filter()
            .syncStatusEqualTo(SyncStatus.pending)
            .findAll();
        for (final t in pendingTasks) {
          t.syncStatus = SyncStatus.synced;
          await isar.tasks.put(t);
        }

        final pendingMemos = await isar.voiceMemos
            .filter()
            .syncStatusEqualTo(SyncStatus.pending)
            .findAll();
        for (final m in pendingMemos) {
          m.syncStatus = SyncStatus.synced;
          await isar.voiceMemos.put(m);
        }
      });
    } finally {
      _isSyncing = false;
    }
  }

  // Future real implementation outline (for next backend step):
  // 1. Collect all items where syncStatus == pending
  // 2. POST them as delta batch with uuid + updatedAt
  // 3. Server returns accepted + any conflicts
  // 4. Pull remote changes newer than local max updatedAt
  // 5. Apply last-write-wins
}
