import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeBoxName = 'theme_preferences';
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      if (!Hive.isBoxOpen(_themeBoxName)) {
        await Hive.openBox(_themeBoxName);
      }
      
      final box = Hive.box(_themeBoxName);
      final savedThemeMode = box.get(_themeModeKey);
      
      if (savedThemeMode != null) {
        _themeMode = ThemeMode.values[savedThemeMode];
      }
      
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing theme provider: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final box = await Hive.openBox(_themeBoxName);
    await box.put(_themeModeKey, mode.index);
    notifyListeners();
  }

  void setLightMode() {
    _themeMode = ThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    _saveThemePreference();
    notifyListeners();
  }

  void setSystemMode() {
    _themeMode = ThemeMode.system;
    _saveThemePreference();
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    try {
      if (!Hive.isBoxOpen(_themeBoxName)) {
        await Hive.openBox(_themeBoxName);
      }
      
      final box = Hive.box(_themeBoxName);
      await box.put(_themeModeKey, _themeMode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
  
  // Get descriptive name of current theme mode
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
      case ThemeMode.system: return 'System';
    }
  }

  // New theme data creators
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E88E5),        // Blue shade
        onPrimary: Colors.white,
        secondary: Color(0xFF26A69A),      // Teal accent
        tertiary: Color(0xFFFFB300),       // Gold accent
        error: Color(0xFFE53935),          // Red for losses
        background: Color(0xFFF5F5F5),     // Light gray background
        onBackground: Color(0xFF212121),
        surface: Colors.white,
        onSurface: Color(0xFF212121),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF212121),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SF Pro Display',
        ),
        labelLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF64B5F6),        // Lighter blue
        onPrimary: Color(0xFF121212),      // Near black
        secondary: Color(0xFF4DD0E1),      // Light teal
        tertiary: Color(0xFFFFD54F),       // Gold accent
        error: Color(0xFFEF5350),          // Red for losses
        background: Color(0xFF121212),     // Deep black background
        onBackground: Color(0xFFEEEEEE),
        surface: Color(0xFF1E1E1E),        // Slightly lighter surface
        onSurface: Color(0xFFEEEEEE),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A2A),
        thickness: 1,
        space: 40,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: const Color(0xFF64B5F6),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF64B5F6),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.75,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          letterSpacing: 0.5,
          color: Color(0xFFEEEEEE),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          letterSpacing: 0.25,
          color: Color(0xFFEEEEEE),
        ),
        labelLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF64B5F6),
        size: 24,
      ),
    );
  }
} 