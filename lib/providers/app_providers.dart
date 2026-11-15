import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/audio_service.dart';
import '../services/ai_service.dart';
import '../models/note.dart';
import '../models/task.dart';
import '../models/voice_memo.dart';

final databaseProvider = Provider((ref) => DatabaseService());

final syncServiceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  final service = SyncService(db);
  service.startListening();
  ref.onDispose(() => service.dispose());
  return service;
});

final audioServiceProvider = Provider((ref) => AudioService());
final aiServiceProvider = Provider((ref) => AiService());

final notesProvider = FutureProvider.autoDispose<List<Note>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllNotes();
});

final tasksProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllTasks();
});

final memosProvider = FutureProvider.autoDispose<List<VoiceMemo>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllMemos();
});

final pendingCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.pendingCount();
});
