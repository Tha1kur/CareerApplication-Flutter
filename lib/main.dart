import 'package:material_ui/material_ui.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.create();
  await dependencies.loadAll();

  runApp(CareerGuidanceApp(dependencies: dependencies));
}
