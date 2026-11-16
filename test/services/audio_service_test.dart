import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/services/audio_service.dart';

void main() {
  late AudioService audioService;

  setUp(() {
    audioService = AudioService();
  });

  group('AudioService', () {
    test('isRecording returns false initially', () async {
      final recording = await audioService.isRecording();
      expect(recording, isFalse);
    });

    // Permission and actual recording require device/emulator + microphone.
    // These tests verify the public API does not throw on construction
    // and that cancel/stop are safe when not recording.
    test('cancel does not throw when not recording', () async {
      expect(() => audioService.cancel(), returnsNormally);
    });

    test('stopRecording returns null when not recording', () async {
      final path = await audioService.stopRecording();
      expect(path, isNull);
    });
  });
}
