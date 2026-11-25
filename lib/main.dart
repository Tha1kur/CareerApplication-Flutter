import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(CareerGuidanceApp(themeProvider: themeProvider));
}
