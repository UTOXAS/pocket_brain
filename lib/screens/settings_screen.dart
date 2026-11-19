import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('PocketBrain', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Local-first • Essential Cloud Sync'),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Force Sync Now'),
            subtitle: const Text('Push pending changes'),
            onTap: () async {
              await ref.read(syncServiceProvider).syncNow();
              // MODIFIED: invalidate all list providers so status chips update
              ref.invalidate(pendingCountProvider);
              ref.invalidate(notesProvider);
              ref.invalidate(tasksProvider);
              ref.invalidate(memosProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Sync completed')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text(
              'v1.0.0 • Gemini model: ${AppConstants.geminiModel}',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI uses free Gemini Flash tier (no credit card required).\n'
            'Set your API key via --dart-define=GEMINI_API_KEY=your_key',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
