import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('No notes yet.\nTap + to create one.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notesProvider);
              await ref.read(syncServiceProvider).syncNow();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(existing: note),
                      ),
                    ).then((_) {
                      ref.invalidate(notesProvider);
                      ref.invalidate(pendingCountProvider);
                    });
                  },
                  onDelete: () async {
                    await ref.read(databaseProvider).deleteNote(note.uuid);
                    ref.invalidate(notesProvider);
                    ref.invalidate(pendingCountProvider);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          ).then((_) {
            ref.invalidate(notesProvider);
            ref.invalidate(pendingCountProvider);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
