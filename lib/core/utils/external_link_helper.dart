import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Safely normalizes and launches external URLs with graceful offline/failure feedback.
Future<void> launchExternalUrlSafely(
  BuildContext context,
  String rawUrl,
) async {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) {
    _showSnack(context, 'No link available');
    return;
  }

  final normalized =
      trimmed.startsWith('http://') || trimmed.startsWith('https://')
      ? trimmed
      : 'https://$trimmed';

  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.hasScheme) {
    _showSnack(context, 'Invalid link');
    return;
  }

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showSnack(context, 'Unable to open link');
    }
  } catch (_) {
    if (context.mounted) {
      _showSnack(context, 'Unable to open link');
    }
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
