import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: 16), // Commence après l'icône + espace
      child: Container(
        height: 1.0, // Légèrement plus épais pour une meilleure visibilité
        decoration: BoxDecoration(
          color: isDarkMode 
            ? Colors.white.withValues(alpha: 0.15) 
            : Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(0.5), // Arrondi subtil
        ),
      ),
    );
  }
} 