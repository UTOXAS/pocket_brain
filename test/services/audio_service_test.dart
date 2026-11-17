import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/services/audio_service.dart';

void main() {
  // ADDED: required for any platform-channel usage
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioService audioService;

  setUp(() {
    audioService = AudioService();
  });

  group('AudioService', () {
    // MODIFIED: construction must not throw (lazy recorder)
    test('can be constructed without throwing', () {
      expect(() => AudioService(), returnsNormally);
    });

    // Platform methods require a real device / emulator – skip in pure unit tests
    test(
      'isRecording returns false initially',
      () async {
        final recording = await audioService.isRecording();
        expect(recording, isFalse);
      },
      skip: 'Requires record plugin platform implementation',
    );

    test(
      'cancel does not throw when not recording',
      () async {
        expect(() => audioService.cancel(), returnsNormally);
      },
      skip: 'Requires record plugin platform implementation',
    );

    test(
      'stopRecording returns null when not recording',
      () async {
        final path = await audioService.stopRecording();
        expect(path, isNull);
      },
      skip: 'Requires record plugin platform implementation',
    );
  });
}
