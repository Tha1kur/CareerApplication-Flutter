import 'package:material_ui/material_ui.dart';

import '../../services/local_storage_service.dart';

/// Manages Light / Dark / System theme mode with local persistence via [LocalStorageService].
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  ThemeMode _themeMode = ThemeMode.system;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _loaded;

  String get themeModeKey => switch (_themeMode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  Future<void> load() async {
    final stored = await _storage.loadThemeMode();
    _themeMode = _parseMode(stored);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.saveThemeMode(themeModeKey);
  }

  static ThemeMode _parseMode(String value) {
    return switch (value.toLowerCase()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
