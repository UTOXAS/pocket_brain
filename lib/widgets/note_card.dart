import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/sync_status.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          note.title.isEmpty ? 'Untitled' : note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty)
              Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            // MODIFIED: Row -> Wrap so date + chip wrap instead of overflowing
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  DateFormat.yMMMd().add_jm().format(note.updatedAt),
                  style: theme.textTheme.bodySmall,
                ),
                _statusChip(note.syncStatus, theme),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Widget _statusChip(SyncStatus status, ThemeData theme) {
    Color color;
    String label;
    switch (status) {
      case SyncStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case SyncStatus.synced:
        color = Colors.green;
        label = 'Synced';
        break;
      case SyncStatus.conflict:
        color = Colors.red;
        label = 'Conflict';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
