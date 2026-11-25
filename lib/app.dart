import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/core/constants/app_constants.dart';
import 'package:bennett_campus/core/router/app_router.dart';
import 'package:bennett_campus/core/theme/app_theme.dart';

/// Root widget configuring theming, Riverpod state scope, and GoRouter.
class BennettApp extends ConsumerWidget {
  const BennettApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
