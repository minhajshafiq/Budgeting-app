import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/card_container.dart';
import '../../../../providers/transaction_provider.dart';
import '../controllers/pocket_detail_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class StatsCard extends StatelessWidget {
  final bool isDark;

  const StatsCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PocketDetailController>(
      builder: (context, controller, child) {
        final currentPocket = controller.currentPocket;
        
        // Calculer les statistiques basées sur les transactions réelles
        final int transactionCount = currentPocket.transactions.length;
        
        // Calculer la moyenne par transaction (éviter la division par zéro)
        final double averagePerTransaction = transactionCount > 0 
            ? currentPocket.spent / transactionCount 
            : 0.0;
        
        // Calculer les dépenses de cette semaine
        final DateTime now = DateTime.now();
        final DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
        final double thisWeekSpending = currentPocket.transactions
            .where((t) => t.date.isAfter(startOfWeek))
            .fold(0.0, (sum, t) => sum + t.amount);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                controller.getPocketColor().withValues(alpha: 0.1),
                controller.getPocketColor().withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedChartHistogram,
                      color: controller.getPocketColor(),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: controller.getPocketColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildModernStatItem(
                      'Transactions', 
                      transactionCount.toString(), 
                      HugeIcons.strokeRoundedInvoice01, 
                      const Color(0xFF6BC6EA), 
                      isDark,
                      0,
                    ),
                    _buildModernStatItem(
                      'Moyenne/Trans.', 
                      '${averagePerTransaction.toStringAsFixed(0)}€', 
                      HugeIcons.strokeRoundedCalculator, 
                      const Color(0xFFFFB67A), 
                      isDark,
                      1,
                    ),
                    _buildModernStatItem(
                      'Cette semaine', 
                      '${thisWeekSpending.toStringAsFixed(0)}€', 
                      HugeIcons.strokeRoundedCalendar01, 
                      const Color(0xFF78D078), 
                      isDark,
                      2,
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

  Widget _buildModernStatItem(String label, String value, IconData icon, Color color, bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDark : AppColors.text,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
} 