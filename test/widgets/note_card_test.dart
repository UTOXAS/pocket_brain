import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/models/note.dart';
import 'package:pocket_brain/models/sync_status.dart';
import 'package:pocket_brain/widgets/note_card.dart';

void main() {
  testWidgets('NoteCard displays title, content snippet and status', (
    tester,
  ) async {
    final note = Note.create(
      uuid: 'n1',
      title: 'Test Note Title',
      content:
          'This is the content of the note that should be truncated if too long.',
      createdAt: DateTime(2024, 1, 15, 10, 30),
      updatedAt: DateTime(2024, 1, 15, 10, 30),
      syncStatus: SyncStatus.pending,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCard(note: note, onTap: () {}, onDelete: () {}),
        ),
      ),
    );

    expect(find.text('Test Note Title'), findsOneWidget);
    expect(find.textContaining('This is the content'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('NoteCard shows Untitled when title is empty', (tester) async {
    final note = Note.create(
      uuid: 'n2',
      title: '',
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCard(note: note, onTap: () {}, onDelete: () {}),
        ),
      ),
    );

    expect(find.text('Untitled'), findsOneWidget);
  });
}
