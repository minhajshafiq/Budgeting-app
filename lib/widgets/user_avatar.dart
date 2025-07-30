import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final double fontSize;
  final List<Color>? gradientColors;

  const UserAvatar({
    Key? key,
    required this.initials,
    this.size = 44,
    this.fontSize = 16,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dégradé par défaut (bleu/violet comme dans accounts)
    final colors = gradientColors ?? [
      const Color(0xFF5B67FD), // AppColors.primary
      const Color(0xFF6C47FF), // Un violet pour le dégradé
    ];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 