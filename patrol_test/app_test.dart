import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:pocket_brain/main.dart';
import 'package:pocket_brain/services/database_service.dart';
import 'package:pocket_brain/widgets/memo_card.dart';

void main() {
  patrolTest(
    'PocketBrain full manual flow – fast human speed',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      // ---------- helpers (human-like pacing) ----------
      Future<void> humanPause([int ms = 800]) async {
        await Future<void>.delayed(Duration(milliseconds: ms));
        await $.pump(const Duration(milliseconds: 100));
      }

      Future<void> tapAndPause(PatrolFinder finder, [int ms = 800]) async {
        await finder.tap();
        await humanPause(ms);
      }

      // ---------- 0. Launch ----------
      await DatabaseService.instance; // warm Isar
      await $.pumpWidgetAndSettle(const ProviderScope(child: PocketBrainApp()));
      await humanPause(1200);

      // Verify we start on Notes
      expect($('PocketBrain'), findsOneWidget);
      expect($('Notes'), findsOneWidget);

      // =================================================
      // 1. NOTES – create with exact sample data
      // =================================================
      await $(Icons.add).tap();
      await humanPause(900);

      await $(TextField).first.enterText('Weekly sync notes');
      await humanPause(600);

      await $(TextField)
          .at(1)
          .enterText(
            'Discussed progress on the new feature.\n'
            'Need to finish the UI mockups by Thursday.\n'
            'Backend API is ready for testing.\n'
            'Schedule a demo with the product team next Monday.',
          );
      await humanPause(700);

      await $(Icons.check).tap();
      await humanPause(1100);

      expect($('Weekly sync notes'), findsOneWidget);
      expect($('Pending'), findsWidgets);

      // =================================================
      // 2. Edit the note + AI features
      // =================================================
      await $('Weekly sync notes').tap();
      await humanPause(900);

      await $(TextField).first.enterText('Weekly sync notes (updated)');
      await humanPause(500);

      await $('Summarize').tap();
      await humanPause(2500);

      await $('Action Items').tap();
      await humanPause(2500);

      await $(Icons.check).tap();
      await humanPause(1000);

      expect($('Weekly sync notes (updated)'), findsOneWidget);

      // =================================================
      // 3. TASKS
      // =================================================
      await $('Tasks').tap();
      await humanPause(800);

      await $(Icons.add).tap();
      await humanPause(800);

      await $(TextField).first.enterText('Finish UI mockups');
      await humanPause(500);
      await $(TextField)
          .at(1)
          .enterText(
            'Include both light and dark mode versions. Deadline Thursday.',
          );
      await humanPause(500);

      await $(Icons.check).tap();
      await humanPause(1000);

      expect($('Finish UI mockups'), findsOneWidget);

      await $(Checkbox).tap();
      await humanPause(700);

      // =================================================
      // 4. MEMOS (voice)
      // =================================================
      await $('Memos').tap();
      await humanPause(800);

      // Start recording
      await $('Record').tap();

      // MODIFIED: wait up to 5s for the native permission dialog (was a single
      // 1s check that swallowed all errors) and grant it.
      try {
        if (await $.native.isPermissionDialogVisible(
          timeout: const Duration(seconds: 5),
        )) {
          await $.native.grantPermissionWhenInUse();
          await humanPause(800);
        }
      } catch (e) {
        // ignore: avoid_print
        print('Permission dialog handling skipped: $e');
      }

      // Wait a bit while "recording"
      await humanPause(1800);

      // Stop
      await $('Stop').tap();
      await humanPause(1200);

      await $(MemoCard).waitUntilVisible(timeout: const Duration(seconds: 10));
      expect($(MemoCard), findsOneWidget);

      // =================================================
      // 5. SYNC (badge + Settings)
      // =================================================
      await $('Notes').tap();
      await humanPause(700);

      await $(Icons.cloud_upload_outlined).tap();
      await humanPause(1500);

      await $('Settings').tap();
      await humanPause(800);

      await $('Force Sync Now').tap();
      await humanPause(1500);

      // =================================================
      // 6. Cleanup – delete everything
      // =================================================
      await $('Notes').tap();
      await humanPause(600);
      while ($(Icons.delete_outline).evaluate().isNotEmpty) {
        await $(Icons.delete_outline).first.tap();
        await humanPause(600);
      }

      await $('Tasks').tap();
      await humanPause(600);
      while ($(Icons.delete_outline).evaluate().isNotEmpty) {
        await $(Icons.delete_outline).first.tap();
        await humanPause(600);
      }

      await $('Memos').tap();
      await humanPause(600);
      while ($(Icons.delete_outline).evaluate().isNotEmpty) {
        await $(Icons.delete_outline).first.tap();
        await humanPause(600);
      }

      await humanPause(1000);

      expect($('No voice memos yet.'), findsOneWidget);

      await $('Notes').tap();
      await humanPause(600);
      expect(find.textContaining('No notes yet'), findsOneWidget);
    },
  );
}
