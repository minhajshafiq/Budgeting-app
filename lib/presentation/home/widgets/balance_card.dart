import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../widgets/modern_animations.dart';
import '../../../widgets/arrow_painters.dart';
import '../../transactions_history/screens/transaction_history_screen.dart';

class BalanceCard extends StatelessWidget {
  final VoidCallback? onTap;
  
  const BalanceCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return ModernRippleEffect(
          onTap: onTap ?? () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/transaction-history');
          },
          child: CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solde actuel',
                            style: AppTextStyles.header(context),
                          ),
                          const SizedBox(height: 4),
                          AnimatedCounter(
                            value: transactionProvider.balance,
                            style: AppTextStyles.amountSmall(context),
                            suffix: ' €',
                            decimalPlaces: 2,
                            decimalSeparator: ',',
                            thousandSeparator: ' ',
                            enableBounceEffect: true,
                            duration: const Duration(milliseconds: 1500),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Dernière 24h',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                    ? AppColors.textSecondaryDark 
                                    : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildTrendArrow(transactionProvider),
                              const SizedBox(width: 6),
                              AnimatedCounter(
                                value: _getLastDayChangeAmount(transactionProvider),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getLastDayChangeColor(transactionProvider, context),
                                  fontWeight: FontWeight.normal,
                                ),
                                suffix: '€',
                                decimalPlaces: 2,
                                decimalSeparator: ',',
                                duration: const Duration(milliseconds: 1200),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ModernRippleEffect(
                      onTap: onTap ?? () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/transaction-history');
                      },
                      child: Container(
                        decoration: AppDecorations.getCircleButtonDecoration(context),
                        child: IconButton(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onPressed: null, // Géré par ModernRippleEffect
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Méthodes de calcul des changements des dernières 24h
  double _getLastDayChange(TransactionProvider provider) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final today = DateTime.now();
    
    final recentTransactions = provider.transactions.where((transaction) {
      final t = transaction;
      return t.date.isAfter(yesterday) && t.date.isBefore(today.add(const Duration(days: 1)));
    }).toList();
    
    double change = 0.0;
    for (final transaction in recentTransactions) {
      final t = transaction;
      if (t.isIncome) {
        change += t.amount;
      } else {
        change -= t.amount;
      }
    }
    
    return change;
  }

  double _getLastDayChangeAmount(TransactionProvider provider) {
    return _getLastDayChange(provider).abs();
  }

  Color _getLastDayChangeColor(TransactionProvider provider, BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.color!;
  }

  Widget _buildTrendArrow(TransactionProvider provider) {
    final change = _getLastDayChange(provider);
    
    if (change > 0) {
      return CustomPaint(
        size: const Size(16, 11),
        painter: ArrowUpPainter(color: AppColors.green),
      );
    } else if (change < 0) {
      return CustomPaint(
        size: const Size(16, 11),
        painter: ArrowDownPainter(color: AppColors.red),
      );
    } else {
      return Builder(
        builder: (context) => Container(
          width: 16,
          height: 2,
          decoration: BoxDecoration(
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
    }
  }
} 