import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/app.dart';
import 'package:bennett_campus/core/config/supabase_config.dart';
import 'package:bennett_campus/core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await SupabaseService.initialize();
  }

  runApp(const ProviderScope(child: BennettApp()));
}
