import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../widgets/bar_chart.dart';

class WeeklySpendingCard extends StatelessWidget {
  final Animation<double>? animation;
  
  const WeeklySpendingCard({
    super.key,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final weeklyExpenses = _getWeeklyExpenses(transactionProvider);
        
        return CardContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dépensé cette semaine',
                style: AppTextStyles.header(context),
              ),
              const SizedBox(height: 4),
              AnimatedCounter(
                value: weeklyExpenses,
                style: AppTextStyles.amountSmall(context),
                prefix: '-',
                suffix: ' €',
                decimalPlaces: 2,
                decimalSeparator: ',',
                thousandSeparator: ' ',
                duration: const Duration(milliseconds: 1800),
                enableBounceEffect: true,
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                  animation: animation ?? const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                  final chartData = _getWeeklyDataFromTransactions(transactionProvider.transactions);
                  
                  // Vérifier que les données sont valides
                  if (chartData.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune donnée disponible',
                        style: AppTextStyles.header(context),
                      ),
                    );
                  }
                  
                    return BarChart(
                      animation: animation ?? const AlwaysStoppedAnimation(1.0),
                    data: chartData,
                      showAllLabels: true, // Afficher le label du prix au-dessus de chaque barre
                    );
                  },
              ),
            ],
          ),
        );
      },
    );
  }

  // Méthode pour calculer les dépenses hebdomadaires
  double _getWeeklyExpenses(TransactionProvider provider) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final weeklyTransactions = provider.transactions.where((transaction) {
      final t = transaction;
      return t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
             t.date.isBefore(endOfWeek.add(const Duration(days: 1))) &&
             t.isExpense;
    }).toList();
    
    return weeklyTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Méthode pour obtenir les données du graphique hebdomadaire avec normalisation
  List<Map<String, dynamic>> _getWeeklyDataFromTransactions(List<dynamic> transactions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Utiliser les mêmes couleurs dégradées que la page statistiques
    final Map<String, double> dailyExpenses = {
      'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0,
      'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
    };
    
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // Traiter les transactions seulement si elles existent
    if (transactions.isNotEmpty) {
    for (final transaction in transactions) {
      if (transaction.isExpense) {
        final transactionDate = transaction.date;
        final dayOfWeek = transactionDate.weekday - 1; // 0 = lundi, 6 = dimanche
        
        if (transactionDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
          final dayName = dayNames[dayOfWeek];
          dailyExpenses[dayName] = dailyExpenses[dayName]! + transaction.amount;
          }
        }
      }
    }
    
    // Créer les données brutes avec les couleurs dégradées
    final rawData = [
      {'period': 'Mon', 'expenses': dailyExpenses['Mon']!, 'color': AppColors.barMon},
      {'period': 'Tue', 'expenses': dailyExpenses['Tue']!, 'color': AppColors.barTue},
      {'period': 'Wed', 'expenses': dailyExpenses['Wed']!, 'color': AppColors.barWed},
      {'period': 'Thu', 'expenses': dailyExpenses['Thu']!, 'color': AppColors.barThu},
      {'period': 'Fri', 'expenses': dailyExpenses['Fri']!, 'color': AppColors.barFri},
      {'period': 'Sat', 'expenses': dailyExpenses['Sat']!, 'color': AppColors.barSat},
      {'period': 'Sun', 'expenses': dailyExpenses['Sun']!, 'color': AppColors.barSun},
    ];
    
    // Normaliser les données comme dans la page statistiques
    return _normalizeData(rawData);
  }

  // Méthode de normalisation identique à celle de la page statistiques
  List<Map<String, dynamic>> _normalizeData(List<Map<String, dynamic>> rawData) {
    const maxBarHeight = 100.0;
    const maxExpense = 1000.0; // 1000€ = barre max (identique à la page statistiques)
    
    return rawData.map((item) {
      final expense = item['expenses'] as double;
      final normalizedHeight = expense > maxExpense ? maxBarHeight : (expense / maxExpense) * maxBarHeight;
      
      return {
        'day': item['period'],
        'period': item['period'],
        'amount': normalizedHeight,
        'expense': expense,
        'value': '${expense.toStringAsFixed(expense >= 1000 ? 0 : 2)}€',
        'color': item['color'],
      };
    }).toList();
  }
} 