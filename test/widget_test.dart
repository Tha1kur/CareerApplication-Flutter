import 'package:career_application_flutter/app.dart';
import 'package:career_application_flutter/core/constants/app_routes.dart';
import 'package:career_application_flutter/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Home launches cleanly and navigates to Settings for theme toggle',
    (WidgetTester tester) async {
      final deps = AppDependencies.create();
      await tester.runAsync(deps.loadAll);

      expect(deps.themeProvider.themeMode, ThemeMode.system);

      await tester.pumpWidget(CareerGuidanceApp(dependencies: deps));
      await tester.pumpAndSettle();

      expect(find.text('Career Guidance Community'), findsOneWidget);
      expect(find.text('Find your best-fit career'), findsOneWidget);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(deps.themeProvider.themeMode, ThemeMode.dark);

      await tester.tap(find.text('Reset gamification (XP & badges)'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Gamification?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Gamification?'), findsNothing);

      deps.dispose();
    },
  );

  testWidgets('Profile form validates name, saves, and clears', (
    WidgetTester tester,
  ) async {
    final deps = AppDependencies.create();
    await tester.runAsync(deps.loadAll);

    await tester.pumpWidget(
      CareerGuidanceApp(
        dependencies: deps,
        router: createAppRouter(initialLocation: AppRoutes.profile),
      ),
    );
    await tester.pumpAndSettle();

    final saveButton = find.text('Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Aditya');
    await tester.enterText(fields.at(1), '20');
    await tester.enterText(fields.at(2), 'Software Engineer');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(deps.profileProvider.profile.name, 'Aditya');
    expect(deps.profileProvider.profile.age, 20);
    await tester.scrollUntilVisible(
      find.text('Name: Aditya'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Name: Aditya'), findsOneWidget);

    final clearButton = find.text('Clear');
    await tester.ensureVisible(clearButton);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();
    expect(deps.profileProvider.profile.isEmpty, isTrue);

    deps.dispose();
  });

  test('AppRoutes helper formats detail and comparison paths safely', () {
    expect(AppRoutes.collegeDetails('iitb'), '/college/iitb');
    expect(AppRoutes.compareWithIds(const []), '/compare');
    expect(
      AppRoutes.compareWithIds(const ['iitb', 'nid', 'iim-a', 'iitk']),
      '/compare?ids=iitb%2Cnid%2Ciim-a',
    );
  });
}
