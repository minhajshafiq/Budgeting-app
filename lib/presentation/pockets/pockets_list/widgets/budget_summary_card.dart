import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/card_container.dart';
import '../../../../providers/transaction_provider.dart';
import '../controllers/pockets_list_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class BudgetSummaryCard extends StatelessWidget {
  final bool isDark;

  const BudgetSummaryCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, PocketsListController>(
      builder: (context, transactionProvider, pocketsController, child) {
        final totalIncome = pocketsController.getTotalIncome(transactionProvider);
        final availableBudget = pocketsController.getAvailableBudget(transactionProvider);
        final currentBalance = pocketsController.getCurrentBalance(transactionProvider);
        
        // Règle stricte 50/30/20 avec tolérance ±2%
        final needsPercentage = pocketsController.getNeedsPercentage(totalIncome);
        final wantsPercentage = pocketsController.getWantsPercentage(totalIncome);
        final savingsPercentage = pocketsController.getSavingsPercentage(totalIncome);
        
        bool isBalanced =
            (needsPercentage - 50).abs() <= 2 &&
            (wantsPercentage - 30).abs() <= 2 &&
            (savingsPercentage - 20).abs() <= 2;

        String message;
        Color statusColor;
        IconData statusIcon;
        if (isBalanced) {
          message = 'Budget équilibré (règle 50/30/20 respectée)';
          statusColor = AppColors.green;
          statusIcon = HugeIcons.strokeRoundedCheckmarkCircle02;
        } else {
          message = 'Budget à rééquilibrer : la règle 50/30/20 n\'est pas respectée';
          statusColor = AppColors.orange;
          statusIcon = HugeIcons.strokeRoundedAlert02;
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header avec montant total et budget disponible
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark 
                                ? Colors.white.withValues(alpha: 0.7)
                                : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${totalIncome.toStringAsFixed(0)}€',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                HugeIcons.strokeRoundedWallet01,
                                size: 16,
                                color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Disponible: ${availableBudget.toStringAsFixed(0)}€',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: availableBudget >= 0 
                                    ? AppColors.green 
                                    : AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
              
                  // Barres de progression modernes
                  Column(
                    children: [
                      _buildModernProgressBar(
                        'Besoins', 
                        needsPercentage, 
                        const Color(0xFFF48A99), 
                        '${pocketsController.totalNeeds.toStringAsFixed(0)}€',
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildModernProgressBar(
                        'Envies', 
                        wantsPercentage, 
                        const Color(0xFF78D078), 
                        '${pocketsController.totalWants.toStringAsFixed(0)}€',
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildModernProgressBar(
                        'Épargne', 
                        savingsPercentage, 
                        const Color(0xFF6BC6EA), 
                        '${pocketsController.totalSavings.toStringAsFixed(0)}€',
                        isDark,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Analyse de la règle 50/30/20
                  _build503020Analysis(isDark, needsPercentage, wantsPercentage, savingsPercentage),
                  
                  const SizedBox(height: 16),
                  
                  // Status message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernProgressBar(String label, double percentage, Color color, String amount, bool isDark) {
    // Définir les seuils recommandés pour la règle 50/30/20
    double recommendedPercentage;
    switch (label) {
      case 'Besoins':
        recommendedPercentage = 50.0;
        break;
      case 'Envies':
        recommendedPercentage = 30.0;
        break;
      case 'Épargne':
        recommendedPercentage = 20.0;
        break;
      default:
        recommendedPercentage = 100.0;
    }
    
    final isOverLimit = percentage > recommendedPercentage;
    final progressColor = isOverLimit ? const Color(0xFFDC2626) : color;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF374151),
                  ),
                ),
                if (isOverLimit) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedAlert02,
                          size: 12,
                          color: const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dépassé',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
                Text(
                  ' / ${recommendedPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark 
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark 
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final progressWidth = constraints.maxWidth * (percentage / 100).clamp(0.0, 1.0);
            final recommendedWidth = constraints.maxWidth * (recommendedPercentage / 100);
            
            return Stack(
              children: [
                // Barre de fond
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark 
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Ligne de limite recommandée
                if (recommendedWidth <= constraints.maxWidth)
                  Positioned(
                    left: recommendedWidth,
                    child: Container(
                      width: 2,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFF6B7280),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                // Barre de progression
                Container(
                  height: 8,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _build503020Analysis(bool isDark, double needsPercentage, double wantsPercentage, double savingsPercentage) {
    // Vérifier les dépassements pour chaque catégorie
    final needsOverLimit = needsPercentage > 50;
    final wantsOverLimit = wantsPercentage > 30;
    final savingsUnderLimit = savingsPercentage < 20;
    
    // Calculer le nombre de violations
    final violations = [
      if (needsOverLimit) 'Besoins dépassent 50%',
      if (wantsOverLimit) 'Envies dépassent 30%',
      if (savingsUnderLimit) 'Épargne sous 20%',
    ];
    
    final hasViolations = violations.isNotEmpty;
    final analysisColor = hasViolations ? const Color(0xFFDC2626) : const Color(0xFF78D078);
    final analysisIcon = hasViolations ? HugeIcons.strokeRoundedAlert02 : HugeIcons.strokeRoundedCheckmarkCircle02;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: analysisColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: analysisColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et indicateur
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: analysisColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  analysisIcon,
                  color: analysisColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Règle 50/30/20',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      hasViolations 
                        ? '${violations.length} point${violations.length > 1 ? 's' : ''} à améliorer'
                        : 'Budget équilibré !',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: analysisColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (hasViolations) ...[
            const SizedBox(height: 12),
            // Liste des recommandations
            ...violations.map((violation) {
              IconData recommendationIcon;
              String recommendation;
              
              if (violation.contains('Besoins')) {
                recommendationIcon = HugeIcons.strokeRoundedArrowDown01;
                recommendation = 'Réduisez vos dépenses essentielles de ${(needsPercentage - 50).toStringAsFixed(0)}%';
              } else if (violation.contains('Envies')) {
                recommendationIcon = HugeIcons.strokeRoundedArrowDown01;
                recommendation = 'Limitez vos loisirs de ${(wantsPercentage - 30).toStringAsFixed(0)}%';
              } else {
                recommendationIcon = HugeIcons.strokeRoundedArrowUp01;
                recommendation = 'Augmentez votre épargne de ${(20 - savingsPercentage).toStringAsFixed(0)}%';
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      recommendationIcon,
                      size: 14,
                      color: analysisColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark 
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Félicitations ! Votre budget respecte parfaitement la règle 50/30/20 pour une gestion financière équilibrée.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark 
                  ? Colors.white.withValues(alpha: 0.8)
                  : const Color(0xFF374151),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 