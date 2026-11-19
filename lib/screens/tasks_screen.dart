import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_status.dart';
import '../providers/app_providers.dart';
import '../widgets/task_card.dart';
import 'task_editor_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet.\nTap + to create one.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // MODIFIED: sync first, then invalidate so fresh data is loaded
              await ref.read(syncServiceProvider).syncNow();
              ref.invalidate(tasksProvider);
              ref.invalidate(pendingCountProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskEditorScreen(existing: task),
                      ),
                    ).then((_) {
                      ref.invalidate(tasksProvider);
                      ref.invalidate(pendingCountProvider);
                    });
                  },
                  onToggle: () async {
                    task.isCompleted = !task.isCompleted;
                    task.updatedAt = DateTime.now();
                    task.syncStatus = SyncStatus.pending;
                    await ref.read(databaseProvider).putTask(task);
                    ref.invalidate(tasksProvider);
                    ref.invalidate(pendingCountProvider);
                  },
                  onDelete: () async {
                    await ref.read(databaseProvider).deleteTask(task.uuid);
                    ref.invalidate(tasksProvider);
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
        heroTag: 'tasks_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
          ).then((_) {
            ref.invalidate(tasksProvider);
            ref.invalidate(pendingCountProvider);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
