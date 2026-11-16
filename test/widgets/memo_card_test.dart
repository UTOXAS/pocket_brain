import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/models/voice_memo.dart';
import 'package:pocket_brain/models/sync_status.dart';
import 'package:pocket_brain/widgets/memo_card.dart';

void main() {
  testWidgets('MemoCard displays duration and status', (tester) async {
    final memo = VoiceMemo.create(
      uuid: 'm1',
      localPath: '/tmp/memo.m4a',
      durationMs: 125000, // 2:05
      createdAt: DateTime(2024, 3, 10, 14, 0),
      updatedAt: DateTime(2024, 3, 10, 14, 0),
      syncStatus: SyncStatus.pending,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemoCard(memo: memo, onDelete: () {}),
        ),
      ),
    );

    expect(find.textContaining('2:05'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });

  testWidgets('MemoCard shows transcription when present', (tester) async {
    final memo = VoiceMemo.create(
      uuid: 'm2',
      localPath: '/tmp/t.m4a',
      transcription: 'This is a transcribed voice memo.',
      durationMs: 3000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemoCard(memo: memo, onDelete: () {}),
        ),
      ),
    );

    expect(find.textContaining('transcribed voice memo'), findsOneWidget);
  });
}
