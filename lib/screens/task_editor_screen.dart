import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/sync_status.dart';
import '../providers/app_providers.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  final Task? existing;
  const TaskEditorScreen({super.key, this.existing});

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _isCompleted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
    _isCompleted = widget.existing?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    final now = DateTime.now();
    final task =
        widget.existing ??
        Task.create(
          uuid: const Uuid().v4(),
          title: '',
          createdAt: now,
          updatedAt: now,
        );

    task.title = _titleCtrl.text.trim();
    task.description = _descCtrl.text.trim().isEmpty
        ? null
        : _descCtrl.text.trim();
    task.isCompleted = _isCompleted;
    task.updatedAt = now;
    task.syncStatus = SyncStatus.pending;

    await ref.read(databaseProvider).putTask(task);
    ref.invalidate(tasksProvider);
    ref.invalidate(pendingCountProvider);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Task' : 'Edit Task'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // ADDED: SingleChildScrollView so the form can't overflow
        // when the keyboard is open on small screens
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Completed'),
                value: _isCompleted,
                onChanged: (v) => setState(() => _isCompleted = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
