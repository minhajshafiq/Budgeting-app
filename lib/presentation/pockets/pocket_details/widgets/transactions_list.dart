import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/card_container.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';
import '../controllers/pocket_detail_controller.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/app_notification.dart';

class TransactionsList extends StatelessWidget {
  final PocketDetailController controller;
  final bool isDark;

  const TransactionsList({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PocketDetailController>(
      builder: (context, controller, child) {
        // Utiliser directement les transactions du pocket local
        final transactions = controller.currentPocket.transactions;
        
        print('📊 TransactionsList: ${transactions.length} transactions dans le pocket ${controller.currentPocket.name}');
        for (final transaction in transactions) {
          print('  - ${transaction.title}: ${transaction.amount}€ (${transaction.date})');
        }
        
        return CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller.getPocketColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedWallet01,
                      color: controller.getPocketColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${transactions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              if (transactions.isEmpty)
                _buildEmptyState(isDark)
              else
                Column(
                  children: transactions
                      .take(5) // Limiter à 5 transactions pour l'affichage
                      .map((transaction) => _buildTransactionItem(transaction, isDark, context))
                      .toList(),
                ),
              
              if (transactions.length > 5) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Et ${transactions.length - 5} autres transactions...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            HugeIcons.strokeRoundedWallet01,
            size: 48,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDark : AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les transactions liées à ce pocket apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic transaction, bool isDark, BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFF48A99).withValues(alpha: 0.8),
              const Color(0xFFF48A99),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
      dismissThresholds: const {
        DismissDirection.endToStart: 0.3,
      },
      movementDuration: const Duration(milliseconds: 200),
      resizeDuration: const Duration(milliseconds: 300),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        
        // Supprimer la transaction du pocket local uniquement
        controller.deleteTransaction(transaction);
        
        // NE PAS supprimer la transaction du TransactionProvider global
        // La transaction reste disponible dans l'application pour d'autres pockets
        print('✅ Transaction supprimée du pocket uniquement: ${transaction.title}');
        
        // Afficher une notification de succès
        AppNotification.success(
          context,
          title: 'Transaction supprimée',
          subtitle: 'La transaction "${transaction.title}" a été retirée du pocket',
        );
        
        return true;
      },
      onDismissed: (direction) {
        HapticFeedback.heavyImpact();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  controller.getPocketColor().withValues(alpha: 0.8),
                  controller.getPocketColor(),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: controller.getPocketColor().withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              controller.getIconForTransaction(transaction),
              color: Colors.white,
              size: 22,
            ),
          ),
          title: Text(
            transaction.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDark : AppColors.text,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              if (transaction.description != null && transaction.description!.isNotEmpty)
                Text(
                  transaction.description!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF48A99).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${transaction.amount.toStringAsFixed(2)}€',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF48A99),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 