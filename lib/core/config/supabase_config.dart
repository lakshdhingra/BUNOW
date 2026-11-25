/// Compile-time Supabase configuration loaded via `--dart-define` or `--dart-define-from-file=env.local.json`.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get hasUrl => url.trim().isNotEmpty;

  static bool get hasPublishableKey => publishableKey.trim().isNotEmpty;

  static bool get isConfigured => hasUrl && hasPublishableKey;

  /// Non-sensitive diagnostic summary safe for console logging.
  static String get diagnosticSummary =>
      'SUPABASE_URL configured: $hasUrl, '
      'SUPABASE_PUBLISHABLE_KEY configured: $hasPublishableKey';
}
