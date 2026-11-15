import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class AiService {
  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );
  }

  Future<String> summarize(String text) async {
    if (text.trim().isEmpty) return '';
    final prompt =
        'Summarize the following note in 2-3 concise bullet points:\n\n$text';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No summary generated.';
  }

  Future<List<String>> extractActionItems(String text) async {
    if (text.trim().isEmpty) return [];
    final prompt =
        'Extract clear action items from the text below. Return only a plain list, one item per line:\n\n$text';
    final response = await _model.generateContent([Content.text(prompt)]);
    final raw = response.text ?? '';
    return raw
        .split('\n')
        .map((e) => e.replaceAll(RegExp(r'^[-*•\d.]+\s*'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
