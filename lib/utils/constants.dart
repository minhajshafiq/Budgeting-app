import 'package:flutter/material.dart';

// Couleurs
class AppColors {
  // Couleurs communes
  static const Color primary = Color(0xFF5B67FD);
  static const Color red = Color(0xFFDC3545);
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
}

// Styles de texte adaptés au thème
class AppTextStyles {
  static TextStyle title(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.textDark : AppColors.text,
    );
  }
  
  static TextStyle subtitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: isDark ? AppColors.textDark : AppColors.text,
    );
  }
  
  static TextStyle header(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );
  }
  
  static TextStyle amount(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.textDark : AppColors.text,
    );
  }
  
  static TextStyle amountSmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.textDark : AppColors.text,
    );
  }
  
  static TextStyle barValue(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 10, 
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textDark : AppColors.text,
    );
  }
  
  static TextStyle navLabel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12, 
      color: isDark ? AppColors.textDark : AppColors.text,
    );
  }
  
  // Pour compatibilité avec l'ancien code - à migrer progressivement
  @Deprecated('Utilisez la version qui accepte le BuildContext à la place')
  static const TextStyle title_legacy = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  @Deprecated('Utilisez la version qui accepte le BuildContext à la place')
  static const TextStyle subtitle_legacy = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );
  
  @Deprecated('Utilisez la version qui accepte le BuildContext à la place')
  static const TextStyle header_legacy = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  @Deprecated('Utilisez la version qui accepte le BuildContext à la place')
  static const TextStyle amount_legacy = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  @Deprecated('Utilisez la version qui accepte le BuildContext à la place')
  static const TextStyle amountSmall_legacy = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  @Deprecated('Utilisez la version qui accepte le BuildContext à la place')
  static const TextStyle barValue_legacy = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
  
  @Deprecated('Utilisez la version qui accepte le BuildContext à la place')
  static const TextStyle navLabel_legacy = TextStyle(
    fontSize: 12,
    color: AppColors.text,
  );
}

// Décoration standard
class AppDecorations {
  // Fonction pour obtenir la décoration de carte en fonction du thème
  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.border, 
        width: 1
      ),
      boxShadow: [
        BoxShadow(
          color: isDark 
            ? Colors.black.withOpacity(0.3) 
            : Colors.grey.withAlpha(26),
          spreadRadius: isDark ? 0 : 1,
          blurRadius: isDark ? 8 : 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  // Fonction pour obtenir la décoration de bouton circulaire en fonction du thème
  static BoxDecoration getCircleButtonDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: BoxShape.circle,
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.border, 
        width: 1
      ),
      boxShadow: [
        BoxShadow(
          color: isDark 
            ? Colors.black.withOpacity(0.3) 
            : Colors.grey.withAlpha(26),
          spreadRadius: isDark ? 0 : 1,
          blurRadius: isDark ? 8 : 5,
        ),
      ],
    );
  }
  
  // Versions statiques pour la compatibilité avec le code existant
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
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
    color: AppColors.surface,
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