import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/models/task.dart';
import 'package:pocket_brain/models/sync_status.dart';
import 'package:pocket_brain/widgets/task_card.dart';

void main() {
  testWidgets('TaskCard displays title, checkbox and status', (tester) async {
    final task = Task.create(
      uuid: 't1',
      title: 'Complete unit tests',
      description: 'Write tests for all models and services',
      isCompleted: false,
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime(2024, 2, 1),
      syncStatus: SyncStatus.synced,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onTap: () {},
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Complete unit tests'), findsOneWidget);
    expect(find.textContaining('Write tests'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('TaskCard shows strikethrough when completed', (tester) async {
    final task = Task.create(
      uuid: 't2',
      title: 'Done task',
      isCompleted: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onTap: () {},
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text('Done task'));
    expect(textWidget.style?.decoration, TextDecoration.lineThrough);
  });
}
