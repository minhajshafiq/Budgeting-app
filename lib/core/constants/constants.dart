import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Couleurs
class AppColors {
  // Couleurs communes
  static const Color primary = Color(0xFF5B67FD);
  static const Color secondary = Color(0xFF5B67FD);
  static const Color red = Color(0xFFDC3545);
  static const Color orange = Color(0xFFFF8C00);
  static const Color green = Color(0xFF28A745);
  
  // Couleurs mode clair
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD1D5DB);
  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B7280);
  
  // Couleurs mode sombre
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color borderDark = Color(0xFF2C2C2C);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  
  // Couleurs des barres du graphique
  static const Color barMon = Color(0xFFD6E4FF);
  static const Color barTue = Color(0xFFA7C4FF);
  static const Color barWed = Color(0xFF78A4FF);
  static const Color barThu = Color(0xFF4A84FF);
  static const Color barFri = Color(0xFF2E69F0);
  static const Color barSat = Color(0xFF1F4ED8);
  static const Color barSun = Color(0xFF162DAA);
  
  // Méthodes helper pour éviter la répétition
  static Color getTextColor(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? textDark : text;
  
  static Color getSecondaryTextColor(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondary;
    
  static Color getSurfaceColor(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? surfaceDark : surface;
    
  static Color getBorderColor(BuildContext context) => 
    Theme.of(context).brightness == Brightness.dark ? borderDark : border;
}

// Styles de texte optimisés
class AppTextStyles {
  // Cache pour éviter la recréation des styles
  static final Map<String, TextStyle> _cache = {};
  
  // Méthode helper pour créer un style avec cache
  static TextStyle _createStyle(BuildContext context, String key, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    bool useSecondaryColor = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cacheKey = '${key}_${isDark ? 'dark' : 'light'}';
    
    return _cache[cacheKey] ??= GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: useSecondaryColor 
        ? AppColors.getSecondaryTextColor(context)
        : AppColors.getTextColor(context),
    );
  }
  
  static TextStyle title(BuildContext context) => _createStyle(
    context, 'title', fontSize: 22, fontWeight: FontWeight.bold);
  
  static TextStyle subtitle(BuildContext context) => _createStyle(
    context, 'subtitle', fontSize: 18);
  
  static TextStyle header(BuildContext context) => _createStyle(
    context, 'header', fontSize: 14, useSecondaryColor: true);
  
  static TextStyle amount(BuildContext context) => _createStyle(
    context, 'amount', fontSize: 28, fontWeight: FontWeight.bold);
  
  static TextStyle amountSmall(BuildContext context) => _createStyle(
    context, 'amountSmall', fontSize: 22, fontWeight: FontWeight.bold);
  
  static TextStyle barValue(BuildContext context) => _createStyle(
    context, 'barValue', fontSize: 10, fontWeight: FontWeight.w600);
  
  static TextStyle navLabel(BuildContext context) => _createStyle(
    context, 'navLabel', fontSize: 13);
  
  // Méthode pour nettoyer le cache si nécessaire
  static void clearCache() => _cache.clear();
}

// Décorations optimisées
class AppDecorations {
  // Cache pour les décorations
  static final Map<String, BoxDecoration> _cache = {};
  
  // Méthode helper pour créer une BoxShadow selon le thème
  static List<BoxShadow> _createShadow(bool isDark) => [
    BoxShadow(
      color: isDark 
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.grey.withAlpha(26),
      spreadRadius: isDark ? 0 : 1,
      blurRadius: isDark ? 8 : 5,
      offset: const Offset(0, 2),
    ),
  ];
  
  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cacheKey = 'card_${isDark ? 'dark' : 'light'}';
    
    return _cache[cacheKey] ??= BoxDecoration(
      color: AppColors.getSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.getBorderColor(context), 
        width: 1
      ),
      boxShadow: _createShadow(isDark),
    );
  }
  
  static BoxDecoration getCircleButtonDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cacheKey = 'circle_${isDark ? 'dark' : 'light'}';
    
    return _cache[cacheKey] ??= BoxDecoration(
      color: AppColors.getSurfaceColor(context),
      shape: BoxShape.circle,
      border: Border.all(
        color: AppColors.getBorderColor(context), 
        width: 1
      ),
      boxShadow: _createShadow(isDark),
    );
  }
  
  // Méthode pour nettoyer le cache si nécessaire
  static void clearCache() => _cache.clear();
}

// Configuration API
class ApiConfig {
  static const String logoDevApiKey = 'pk_YdY0rOHiR8S_ImFZMMT5yw';
  static const String logoDevBaseUrl = 'https://img.logo.dev';
}

// Durées des animations
class AppAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 600);
  static const Duration shortDuration = Duration(milliseconds: 150);
}

// Padding standard
class AppPadding {
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets screen = EdgeInsets.all(16);
}

// Données de test organisées
class TestData {
  // Données des revenus par période (vides)
  static const Map<String, double> weeklyRevenue = {
    'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0, 
    'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
  };
  
  static const Map<String, double> monthlyRevenue = {
    'Jan': 0.0, 'Fév': 0.0, 'Mar': 0.0, 'Avr': 0.0,
    'Mai': 0.0, 'Juin': 0.0, 'Juil': 0.0, 'Août': 0.0,
    'Sep': 0.0, 'Oct': 0.0, 'Nov': 0.0, 'Déc': 0.0,
  };
  
  static const Map<String, double> yearlyRevenue = {
    '2020': 0.0, '2021': 0.0, '2022': 0.0,
    '2023': 0.0, '2024': 0.0, '2025': 0.0,
  };
  
  // Données des dépenses par période (vides)
  static const List<Map<String, dynamic>> weeklyExpenses = [
    {'period': 'Mon', 'expenses': 0.0, 'color': AppColors.barMon},
    {'period': 'Tue', 'expenses': 0.0, 'color': AppColors.barTue},
    {'period': 'Wed', 'expenses': 0.0, 'color': AppColors.barWed},
    {'period': 'Thu', 'expenses': 0.0, 'color': AppColors.barThu},
    {'period': 'Fri', 'expenses': 0.0, 'color': AppColors.barFri},
    {'period': 'Sat', 'expenses': 0.0, 'color': AppColors.barSat},
    {'period': 'Sun', 'expenses': 0.0, 'color': AppColors.barSun},
  ];
  
  static const List<Map<String, dynamic>> monthlyExpenses = [
    {'period': 'Jan', 'expenses': 0.0, 'color': AppColors.barMon},
    {'period': 'Fév', 'expenses': 0.0, 'color': AppColors.barTue},
    {'period': 'Mar', 'expenses': 0.0, 'color': AppColors.barWed},
    {'period': 'Avr', 'expenses': 0.0, 'color': AppColors.barThu},
    {'period': 'Mai', 'expenses': 0.0, 'color': AppColors.barFri},
    {'period': 'Juin', 'expenses': 0.0, 'color': AppColors.barSat},
    {'period': 'Juil', 'expenses': 0.0, 'color': AppColors.barSun},
    {'period': 'Août', 'expenses': 0.0, 'color': AppColors.barMon},
    {'period': 'Sep', 'expenses': 0.0, 'color': AppColors.barTue},
    {'period': 'Oct', 'expenses': 0.0, 'color': AppColors.barWed},
    {'period': 'Nov', 'expenses': 0.0, 'color': AppColors.barThu},
    {'period': 'Déc', 'expenses': 0.0, 'color': AppColors.barFri},
  ];
  
  static const List<Map<String, dynamic>> yearlyExpenses = [
    {'period': '2020', 'expenses': 0.0, 'color': AppColors.barMon},
    {'period': '2021', 'expenses': 0.0, 'color': AppColors.barTue},
    {'period': '2022', 'expenses': 0.0, 'color': AppColors.barWed},
    {'period': '2023', 'expenses': 0.0, 'color': AppColors.barThu},
    {'period': '2024', 'expenses': 0.0, 'color': AppColors.barFri},
    {'period': '2025', 'expenses': 0.0, 'color': AppColors.barSat},
  ];
}

// Fonctions utilitaires pour les données
Map<String, double> getWeeklyRevenue() => TestData.weeklyRevenue;
Map<String, double> getMonthlyRevenue() => TestData.monthlyRevenue;
Map<String, double> getYearlyRevenue() => TestData.yearlyRevenue;

List<Map<String, dynamic>> getWeeklyData() => _normalizeData(TestData.weeklyExpenses);
List<Map<String, dynamic>> getMonthlyData() => _normalizeData(TestData.monthlyExpenses);
List<Map<String, dynamic>> getYearlyData() => _normalizeData(TestData.yearlyExpenses);

// Fonction pour générer des données hebdomadaires à partir des vraies transactions
List<Map<String, dynamic>> getWeeklyDataFromTransactions(List<dynamic> transactions) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  
  final Map<String, double> dailyExpenses = Map.from(TestData.weeklyRevenue);
  dailyExpenses.updateAll((key, value) => 0.0);
  
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  for (final transaction in transactions) {
    if (transaction.isExpense) {
      final transactionDate = transaction.date;
      final dayOfWeek = transactionDate.weekday - 1;
      
      if (transactionDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
        final dayName = dayNames[dayOfWeek];
        dailyExpenses[dayName] = dailyExpenses[dayName]! + transaction.amount;
      }
    }
  }
  
  final rawData = [
    {'period': 'Mon', 'expenses': dailyExpenses['Mon']!, 'color': AppColors.barMon},
    {'period': 'Tue', 'expenses': dailyExpenses['Tue']!, 'color': AppColors.barTue},
    {'period': 'Wed', 'expenses': dailyExpenses['Wed']!, 'color': AppColors.barWed},
    {'period': 'Thu', 'expenses': dailyExpenses['Thu']!, 'color': AppColors.barThu},
    {'period': 'Fri', 'expenses': dailyExpenses['Fri']!, 'color': AppColors.barFri},
    {'period': 'Sat', 'expenses': dailyExpenses['Sat']!, 'color': AppColors.barSat},
    {'period': 'Sun', 'expenses': dailyExpenses['Sun']!, 'color': AppColors.barSun},
  ];
  
  return _normalizeData(rawData);
}

// Fonction utilitaire optimisée pour normaliser les données
List<Map<String, dynamic>> _normalizeData(List<Map<String, dynamic>> rawData) {
  final maxExpense = rawData.fold<double>(0.0, (max, item) {
    final expense = item['expenses'] as double;
    return expense > max ? expense : max;
  });
  
  const maxBarHeight = 100.0;
  
  return rawData.map((item) {
    final expense = item['expenses'] as double;
    final normalizedHeight = maxExpense > 0 
        ? ((expense / maxExpense) * maxBarHeight).clamp(0.0, maxBarHeight)
        : 0.0;
    
    return {
      'day': item['period'],
      'period': item['period'],
      'amount': normalizedHeight,
      'expense': expense,
      'value': '${expense.toStringAsFixed(expense >= 1000 ? 0 : 2)}€',
      'color': item['color'],
    };
  }).toList();
}
