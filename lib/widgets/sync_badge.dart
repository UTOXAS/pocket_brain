import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class SyncBadge extends ConsumerWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingCountProvider);
    return pendingAsync.when(
      data: (count) {
        if (count == 0) {
          return IconButton(
            icon: const Icon(Icons.cloud_done_outlined),
            tooltip: 'All synced',
            onPressed: () => ref.read(syncServiceProvider).syncNow(),
          );
        }
        return Badge(
          label: Text('$count'),
          child: IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: '$count pending',
            onPressed: () => ref.read(syncServiceProvider).syncNow(),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.cloud_off),
    );
  }
}
