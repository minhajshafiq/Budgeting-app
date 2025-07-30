import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/card_container.dart';
import '../../../widgets/modern_animations.dart';
import '../../../widgets/transaction_list_item.dart';

class RecentTransactions extends StatelessWidget {
  final int maxTransactions;
  
  const RecentTransactions({
    super.key,
    this.maxTransactions = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final recentTransactions = transactionProvider.recentTransactions.take(maxTransactions).toList();
        
        if (recentTransactions.isEmpty) {
          return CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions récentes',
                  style: AppTextStyles.header(context),
                ),
                const SizedBox(height: 16),
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
                        'Aucune transaction récente',
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
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Transactions récentes',
                  style: AppTextStyles.header(context),
                ),
              ),
              
              // Liste des transactions réelles
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 20,
                  thickness: 1,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return RepaintBoundary(
                    child: SlideInAnimation(
                      beginOffset: const Offset(0.3, 0),
                      delay: Duration(milliseconds: 1000 + (index * 150)),
                      duration: const Duration(milliseconds: 500),
                      child: TransactionListItem(
                        transaction: transaction,
                        showStatusBubble: false, // Pas de bulles sur la page d'accueil
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
} 