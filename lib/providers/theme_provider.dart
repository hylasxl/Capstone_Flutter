import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get currentTheme => _themeMode;

  void toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      setLightMode();
    } else {
      setDarkMode();
    }
  }

  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _saveTheme("light");
    notifyListeners();
  }

  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _saveTheme("dark");
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeString = prefs.getString('theme');

    if (themeString == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  Future<void> _saveTheme(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }
}
