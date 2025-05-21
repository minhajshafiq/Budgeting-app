import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Singleton pattern
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  // Initialiser le thème depuis les préférences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // En cas d'erreur, utiliser le thème par défaut
      print('Erreur lors de l\'initialisation du thème: $e');
      _themeMode = ThemeMode.light;
    }
  }

  // Changer le thème
  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
    } catch (e) {
      print('Erreur lors de la sauvegarde du thème: $e');
      // Continuer même si la sauvegarde échoue
    }
  }

  // Obtenir le thème actuel
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;
}

// Thème clair
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    background: AppColors.background,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onBackground: AppColors.text,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.text),
    titleLarge: TextStyle(color: AppColors.text),
    titleMedium: TextStyle(color: AppColors.text),
    titleSmall: TextStyle(color: AppColors.text),
    labelMedium: TextStyle(color: AppColors.textSecondary),
  ),
  iconTheme: IconThemeData(
    color: AppColors.text,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.text,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.border,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
);

// Thème sombre
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textDark,
    onBackground: AppColors.textDark,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark),
    bodyMedium: TextStyle(color: AppColors.textDark),
    titleLarge: TextStyle(color: AppColors.textDark),
    titleMedium: TextStyle(color: AppColors.textDark),
    titleSmall: TextStyle(color: AppColors.textDark),
    labelMedium: TextStyle(color: AppColors.textSecondaryDark),
  ),
  iconTheme: IconThemeData(
    color: AppColors.textDark,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textDark,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.borderDark,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
);
