import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Roboto'; // Fuente predeterminada

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;

  ThemeProvider() {
    _loadPreferences();
  }

  ThemeData _getLightTheme() {
    return ThemeData.light().copyWith(
      textTheme: GoogleFonts.getTextTheme(_fontFamily),
    );
  }

  ThemeData _getDarkTheme() {
    return ThemeData.dark().copyWith(
      textTheme: GoogleFonts.getTextTheme(_fontFamily),
    );
  }

  ThemeData get theme {
    return _themeMode == ThemeMode.dark ? _getDarkTheme() : _getLightTheme();
  }

  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void changeFont(String font) async {
    _fontFamily = font;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', font);
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    notifyListeners();
  }
}
