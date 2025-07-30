import 'package:flutter/foundation.dart';

class NotificationData {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String icon;
  final String color;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.color,
  });

  NotificationData copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    String? icon,
    String? color,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'icon': icon,
      'color': color,
    };
  }

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationData> _notifications = [];
  
  List<NotificationData> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Ajouter une notification
  void addNotification(NotificationData notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Marquer une notification comme lue
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Marquer toutes les notifications comme lues
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Supprimer une notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }



  // Vérifier et créer une notification pour la règle 50/30/20
  void checkBudgetRuleViolation({
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
    required double monthlyIncome,
  }) {
    final now = DateTime.now();
    final violations = <String>[];
    
    // Vérifier les violations
    if (needsPercentage > 50) {
      violations.add('Besoins: ${needsPercentage.toStringAsFixed(1)}% (limite: 50%)');
    }
    if (wantsPercentage > 30) {
      violations.add('Envies: ${wantsPercentage.toStringAsFixed(1)}% (limite: 30%)');
    }
    if (savingsPercentage < 20) {
      violations.add('Épargne: ${savingsPercentage.toStringAsFixed(1)}% (minimum: 20%)');
    }

    if (violations.isNotEmpty) {
      // Vérifier si une notification similaire n'a pas déjà été envoyée récemment
      final recentNotifications = _notifications.where((n) => 
        n.type == 'budget_rule_violation' && 
        now.difference(n.timestamp).inHours < 24
      );

      if (recentNotifications.isEmpty) {
        String title = 'Règle 50/30/20 non respectée';
        String message;
        
        if (violations.length == 1) {
          message = 'Attention: ${violations.first}. Ajustez votre budget pour retrouver l\'équilibre.';
        } else {
          message = 'Attention: ${violations.length} catégories dépassent les limites recommandées. Consultez vos pockets pour plus de détails.';
        }

        final notification = NotificationData(
          id: 'budget_rule_${now.millisecondsSinceEpoch}',
          title: title,
          message: message,
          type: 'budget_rule_violation',
          timestamp: now,
          icon: 'warning',
          color: 'red',
        );

        addNotification(notification);
      }
    }
  }

  // Créer une notification de dépassement de budget pour un pocket spécifique
  void notifyBudgetExceeded({
    required String pocketName,
    required double budgetAmount,
    required double spentAmount,
    required double excessPercentage,
  }) {
    final now = DateTime.now();
    
    // Vérifier si une notification similaire n'a pas déjà été envoyée récemment pour ce pocket
    final recentNotifications = _notifications.where((n) => 
      n.type == 'pocket_budget_exceeded' && 
      n.message.contains(pocketName) &&
      now.difference(n.timestamp).inHours < 6
    );

    if (recentNotifications.isEmpty) {
      final notification = NotificationData(
        id: 'pocket_exceeded_${now.millisecondsSinceEpoch}',
        title: 'Budget dépassé: $pocketName',
        message: 'Vous avez dépassé votre budget de ${excessPercentage.toStringAsFixed(1)}%. Dépensé: ${spentAmount.toStringAsFixed(0)}€ sur ${budgetAmount.toStringAsFixed(0)}€.',
        type: 'pocket_budget_exceeded',
        timestamp: now,
        icon: 'wallet',
        color: 'orange',
      );

      addNotification(notification);
    }
  }

  // Créer une notification d'objectif atteint
  void notifyGoalAchieved({
    required String goalName,
    required double targetAmount,
  }) {
    final now = DateTime.now();
    
    final notification = NotificationData(
      id: 'goal_achieved_${now.millisecondsSinceEpoch}',
      title: 'Objectif atteint !',
      message: 'Félicitations ! Vous avez atteint votre objectif "$goalName" de ${targetAmount.toStringAsFixed(0)}€.',
      type: 'goal_achieved',
      timestamp: now,
      icon: 'target',
      color: 'green',
    );

    addNotification(notification);
  }

  // Rappel de paiements récurrents
  void checkRecurringPaymentReminders(List<dynamic> transactions) {
    final now = DateTime.now();
    final upcomingPayments = <Map<String, dynamic>>[];

    for (final transaction in transactions) {
      if (transaction.recurrence != null && transaction.recurrence.toString() != 'RecurrenceType.none') {
        final lastPaymentDate = transaction.date;
        DateTime? nextPaymentDate;

        switch (transaction.recurrence.toString()) {
          case 'RecurrenceType.weekly':
            nextPaymentDate = lastPaymentDate.add(const Duration(days: 7));
            break;
          case 'RecurrenceType.monthly':
            nextPaymentDate = DateTime(lastPaymentDate.year, lastPaymentDate.month + 1, lastPaymentDate.day);
            break;
          case 'RecurrenceType.quarterly':
            nextPaymentDate = DateTime(lastPaymentDate.year, lastPaymentDate.month + 3, lastPaymentDate.day);
            break;
          case 'RecurrenceType.yearly':
            nextPaymentDate = DateTime(lastPaymentDate.year + 1, lastPaymentDate.month, lastPaymentDate.day);
            break;
        }

        if (nextPaymentDate != null) {
          final daysUntilPayment = nextPaymentDate.difference(now).inDays;
          
          // Notifier 2 jours avant pour les paiements importants (>50€)
          if (daysUntilPayment <= 2 && daysUntilPayment >= 0 && transaction.amount > 50) {
            upcomingPayments.add({
              'title': transaction.title,
              'amount': transaction.amount,
              'date': nextPaymentDate,
              'daysUntil': daysUntilPayment,
            });
          }
        }
      }
    }

    // Créer des notifications pour les paiements à venir
    for (final payment in upcomingPayments) {
      final existingNotification = _notifications.where((n) => 
        n.type == 'recurring_payment_reminder' && 
        n.message.contains(payment['title']) &&
        now.difference(n.timestamp).inHours < 48
      );

      if (existingNotification.isEmpty) {
        final daysText = payment['daysUntil'] == 0 ? 'aujourd\'hui' : 
                        payment['daysUntil'] == 1 ? 'demain' : 'dans ${payment['daysUntil']} jours';
        
        final notification = NotificationData(
          id: 'recurring_payment_${now.millisecondsSinceEpoch}',
          title: 'Paiement récurrent à venir',
          message: '${payment['title']} (${payment['amount'].toStringAsFixed(0)}€) est prévu $daysText.',
          type: 'recurring_payment_reminder',
          timestamp: now,
          icon: 'calendar',
          color: 'blue',
        );

        addNotification(notification);
      }
    }
  }

  // Alerte pour les grosses transactions
  void checkLargeTransactionAlert(dynamic transaction, double averageSpending) {
    final now = DateTime.now();
    
    // Alerter si la transaction est 3x supérieure à la moyenne ou >200€
    if (transaction.amount > (averageSpending * 3) || transaction.amount > 200) {
      final notification = NotificationData(
        id: 'large_transaction_${now.millisecondsSinceEpoch}',
        title: 'Transaction importante détectée',
        message: '${transaction.title}: ${transaction.amount.toStringAsFixed(0)}€. Cela représente ${(transaction.amount / averageSpending).toStringAsFixed(1)}x votre dépense moyenne.',
        type: 'large_transaction_alert',
        timestamp: now,
        icon: 'alert',
        color: 'orange',
      );

      addNotification(notification);
    }
  }

  // Analyse des habitudes de dépense
  void analyzeSpendingPatterns(List<dynamic> transactions) {
    final now = DateTime.now();
    final thisMonth = transactions.where((t) => 
      t.date.month == now.month && 
      t.date.year == now.year && 
      t.isExpense
    ).toList();
    
    final lastMonth = transactions.where((t) => 
      t.date.month == (now.month == 1 ? 12 : now.month - 1) && 
      t.date.year == (now.month == 1 ? now.year - 1 : now.year) && 
      t.isExpense
    ).toList();

    if (thisMonth.isNotEmpty && lastMonth.isNotEmpty) {
      final thisMonthTotal = thisMonth.fold(0.0, (sum, t) => sum + t.amount);
      final lastMonthTotal = lastMonth.fold(0.0, (sum, t) => sum + t.amount);
      
      final changePercentage = ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100);

      // Alerte si augmentation de plus de 20%
      if (changePercentage > 20) {
        final recentNotifications = _notifications.where((n) => 
          n.type == 'spending_increase_alert' && 
          now.difference(n.timestamp).inDays < 7
        );

        if (recentNotifications.isEmpty) {
          final notification = NotificationData(
            id: 'spending_increase_${now.millisecondsSinceEpoch}',
            title: 'Dépenses en hausse',
            message: 'Vos dépenses ont augmenté de ${changePercentage.toStringAsFixed(1)}% par rapport au mois dernier (${thisMonthTotal.toStringAsFixed(0)}€ vs ${lastMonthTotal.toStringAsFixed(0)}€).',
            type: 'spending_increase_alert',
            timestamp: now,
            icon: 'trending_up',
            color: 'orange',
          );

          addNotification(notification);
        }
      }
      
      // Félicitations si diminution de plus de 10%
      else if (changePercentage < -10) {
        final recentNotifications = _notifications.where((n) => 
          n.type == 'spending_decrease_congratulations' && 
          now.difference(n.timestamp).inDays < 7
        );

        if (recentNotifications.isEmpty) {
          final notification = NotificationData(
            id: 'spending_decrease_${now.millisecondsSinceEpoch}',
            title: 'Bravo ! Dépenses maîtrisées',
            message: 'Vous avez réduit vos dépenses de ${(-changePercentage).toStringAsFixed(1)}% ce mois-ci. Économies: ${(lastMonthTotal - thisMonthTotal).toStringAsFixed(0)}€ !',
            type: 'spending_decrease_congratulations',
            timestamp: now,
            icon: 'trending_down',
            color: 'green',
          );

          addNotification(notification);
        }
      }
    }
  }

  // Suivi des objectifs d'épargne
  void checkSavingsGoalProgress(List<dynamic> pockets) {
    final now = DateTime.now();
    
    for (final pocket in pockets) {
      if (pocket.targetAmount != null && pocket.targetAmount! > 0) {
        final progressPercentage = (pocket.spent / pocket.targetAmount! * 100);
        
        // Notification pour les jalons atteints (25%, 50%, 75%, 90%)
        final milestones = [25, 50, 75, 90];
        for (final milestone in milestones) {
          if (progressPercentage >= milestone) {
            final existingNotification = _notifications.where((n) => 
              n.type == 'savings_milestone' && 
              n.message.contains(pocket.name) &&
              n.message.contains('$milestone%') &&
              now.difference(n.timestamp).inDays < 30
            );

            if (existingNotification.isEmpty) {
              final notification = NotificationData(
                id: 'savings_milestone_${pocket.id}_$milestone',
                title: 'Objectif en progression !',
                message: '${pocket.name}: $milestone% atteint ! ${pocket.spent.toStringAsFixed(0)}€ sur ${pocket.targetAmount!.toStringAsFixed(0)}€.',
                type: 'savings_milestone',
                timestamp: now,
                icon: 'target',
                color: milestone >= 90 ? 'green' : 'blue',
              );

              addNotification(notification);
            }
          }
        }

        // Alerte si la date limite approche sans atteindre l'objectif
        if (pocket.targetDate != null) {
          final daysUntilDeadline = pocket.targetDate!.difference(now).inDays;
          
          if (daysUntilDeadline <= 30 && daysUntilDeadline > 0 && progressPercentage < 80) {
            final existingNotification = _notifications.where((n) => 
              n.type == 'savings_deadline_warning' && 
              n.message.contains(pocket.name) &&
              now.difference(n.timestamp).inDays < 7
            );

            if (existingNotification.isEmpty) {
              final notification = NotificationData(
                id: 'savings_deadline_${pocket.id}',
                title: 'Objectif en retard',
                message: '${pocket.name}: Il vous reste $daysUntilDeadline jours pour atteindre votre objectif. Accélérez vos économies !',
                type: 'savings_deadline_warning',
                timestamp: now,
                icon: 'clock',
                color: 'orange',
              );

              addNotification(notification);
            }
          }
        }
      }
    }
  }

  // Détection de transactions inhabituelles
  void detectUnusualTransactions(List<dynamic> transactions) {
    final now = DateTime.now();
    final recentTransactions = transactions.where((t) => 
      now.difference(t.date).inDays <= 1 && t.isExpense
    ).toList();

    for (final transaction in recentTransactions) {
      // Transactions à des heures inhabituelles (très tôt ou très tard)
      final hour = transaction.date.hour;
      if (hour < 6 || hour > 23) {
        final existingNotification = _notifications.where((n) => 
          n.type == 'unusual_time_transaction' && 
          n.message.contains(transaction.title) &&
          now.difference(n.timestamp).inHours < 24
        );

        if (existingNotification.isEmpty) {
          final timeString = '${hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}';
          
          final notification = NotificationData(
            id: 'unusual_time_${transaction.id}',
            title: 'Transaction à heure inhabituelle',
            message: '${transaction.title} (${transaction.amount.toStringAsFixed(0)}€) effectuée à $timeString. Vérifiez si c\'est normal.',
            type: 'unusual_time_transaction',
            timestamp: now,
            icon: 'clock',
            color: 'orange',
          );

          addNotification(notification);
        }
      }

      // Doubles dépenses (même montant, même jour, même catégorie)
      final duplicates = transactions.where((t) => 
        t.id != transaction.id &&
        t.amount == transaction.amount &&
        t.categoryId == transaction.categoryId &&
        t.date.day == transaction.date.day &&
        t.date.month == transaction.date.month &&
        t.date.year == transaction.date.year
      ).toList();

      if (duplicates.isNotEmpty) {
        final existingNotification = _notifications.where((n) => 
          n.type == 'duplicate_transaction' && 
          n.message.contains(transaction.amount.toStringAsFixed(0)) &&
          now.difference(n.timestamp).inHours < 24
        );

        if (existingNotification.isEmpty) {
          final notification = NotificationData(
            id: 'duplicate_${transaction.id}',
            title: 'Transaction en double détectée',
            message: 'Deux transactions identiques de ${transaction.amount.toStringAsFixed(0)}€ aujourd\'hui. Vérifiez s\'il n\'y a pas d\'erreur.',
            type: 'duplicate_transaction',
            timestamp: now,
            icon: 'warning',
            color: 'orange',
          );

          addNotification(notification);
        }
      }
    }
  }

  // Bilan financier mensuel
  void generateMonthlyFinancialSummary(List<dynamic> transactions, List<dynamic> pockets) {
    final now = DateTime.now();
    final isLastDayOfMonth = now.day >= DateTime(now.year, now.month + 1, 0).day - 2;
    
    if (isLastDayOfMonth) {
      final existingNotification = _notifications.where((n) => 
        n.type == 'monthly_summary' && 
        now.difference(n.timestamp).inDays < 28
      );

      if (existingNotification.isEmpty) {
        final monthlyTransactions = transactions.where((t) => 
          t.date.month == now.month && t.date.year == now.year
        ).toList();

        final totalIncome = monthlyTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
        final totalExpenses = monthlyTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
        final balance = totalIncome - totalExpenses;
        
        final topCategory = _getTopSpendingCategory(monthlyTransactions);
        final pocketsOverBudget = pockets.where((p) => p.isOverBudget).length;

        String message = 'Ce mois: +${totalIncome.toStringAsFixed(0)}€ / -${totalExpenses.toStringAsFixed(0)}€';
        if (balance > 0) {
          message += '. Solde positif: +${balance.toStringAsFixed(0)}€ 🎉';
        } else {
          message += '. Attention: déficit de ${(-balance).toStringAsFixed(0)}€';
        }
        
        if (topCategory.isNotEmpty) {
          message += '\nPrincipale dépense: $topCategory';
        }
        
        if (pocketsOverBudget > 0) {
          message += '\n$pocketsOverBudget pocket(s) en dépassement';
        }

        final notification = NotificationData(
          id: 'monthly_summary_${now.year}_${now.month}',
          title: 'Bilan mensuel',
          message: message,
          type: 'monthly_summary',
          timestamp: now,
          icon: 'chart',
          color: balance > 0 ? 'green' : 'orange',
        );

        addNotification(notification);
      }
    }
  }

  // Conseils personnalisés basés sur les habitudes
  void generatePersonalizedTips(List<dynamic> transactions) {
    final now = DateTime.now();
    
    // Générer un conseil par semaine maximum
    final existingTip = _notifications.where((n) => 
      n.type == 'personalized_tip' && 
      now.difference(n.timestamp).inDays < 7
    );

    if (existingTip.isEmpty) {
      final tips = _analyzeSpendingForTips(transactions);
      
      if (tips.isNotEmpty) {
        final randomTip = tips[now.day % tips.length];
        
        final notification = NotificationData(
          id: 'tip_${now.millisecondsSinceEpoch}',
          title: randomTip['title']!,
          message: randomTip['message']!,
          type: 'personalized_tip',
          timestamp: now,
          icon: 'lightbulb',
          color: 'blue',
        );

        addNotification(notification);
      }
    }
  }

  // Méthodes utilitaires privées
  String _getTopSpendingCategory(List<dynamic> transactions) {
    final categoryTotals = <String, double>{};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      categoryTotals[transaction.categoryId] = 
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
    }

    if (categoryTotals.isEmpty) return '';

    final topCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    // Mapper les IDs de catégorie vers des noms lisibles
    final categoryNames = {
      'expense_food': 'Alimentation',
      'expense_transport': 'Transport',
      'expense_shopping': 'Shopping',
      'expense_subscription': 'Abonnements',
      'expense_entertainment': 'Divertissement',
      'expense_health': 'Santé',
      'expense_bills': 'Factures',
      'expense_other': 'Autres dépenses',
    };

    return '${categoryNames[topCategory.key] ?? 'Autres'} (${topCategory.value.toStringAsFixed(0)}€)';
  }

  List<Map<String, String>> _analyzeSpendingForTips(List<dynamic> transactions) {
    final tips = <Map<String, String>>[];
    final now = DateTime.now();
    
    // Analyse des abonnements
    final subscriptions = transactions.where((t) => 
      t.categoryId == 'expense_subscription' && 
      t.recurrence.toString() != 'RecurrenceType.none'
    ).toList();
    
    if (subscriptions.length > 3) {
      tips.add({
        'title': 'Optimisez vos abonnements',
        'message': 'Vous avez ${subscriptions.length} abonnements actifs. Pensez à faire le tri pour économiser !',
      });
    }

    // Analyse des sorties restaurant
    final restaurantExpenses = transactions.where((t) => 
      t.categoryId == 'expense_food' && 
      now.difference(t.date).inDays <= 30
    ).length;
    
    if (restaurantExpenses > 8) {
      tips.add({
        'title': 'Cuisinez plus souvent',
        'message': 'Vous avez dépensé dans $restaurantExpenses restaurants ce mois. Cuisiner chez vous pourrait vous faire économiser !',
      });
    }

    // Analyse des achats impulsifs (weekend)
    final weekendPurchases = transactions.where((t) => 
      (t.date.weekday == 6 || t.date.weekday == 7) && 
      t.categoryId == 'expense_shopping' &&
      now.difference(t.date).inDays <= 14
    ).length;
    
    if (weekendPurchases > 3) {
      tips.add({
        'title': 'Attention aux achats weekend',
        'message': 'Vous faites beaucoup d\'achats le weekend. Établissez une liste avant de sortir !',
      });
    }

    // Conseils génériques
    tips.addAll([
      {
        'title': 'Règle des 24h',
        'message': 'Pour les achats non essentiels, attendez 24h avant d\'acheter. Vous changerez peut-être d\'avis !',
      },
      {
        'title': 'Objectif d\'épargne',
        'message': 'Fixez-vous un objectif d\'épargne automatique de 10% de vos revenus chaque mois.',
      },
      {
        'title': 'Comparez les prix',
        'message': 'Utilisez des applications de comparaison de prix avant vos gros achats.',
      },
    ]);

    return tips;
  }
} 