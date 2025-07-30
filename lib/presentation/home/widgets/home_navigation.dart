import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import '../../../widgets/modern_animations.dart';
import '../../transactions_history/screens/transaction_history_screen.dart';
import '../../statistics/screens/statistics_screen.dart';

class HomeNavigation extends StatelessWidget {
  final VoidCallback? onHistoryTap;
  final VoidCallback? onBudgetTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onMoreTap;
  
  const HomeNavigation({
    super.key,
    this.onHistoryTap,
    this.onBudgetTap,
    this.onReportsTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        HomeNavItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedMenu02,
            size: 24,
            color: isDark ? Colors.white : AppColors.text,
          ),
          label: 'Historique',
          index: 0,
          onTap: onHistoryTap ?? () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/transaction-history');
          },
        ),
        HomeNavItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedWallet01,
            size: 24,
            color: isDark ? Colors.white : AppColors.text,
          ),
          label: 'Budget',
          index: 1,
          onTap: onBudgetTap,
        ),
        HomeNavItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedPieChart,
            size: 24,
            color: isDark ? Colors.white : AppColors.text,
          ),
          label: 'Rapports',
          index: 2,
          onTap: onReportsTap ?? () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/statistics');
          },
        ),
        HomeNavItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedMoreHorizontal,
            size: 24,
            color: isDark ? Colors.white : AppColors.text,
          ),
          label: 'Plus',
          index: 3,
          onTap: onMoreTap,
        ),
      ],
    );
  }
}

class HomeNavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final int index;
  final VoidCallback? onTap;

  const HomeNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInAnimation(
      beginOffset: const Offset(0, 0.5),
      delay: Duration(milliseconds: 700 + (index * 100)),
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: AppDecorations.getCircleButtonDecoration(context),
              child: icon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.navLabel(context),
          ),
        ],
      ),
    );
  }
} 