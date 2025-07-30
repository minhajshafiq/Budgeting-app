import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../controllers/statistics_controller.dart';

class PeriodSelector extends StatelessWidget {
  final StatisticsController controller;
  final bool isDark;

  const PeriodSelector({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsController>(
      builder: (context, ctrl, child) {
        return GestureDetector(
          onTap: () => _showPeriodSelector(context, ctrl),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Text(
                  ctrl.getPeriodLabel(ctrl.selectedPeriod),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPeriodSelector(BuildContext context, StatisticsController ctrl) {
    final List<Map<String, dynamic>> periods = [
      {'key': 'Weekly', 'label': 'Semaine', 'icon': Icons.calendar_view_week},
      {'key': 'Monthly', 'label': 'Mois', 'icon': Icons.calendar_view_month},
      {'key': 'Yearly', 'label': 'Année', 'icon': Icons.bar_chart},
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: MediaQuery.of(context).size.height * 0.55,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFBFBFB),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 0),
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header avec icône et titre centré
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Période d\'analyse',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Choisissez la période à afficher',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Options de période
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: List.generate(periods.length, (index) {
                  final period = periods[index];
                  final periodKey = period['key']!;
                  final periodLabel = period['label']!;
                  final periodIcon = period['icon'] as IconData;
                  final isSelected = periodKey == ctrl.selectedPeriod;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        splashColor: AppColors.primary.withValues(alpha: 0.08),
                        highlightColor: AppColors.primary.withValues(alpha: 0.04),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ctrl.selectPeriod(periodKey);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : (isDark ? AppColors.borderDark : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary 
                                  : (isDark ? AppColors.borderDark.withValues(alpha: 0.7) : Colors.grey.shade200),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : Colors.grey.shade300),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    periodIcon,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  periodLabel,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary 
                                        : (isDark ? AppColors.textDark.withValues(alpha: 0.87) : Colors.black87),
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: isSelected
                                    ? const Icon(Icons.check_circle, color: AppColors.primary, size: 22, key: ValueKey('selected'))
                                    : const SizedBox(width: 22, key: ValueKey('unselected')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 