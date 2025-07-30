import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../widgets/arrow_painters.dart';
import '../../../widgets/bar_chart.dart';
import '../../../widgets/line_chart.dart';
import '../../../providers/transaction_provider.dart';
import '../controllers/statistics_controller.dart';
import 'period_selector.dart';

class ExpensesCard extends StatelessWidget {
  final StatisticsController controller;
  final bool isDark;

  const ExpensesCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, StatisticsController>(
      builder: (context, transactionProvider, statisticsController, child) {
        // Calculer les vraies dépenses selon la période
        double totalExpenses;
        double totalIncome;
        
        switch (statisticsController.selectedPeriod) {
          case 'Weekly':
            final chartData = statisticsController.getChartData(transactionProvider.transactions);
            totalExpenses = chartData.fold(0.0, (sum, item) => sum + (item['expense'] as double));
            totalIncome = statisticsController.getTotalRevenue(transactionProvider.transactions);
            break;
          case 'Monthly':
            final chartData = statisticsController.getChartData(transactionProvider.transactions);
            totalExpenses = chartData.fold(0.0, (sum, item) => sum + (item['expense'] as double));
            totalIncome = statisticsController.getTotalRevenue(transactionProvider.transactions);
            break;
          case 'Yearly':
            totalExpenses = transactionProvider.totalExpenses;
            totalIncome = transactionProvider.totalIncome;
            break;
          default:
            totalExpenses = transactionProvider.totalExpenses;
            totalIncome = transactionProvider.totalIncome;
        }

        return CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dépensé',
                        style: AppTextStyles.header(context),
                      ),
                      AnimatedCounter(
                        value: totalExpenses,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDark : AppColors.text,
                        ),
                        suffix: ' €',
                        duration: const Duration(milliseconds: 1500),
                        enableBounceEffect: true,
                      ),
                    ],
                  ),
                  PeriodSelector(
                    controller: statisticsController,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  CustomPaint(
                    size: const Size(16, 11),
                    painter: (totalIncome - totalExpenses) >= 0 
                      ? ArrowDownLeftPainter(color: AppColors.green)
                      : ArrowUpPainter(color: AppColors.red),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statisticsController.getComparisonText(totalIncome, totalExpenses),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              statisticsController.isLineChart 
                ? LineChart(
                    animation: statisticsController.animation,
                    data: statisticsController.getChartData(transactionProvider.transactions),
                    showAllLabels: true,
                    selectedDay: statisticsController.selectedDay,
                    onBarTap: (day) {
                      statisticsController.selectDay(day);
                    },
                  )
                : BarChart(
                    animation: statisticsController.animation,
                    data: statisticsController.getChartData(transactionProvider.transactions),
                    showAllLabels: true,
                    selectedDay: statisticsController.selectedDay,
                    onBarTap: (day) {
                      statisticsController.selectDay(day);
                    },
                  ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryItem(
                    'Revenu', 
                    '+${totalIncome.toStringAsFixed(0)} €', 
                    AppColors.green, 
                    isRevenu: true, 
                    isDark: isDark
                  ),
                  _buildSummaryItem(
                    'Dépense', 
                    '-${totalExpenses.toStringAsFixed(0)} €', 
                    AppColors.red, 
                    isRevenu: false, 
                    isDark: isDark
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color color, {required bool isRevenu, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isRevenu 
                  ? (isDark ? AppColors.green.withValues(alpha: 0.2) : const Color(0xFFE6F8EA)) 
                  : (isDark ? AppColors.red.withValues(alpha: 0.2) : const Color(0xFFFDE8E8)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(22, 22),
                painter: isRevenu 
                    ? ArrowDownLeftPainter(color: const Color(0xFF28A745))
                    : ArrowUpRightPainter(color: const Color(0xFFDC3545)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 