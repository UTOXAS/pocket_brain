import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_brain/services/ai_service.dart';
import 'package:pocket_brain/utils/constants.dart';

void main() {
  // Note: Real Gemini calls require a valid API key.
  // These tests cover the public API surface and empty-input guards.
  late AiService aiService;

  setUp(() {
    aiService = AiService();
  });

  group('AiService', () {
    test('summarize returns empty string for empty input', () async {
      final result = await aiService.summarize('');
      expect(result, '');
    });

    test('summarize returns empty string for whitespace-only input', () async {
      final result = await aiService.summarize('   \n\t  ');
      expect(result, '');
    });

    test('extractActionItems returns empty list for empty input', () async {
      final result = await aiService.extractActionItems('');
      expect(result, isEmpty);
    });

    test(
      'extractActionItems returns empty list for whitespace-only input',
      () async {
        final result = await aiService.extractActionItems('  \n  ');
        expect(result, isEmpty);
      },
    );

    // The following tests will only pass with a real/valid GEMINI_API_KEY
    // and network access. They are marked skip by default.
    test(
      'summarize returns non-empty result for valid text',
      () async {
        // Skip unless a real key is provided via --dart-define
        if (AppConstants.geminiApiKey == 'YOUR_FREE_GEMINI_KEY_HERE') {
          return;
        }
        final result = await aiService.summarize(
          'The quick brown fox jumps over the lazy dog. This is a test note.',
        );
        expect(result, isNotEmpty);
      },
      skip: AppConstants.geminiApiKey == 'YOUR_FREE_GEMINI_KEY_HERE',
    );

    test(
      'extractActionItems returns list of items',
      () async {
        if (AppConstants.geminiApiKey == 'YOUR_FREE_GEMINI_KEY_HERE') {
          return;
        }
        final result = await aiService.extractActionItems(
          'I need to buy milk, call mom, and finish the report by Friday.',
        );
        expect(result, isA<List<String>>());
        expect(result.length, greaterThan(0));
      },
      skip: AppConstants.geminiApiKey == 'YOUR_FREE_GEMINI_KEY_HERE',
    );
  });
}
