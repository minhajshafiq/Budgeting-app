import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../domain/entities/transaction_period.dart';
import '../controllers/transaction_history_controller.dart';

class DateFilterButtons extends StatelessWidget {
  final TransactionHistoryController controller;

  const DateFilterButtons({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: TransactionPeriod.values.map((period) {
              bool isSelected = period == controller.selectedPeriod;
              Color getButtonColor() {
                if (isSelected) {
                  switch (period) {
                    case TransactionPeriod.past:
                      return const Color(0xFF4A84FF);
                    case TransactionPeriod.future:
                      return const Color(0xFFA7C4FF);
                    default:
                      return AppColors.primary;
                  }
                }
                return Colors.white;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.changePeriod(period),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: getButtonColor(),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? getButtonColor() : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      period.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
} 