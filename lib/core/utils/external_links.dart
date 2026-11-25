import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches an external HTTPS URL safely and provides fallback feedback on error.
Future<void> launchExternalUrl(
  BuildContext context,
  String url, {
  String? label,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final launched = await launchUrl(
    uri,
    mode: LaunchMode.platformDefault,
    webOnlyWindowName: '_blank',
  );

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          label != null ? 'Unable to open $label.' : 'Unable to open link.',
        ),
      ),
    );
  }
}
