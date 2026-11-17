import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioService {
  // MODIFIED: lazy init so unit tests do not hit the platform channel on construction
  AudioRecorder? _recorder;
  AudioRecorder get _recorderInstance {
    _recorder ??= AudioRecorder();
    return _recorder!;
  }

  final _uuid = const Uuid();

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String?> startRecording() async {
    if (!await requestPermission()) return null;
    if (await _recorderInstance.isRecording()) return null;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.m4a';
    final path = p.join(dir.path, 'memos', fileName);
    await Directory(p.dirname(path)).create(recursive: true);

    await _recorderInstance.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    return path;
  }

  Future<String?> stopRecording() async {
    return await _recorderInstance.stop();
  }

  Future<void> cancel() async {
    await _recorderInstance.cancel();
  }

  Future<bool> isRecording() => _recorderInstance.isRecording();
}
