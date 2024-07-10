import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  final Box _themeBox = Hive.box('themebox');

  ThemeMode get theme {
    final themeString = _themeBox.get('theme', defaultValue: 'system');
    return _themeModeFromString(themeString);
  }

  void changeThemeMode(String themeMode) {
    _themeBox.put('theme', themeMode);
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

 
}
