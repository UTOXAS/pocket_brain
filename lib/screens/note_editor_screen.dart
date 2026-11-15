import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/sync_status.dart';
import '../providers/app_providers.dart';
import '../services/ai_service.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? existing;
  const NoteEditorScreen({super.key, this.existing});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _isSaving = false;
  String? _aiResult;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final now = DateTime.now();
    final note =
        widget.existing ??
        Note.create(
          uuid: const Uuid().v4(),
          title: '',
          content: '',
          createdAt: now,
          updatedAt: now,
        );

    note.title = _titleCtrl.text.trim();
    note.content = _contentCtrl.text.trim();
    note.updatedAt = now;
    note.syncStatus = SyncStatus.pending;

    await ref.read(databaseProvider).putNote(note);
    ref.invalidate(notesProvider);
    ref.invalidate(pendingCountProvider);

    if (mounted) Navigator.pop(context);
  }

  Future<void> _runAi(String action) async {
    final ai = ref.read(aiServiceProvider);
    final text = _contentCtrl.text;
    setState(() => _aiResult = 'Working…');
    try {
      if (action == 'summarize') {
        final result = await ai.summarize(text);
        setState(() => _aiResult = result);
      } else {
        final items = await ai.extractActionItems(text);
        setState(() => _aiResult = items.join('\n'));
      }
    } catch (e) {
      setState(() => _aiResult = 'AI error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Note' : 'Edit Note'),
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
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Start typing…',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_aiResult != null) ...[
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AI Result',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_aiResult!),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _runAi('summarize'),
                    icon: const Icon(Icons.summarize),
                    label: const Text('Summarize'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _runAi('actions'),
                    icon: const Icon(Icons.checklist),
                    label: const Text('Action Items'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
