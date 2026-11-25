import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennett_campus/core/config/supabase_config.dart';

/// Centralized access point for Supabase initialization and client instances.
abstract final class SupabaseService {
  static bool _initialized = false;
  static String? _initializationErrorMessage;

  static bool get isInitialized => _initialized;

  static String? get initializationErrorMessage => _initializationErrorMessage;

  static Future<void> initialize() async {
    if (_initialized) return;

    debugPrint(
      '[SupabaseService] Checking configuration -> '
      '${SupabaseConfig.diagnosticSummary}',
    );

    if (!SupabaseConfig.isConfigured) {
      const message =
          'Supabase configuration is missing. Start the app with '
          '--dart-define-from-file=env.local.json.';
      _initializationErrorMessage =
          '$message (${SupabaseConfig.diagnosticSummary})';
      debugPrint('[SupabaseService] ERROR: $_initializationErrorMessage');
      throw StateError(_initializationErrorMessage!);
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
        debug: kDebugMode,
      );
      _initialized = true;
      _initializationErrorMessage = null;
      debugPrint('[SupabaseService] Supabase.initialize() completed successfully.');
    } catch (error, stackTrace) {
      _initialized = false;
      _initializationErrorMessage = 'Supabase initialization failed: $error';
      debugPrint('[SupabaseService] ERROR: $_initializationErrorMessage');
      debugPrintStack(stackTrace: stackTrace, label: '[SupabaseService]');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => _initialized ? auth.currentUser : null;

  static Session? get currentSession =>
      _initialized ? auth.currentSession : null;
}
