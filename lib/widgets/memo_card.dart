import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voice_memo.dart';
import '../models/sync_status.dart';

class MemoCard extends StatelessWidget {
  final VoiceMemo memo;
  final VoidCallback onDelete;

  const MemoCard({super.key, required this.memo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = Duration(milliseconds: memo.durationMs);
    final durationStr =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.mic)),
        title: Text('Voice Memo • $durationStr'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (memo.transcription != null && memo.transcription!.isNotEmpty)
              Text(
                memo.transcription!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  DateFormat.yMMMd().add_jm().format(memo.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                _statusChip(memo.syncStatus, theme),
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
