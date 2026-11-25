import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennett_campus/core/config/supabase_config.dart';

/// Centralized access point for Supabase initialization and client instances.
abstract final class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase configuration is missing. Run with '
        '--dart-define-from-file=env.local.json.',
      );
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
      debug: kDebugMode,
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => _initialized ? auth.currentUser : null;

  static Session? get currentSession =>
      _initialized ? auth.currentSession : null;
}
