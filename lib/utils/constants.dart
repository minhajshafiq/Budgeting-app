import 'package:flutter/material.dart';

// Couleurs
class AppColors {
  static const Color background = Color(0xFFF8F9FA);
  static const Color primary = Color(0xFF5B67FD);
  static const Color border = Color(0xFFD1D5DB);
  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color red = Color(0xFFDC3545);
  static const Color green = Color(0xFF28A745);
  
  // Couleurs des barres du graphique
  static const Color barMon = Color(0xFFD6E4FF);
  static const Color barTue = Color(0xFFA7C4FF);
  static const Color barWed = Color(0xFF78A4FF);
  static const Color barThu = Color(0xFF4A84FF);
  static const Color barFri = Color(0xFF2E69F0);
  static const Color barSat = Color(0xFF1F4ED8);
  static const Color barSun = Color(0xFF162DAA);
}

// Styles de texte
class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );
  
  static const TextStyle header = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle amount = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle amountSmall = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle barValue = TextStyle(
    fontSize: 10, 
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
  
  static const TextStyle navLabel = TextStyle(
    fontSize: 12, 
    color: AppColors.text,
  );
}

// Décoration standard
class AppDecorations {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha(26),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration circleButtonDecoration = BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha(26),
        spreadRadius: 1,
        blurRadius: 5,
      ),
    ],
  );
}

// Durée des animations
class AppAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 1500);
}

// Padding standard
class AppPadding {
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets screen = EdgeInsets.all(16);
}

// Données des barres du graphique
List<Map<String, dynamic>> getWeeklyData() {
  return [
    {'day': 'Mon', 'amount': 60, 'value': '100.33€', 'color': AppColors.barMon},
    {'day': 'Tue', 'amount': 80, 'value': '100.33€', 'color': AppColors.barTue},
    {'day': 'Wed', 'amount': 50, 'value': '100.33€', 'color': AppColors.barWed},
    {'day': 'Thu', 'amount': 100, 'value': '100.33€', 'color': AppColors.barThu},
    {'day': 'Fri', 'amount': 40, 'value': '100.33€', 'color': AppColors.barFri},
    {'day': 'Sat', 'amount': 80, 'value': '100.33€', 'color': AppColors.barSat},
    {'day': 'Sun', 'amount': 110, 'value': '100.33€', 'color': AppColors.barSun},
  ];
} 