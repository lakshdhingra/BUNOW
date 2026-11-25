import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/app.dart';
import 'package:bennett_campus/core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseService.initialize();
  } catch (error) {
    debugPrint('[main] Supabase startup did not complete: $error');
  }

  runApp(const ProviderScope(child: BennettApp()));
}
