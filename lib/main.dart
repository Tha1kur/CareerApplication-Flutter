import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/constants/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CareerGuidanceApp(initialLocation: AppRoutes.splash));
}
