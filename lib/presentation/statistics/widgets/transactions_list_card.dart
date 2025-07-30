import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/card_container.dart';
import '../../../widgets/modern_animations.dart';
import '../../../widgets/transaction_list_item.dart';
import '../../../providers/transaction_provider.dart';
import '../controllers/statistics_controller.dart';

class TransactionsListCard extends StatelessWidget {
  final StatisticsController controller;
  final bool isDark;

  const TransactionsListCard({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, StatisticsController>(
      builder: (context, transactionProvider, statisticsController, child) {
        final transactions = statisticsController.getFilteredTransactions(transactionProvider.transactions);

        if (transactions.isEmpty) {
          return CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildTransactionsHeader(context),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Column(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedInvoice01,
                        size: 48,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statisticsController.selectedDay != null 
                            ? 'Aucune transaction ce jour-là'
                            : 'Aucune transaction récente',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildTransactionsHeader(context),
              ),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 20,
                  thickness: 1,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return RepaintBoundary(
                    child: SlideInAnimation(
                      beginOffset: const Offset(0.3, 0),
                      delay: Duration(milliseconds: 800 + (index * 150)),
                      duration: const Duration(milliseconds: 500),
                      child: TransactionListItem(
                        transaction: transaction,
                        showStatusBubble: false,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    return Consumer<StatisticsController>(
      builder: (context, ctrl, child) {
        return Row(
          children: [
            Expanded(
              child: Text(
                ctrl.getTransactionsTitle(),
                style: AppTextStyles.header(context),
              ),
            ),
            if (ctrl.selectedDay != null)
              GestureDetector(
                onTap: () {
                  ctrl.selectDay(null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tout voir',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.close,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
} 