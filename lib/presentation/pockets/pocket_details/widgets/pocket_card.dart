import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/card_container.dart';
import '../controllers/pocket_detail_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class PocketCard extends StatelessWidget {
  final bool isDark;

  const PocketCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PocketDetailController>(
      builder: (context, controller, child) {
        final currentPocket = controller.currentPocket;
        print('PocketCard rebuild - isEditing: ${controller.isEditing}');
        
        return CardContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: controller.getPocketColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(controller.getPocketIcon(), color: controller.getPocketColor(), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: controller.isEditing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: controller.nameController,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textDark : AppColors.text,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  hintText: 'Nom du pocket',
                                  hintStyle: TextStyle(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              // Suggestions automatiques
                              if (controller.filteredSuggestions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.border,
                                    ),
                                  ),
                                  child: Wrap(
                                    spacing: 8,
                                    children: controller.filteredSuggestions.map((suggestion) => 
                                      GestureDetector(
                                        onTap: () => controller.selectSuggestion(suggestion),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6BC6EA).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            suggestion,
                                            style: TextStyle(
                                              color: const Color(0xFF6BC6EA),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ],
                          )
                        : Text(
                            currentPocket.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textDark : AppColors.text,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBudgetItem(
                    'Budget',
                    controller.isEditing
                        ? SizedBox(
                            width: 80,
                            child: TextField(
                              controller: controller.budgetController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6BC6EA)),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                suffix: const Text('€'),
                                hintText: '0',
                              ),
                              onChanged: (value) {
                                // Validation en temps réel
                                final amount = double.tryParse(value);
                                if (amount != null && amount < 0) {
                                  HapticFeedback.heavyImpact();
                                }
                              },
                            ),
                          )
                        : Text(
                            '${currentPocket.budget.toInt()}€',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6BC6EA)),
                          ),
                    isDark,
                  ),
                  _buildBudgetItem(
                    'Dépensé',
                    Text(
                      '${currentPocket.spent.toInt()}€',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentPocket.isOverBudget ? const Color(0xFFDC2626) : const Color(0xFF78D078),
                      ),
                    ),
                    isDark,
                  ),
                  _buildBudgetItem(
                    'Restant',
                    Text(
                      '${currentPocket.remainingBudget.toInt()}€',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentPocket.remainingBudget < 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      ),
                    ),
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Barre de progression
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
                          color: isDark ? AppColors.textDark : AppColors.text,
                        ),
                      ),
                      Text(
                        '${currentPocket.progressPercentage.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: currentPocket.isOverBudget ? const Color(0xFFDC2626) : controller.getPocketColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final progressValue = currentPocket.progressPercentage / 100;
                      print('📊 Barre de progression: ${currentPocket.progressPercentage}% (${progressValue.toStringAsFixed(3)})');
                      
                      return Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0.0,
                              end: progressValue.clamp(0.0, 1.0),
                            ),
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  currentPocket.isOverBudget ? const Color(0xFFDC2626) : controller.getPocketColor(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetItem(String label, Widget value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        value,
      ],
    );
  }
} 