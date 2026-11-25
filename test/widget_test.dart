import 'package:career_application_flutter/app.dart';
import 'package:career_application_flutter/core/constants/app_routes.dart';
import 'package:career_application_flutter/core/theme/theme_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'App launches cleanly with default System theme and switches theme',
    (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      await themeProvider.load();

      expect(themeProvider.themeMode, ThemeMode.system);

      await tester.pumpWidget(CareerGuidanceApp(themeProvider: themeProvider));
      await tester.pumpAndSettle();

      expect(find.text('Career Guidance Community'), findsWidgets);
      expect(find.text('Phase 2 Foundation Ready'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeProvider.themeMode, ThemeMode.dark);
    },
  );

  test('AppRoutes helper formats detail and comparison paths safely', () {
    expect(AppRoutes.collegeDetails('iitb'), '/college/iitb');
    expect(AppRoutes.compareWithIds(const []), '/compare');
    expect(
      AppRoutes.compareWithIds(const ['iitb', 'nid', 'iim-a', 'iitk']),
      '/compare?ids=iitb%2Cnid%2Ciim-a',
    );
  });
}
