import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import '../controllers/statistics_controller.dart';

class ChartTypeSwitcher extends StatelessWidget {
  final StatisticsController controller;
  final bool isDark;

  const ChartTypeSwitcher({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsController>(
      builder: (context, ctrl, child) {
        return GestureDetector(
          onTap: ctrl.toggleChartType,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: !ctrl.isLineChart ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedBarChart,
                    color: !ctrl.isLineChart ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ctrl.isLineChart ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAnalytics02,
                    color: ctrl.isLineChart ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 