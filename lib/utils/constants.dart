class AppConstants {
  static const String appName = 'PocketBrain';
  static const String geminiModel = 'gemini-1.5-flash';
  // Put your free Gemini API key here (or better: use --dart-define later)
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_FREE_GEMINI_KEY_HERE',
  );
  static const Duration syncDebounce = Duration(seconds: 3);
}
