
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString('app_theme_mode');

    _themeMode = savedTheme == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      'app_theme_mode',
      mode == ThemeMode.light ? 'light' : 'dark',
    );

    _themeMode = mode;
    notifyListeners();
  }
}