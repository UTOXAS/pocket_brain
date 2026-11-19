import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/voice_memo.dart';
import '../models/sync_status.dart';
import '../providers/app_providers.dart';
import '../widgets/memo_card.dart';

class MemosScreen extends ConsumerStatefulWidget {
  const MemosScreen({super.key});

  @override
  ConsumerState<MemosScreen> createState() => _MemosScreenState();
}

class _MemosScreenState extends ConsumerState<MemosScreen> {
  bool _isRecording = false;
  String? _currentPath;
  DateTime? _startTime;

  Future<void> _toggleRecord() async {
    final audio = ref.read(audioServiceProvider);
    if (_isRecording) {
      final path = await audio.stopRecording();
      if (path != null && _startTime != null) {
        final duration = DateTime.now().difference(_startTime!).inMilliseconds;
        final memo = VoiceMemo.create(
          uuid: const Uuid().v4(),
          localPath: path,
          durationMs: duration,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.read(databaseProvider).putMemo(memo);
        ref.invalidate(memosProvider);
        ref.invalidate(pendingCountProvider);
      }
      setState(() {
        _isRecording = false;
        _currentPath = null;
        _startTime = null;
      });
    } else {
      final path = await audio.startRecording();
      if (path != null) {
        setState(() {
          _isRecording = true;
          _currentPath = path;
          _startTime = DateTime.now();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memosAsync = ref.watch(memosProvider);

    return Scaffold(
      body: Column(
        children: [
          if (_isRecording)
            Container(
              width: double.infinity,
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Recording… Tap stop when finished'),
                ],
              ),
            ),
          Expanded(
            child: memosAsync.when(
              data: (memos) {
                if (memos.isEmpty) {
                  return const Center(child: Text('No voice memos yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: memos.length,
                  itemBuilder: (context, index) {
                    final memo = memos[index];
                    return MemoCard(
                      memo: memo,
                      onDelete: () async {
                        await ref.read(databaseProvider).deleteMemo(memo.uuid);
                        ref.invalidate(memosProvider);
                        ref.invalidate(pendingCountProvider);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // ADDED: unique heroTag to avoid conflict with other FABs in IndexedStack
        heroTag: 'memos_fab',
        onPressed: _toggleRecord,
        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
        label: Text(_isRecording ? 'Stop' : 'Record'),
        backgroundColor: _isRecording ? Colors.red : null,
      ),
    );
  }
}
