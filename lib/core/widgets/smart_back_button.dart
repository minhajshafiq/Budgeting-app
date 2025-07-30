import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../utils/navigation_service.dart';
import 'package:hugeicons/hugeicons.dart';

class SmartBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double iconSize;
  final bool showBackground;

  const SmartBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.iconSize = 20,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onPressed != null) {
          onPressed!();
        } else {
          _handleSmartNavigation(context);
        }
      },
      child: Container(
        decoration: showBackground 
          ? BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
        child: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: iconSize,
            color: iconColor ?? Theme.of(context).iconTheme.color ?? AppColors.text,
          ),
          onPressed: null, // Géré par GestureDetector
        ),
      ),
    );
  }

  void _handleSmartNavigation(BuildContext context) async {
    final popped = await Navigator.of(context).maybePop();
    if (!popped) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }
} 