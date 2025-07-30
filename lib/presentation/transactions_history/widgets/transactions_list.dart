import 'package:flutter/material.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/constants/constants.dart';
import '../../../widgets/modern_animations.dart';
import '../../../widgets/transaction_list_item.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_history_controller.dart';
import 'empty_state_message.dart';
import 'package:my_flutter_app/data/mappers/transaction_entity_mapper.dart';

class TransactionsList extends StatelessWidget {
  final TransactionHistoryController controller;
  final List<TransactionEntity>? transactions;

  const TransactionsList({
    super.key,
    required this.controller,
    this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final currentTransactions = controller.getSelectedDayTransactions();
        
        if (currentTransactions.isEmpty) {
          return EmptyStateMessage(
            controller: controller,
            isDark: Theme.of(context).brightness == Brightness.dark,
          );
        }

        return CardContainer(
           child: ListView.separated(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             itemCount: currentTransactions.length,
             separatorBuilder: (context, index) => const Divider(
               height: 20,
               thickness: 1,
               color: AppColors.border,
             ),
             itemBuilder: (context, index) {
               final transaction = currentTransactions[index];
               return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                builder: (context, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: TransactionListItem(transaction: TransactionEntityMapper.toData(transaction)),
                  );
                },
              );
             },
           ),
         );
      },
    );
  }
} 