import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import 'package:flutter/material.dart';

IconData getNotificationIcon(String iconName) {
  switch (iconName) {
    case 'warning':
      return HugeIcons.strokeRoundedAlert02;
    case 'wallet':
      return HugeIcons.strokeRoundedWallet01;
    case 'target':
      return HugeIcons.strokeRoundedTarget01;
    case 'calendar':
      return HugeIcons.strokeRoundedCalendar01;
    case 'alert':
      return HugeIcons.strokeRoundedAlert01;
    case 'trending_up':
      return HugeIcons.strokeRoundedArrowUp02;
    case 'trending_down':
      return HugeIcons.strokeRoundedArrowDown02;
    case 'clock':
      return HugeIcons.strokeRoundedClock01;
    case 'chart':
      return HugeIcons.strokeRoundedAnalytics01;
    case 'lightbulb':
      return HugeIcons.strokeRoundedIdea;
    case 'info':
      return HugeIcons.strokeRoundedInformationCircle;
    default:
      return HugeIcons.strokeRoundedNotification01;
  }
}

Color getNotificationColor(String colorName) {
  switch (colorName) {
    case 'red':
      return AppColors.red;
    case 'orange':
      return AppColors.orange;
    case 'green':
      return AppColors.green;
    case 'blue':
      return AppColors.primary;
    case 'purple':
      return AppColors.primary;
    default:
      return AppColors.primary;
  }
}

String getNotificationTypeLabel(String type) {
  switch (type) {
    case 'budget_rule_violation':
      return 'BUDGET';
    case 'pocket_budget_exceeded':
      return 'POCKET';
    case 'recurring_payment_reminder':
      return 'RAPPEL';
    case 'large_transaction_alert':
      return 'ALERTE';
    case 'spending_increase_alert':
      return 'HAUSSE';
    case 'spending_decrease_congratulations':
      return 'BRAVO';
    case 'savings_milestone':
      return 'OBJECTIF';
    case 'savings_deadline_warning':
      return 'ÉCHÉANCE';
    case 'unusual_time_transaction':
      return 'SUSPECT';
    case 'duplicate_transaction':
      return 'DOUBLON';
    case 'monthly_summary':
      return 'BILAN';
    case 'personalized_tip':
      return 'CONSEIL';
    case 'goal_achieved':
      return 'SUCCÈS';
    default:
      return 'INFO';
  }
}

String formatNotificationTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  if (difference.inMinutes < 1) {
    return 'À l\'instant';
  } else if (difference.inMinutes < 60) {
    return 'Il y a ${difference.inMinutes} min';
  } else if (difference.inHours < 24) {
    return 'Il y a ${difference.inHours}h';
  } else if (difference.inDays < 7) {
    return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
  } else {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
} 