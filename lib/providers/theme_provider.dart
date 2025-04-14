import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeMode _themeMode;
  bool _isDarkMode = false;
  final String _boxName = 'theme_preferences';
  final String _darkModeKey = 'dark_mode';

  ThemeProvider() {
    _themeMode = ThemeMode.system;
    _isDarkMode = false;
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    try {
      final box = await Hive.openBox(_boxName);
      final isDarkMode = box.get(_darkModeKey, defaultValue: false);
      setTheme(isDarkMode);
    } catch (e) {
      debugPrint('Error initializing theme: $e');
      // Default to system theme if there's an error
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

  Future<void> setTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_darkModeKey, isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
    
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setTheme(!_isDarkMode);
  }

  ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 