import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/constants.dart';
import '../core/services/secure_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Service de stockage sécurisé
  final SecureStorageService _secureStorage = SecureStorageService();

  // Singleton pattern
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  // Initialiser le thème depuis les préférences sécurisées
  Future<void> initialize() async {
    try {
      final preferences = await _secureStorage.getThemePreferences();
      final isDark = preferences['isDarkMode'] as bool? ?? false;
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
      await _secureStorage.saveThemePreferences(
        themeMode: _themeMode.name,
        isDarkMode: isDarkMode,
      );
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
  fontFamily: GoogleFonts.inter().fontFamily,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onBackground: AppColors.text,
    error: AppColors.red,
    onError: Colors.white,
  ),
  textTheme: GoogleFonts.interTextTheme().apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  ).copyWith(
    bodyLarge: GoogleFonts.inter(color: AppColors.text),
    bodyMedium: GoogleFonts.inter(color: AppColors.text),
    titleLarge: GoogleFonts.inter(color: AppColors.text),
    titleMedium: GoogleFonts.inter(color: AppColors.text),
    titleSmall: GoogleFonts.inter(color: AppColors.text),
    labelMedium: GoogleFonts.inter(color: AppColors.textSecondary),
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
  fontFamily: GoogleFonts.inter().fontFamily,
  colorScheme: ColorScheme.dark(
    primary: AppColors.secondary,
    secondary: AppColors.secondary,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textDark,
    onBackground: AppColors.textDark,
    error: AppColors.red,
    onError: Colors.white,
  ),
  textTheme: GoogleFonts.interTextTheme().apply(
    bodyColor: AppColors.textDark,
    displayColor: AppColors.textDark,
  ).copyWith(
    bodyLarge: GoogleFonts.inter(color: AppColors.textDark),
    bodyMedium: GoogleFonts.inter(color: AppColors.textDark),
    titleLarge: GoogleFonts.inter(color: AppColors.textDark),
    titleMedium: GoogleFonts.inter(color: AppColors.textDark),
    titleSmall: GoogleFonts.inter(color: AppColors.textDark),
    labelMedium: GoogleFonts.inter(color: AppColors.textSecondaryDark),
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
