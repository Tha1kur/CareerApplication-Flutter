import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class CareerGuidanceApp extends StatefulWidget {
  const CareerGuidanceApp({super.key, this.themeProvider, this.router});

  final ThemeProvider? themeProvider;
  final GoRouter? router;

  @override
  State<CareerGuidanceApp> createState() => _CareerGuidanceAppState();
}

class _CareerGuidanceAppState extends State<CareerGuidanceApp> {
  late final ThemeProvider _themeProvider;
  late final GoRouter _router;
  late final bool _ownsThemeProvider;

  @override
  void initState() {
    super.initState();
    _ownsThemeProvider = widget.themeProvider == null;
    _themeProvider = widget.themeProvider ?? ThemeProvider();
    if (!_themeProvider.isLoaded) {
      unawaited(_themeProvider.load());
    }
    _router = widget.router ?? createAppRouter();
  }

  @override
  void dispose() {
    if (_ownsThemeProvider) {
      _themeProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: _themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Career Guidance Community',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
