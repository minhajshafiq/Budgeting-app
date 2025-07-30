import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/card_container.dart';
import '../../../../data/models/pocket.dart';
import '../controllers/pockets_list_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class PocketCard extends StatelessWidget {
  final Pocket pocket;
  final bool isDark;

  const PocketCard({
    super.key,
    required this.pocket,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PocketsListController>(
      builder: (context, controller, child) {
        // Trouver la version la plus récente du pocket
        final currentPocket = controller.pockets.firstWhere(
          (p) => p.id == pocket.id,
          orElse: () => pocket,
        );
        
        final color = controller.getColorFromHex(currentPocket.color);
        final progressColor = currentPocket.isOverBudget ? const Color(0xFFDC2626) : color;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.lightImpact();
                controller.navigateToPocketDetail(currentPocket, context);
              },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar avec gradient
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        controller.getIconFromString(currentPocket.icon),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Informations du pocket
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPocket.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentPocket.transactions.length} transaction${currentPocket.transactions.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark 
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Montant avec style moderne
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${currentPocket.spent.toInt()}€',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: progressColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'sur ${currentPocket.budget.toInt()}€',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark 
                              ? Colors.white.withValues(alpha: 0.5)
                              : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Barre de progression moderne avec animation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark 
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xFF374151),
                          ),
                        ),
                        Text(
                          '${currentPocket.progressPercentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (currentPocket.progressPercentage / 100).clamp(0.0, 1.0),
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
} 