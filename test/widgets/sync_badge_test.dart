import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_brain/providers/app_providers.dart';
import 'package:pocket_brain/widgets/sync_badge.dart';

void main() {
  testWidgets('SyncBadge shows cloud_done when pending count is 0', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pendingCountProvider.overrideWith((ref) async => 0)],
        child: const MaterialApp(home: Scaffold(body: SyncBadge())),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
  });

  testWidgets('SyncBadge shows badge with count when pending > 0', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pendingCountProvider.overrideWith((ref) async => 3)],
        child: const MaterialApp(home: Scaffold(body: SyncBadge())),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
