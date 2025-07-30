import 'package:flutter/material.dart';
import '../../../core/widgets/card_container.dart';
import '../../../widgets/modern_animations.dart';
import '../controllers/transaction_history_controller.dart';

class EmptyStateMessage extends StatelessWidget {
  final TransactionHistoryController controller;
  final bool isDark;

  const EmptyStateMessage({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return SlideInAnimation(
          beginOffset: const Offset(0, 0.3),
          delay: const Duration(milliseconds: 700),
          duration: const Duration(milliseconds: 600),
          child: CardContainer(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  PulseAnimation(
                    duration: const Duration(milliseconds: 2000),
                    minScale: 0.95,
                    maxScale: 1.05,
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.getEmptyStateMessage(),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 