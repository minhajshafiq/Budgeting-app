import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../controllers/statistics_controller.dart';

class PeriodNavigation extends StatelessWidget {
  final StatisticsController controller;
  final bool isDark;

  const PeriodNavigation({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsController>(
      builder: (context, ctrl, child) {
        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              // Bouton précédent
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ctrl.navigateToPrevious();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: isDark ? AppColors.textDark : AppColors.text,
                    size: 24,
                  ),
                ),
              ),
              
              // Texte de la période actuelle
              Expanded(
                child: Center(
                  child: Text(
                    ctrl.getCurrentPeriodText(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                ),
              ),
              
              // Bouton suivant
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ctrl.navigateToNext();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: isDark ? AppColors.textDark : AppColors.text,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 