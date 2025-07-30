import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

class GetTransactionStatisticsUseCase {
  final TransactionRepository _repository;

  GetTransactionStatisticsUseCase(this._repository);

  Future<Map<String, double>> execute() async {
    final transactions = await _repository.getAllTransactions();
    
    double totalIncome = 0;
    double totalExpenses = 0;
    
    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }
    
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
      'transactionCount': transactions.length.toDouble(),
    };
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final transactions = await _repository.getAllTransactions();
    final Map<String, double> result = {};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      result[transaction.categoryId] = 
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    
    return result;
  }

  Future<Map<String, double>> getIncomeByCategory() async {
    final transactions = await _repository.getAllTransactions();
    final Map<String, double> result = {};
    
    for (final transaction in transactions.where((t) => t.isIncome)) {
      result[transaction.categoryId] = 
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    
    return result;
  }

  Future<Map<String, double>> getMonthlyExpenses(int year) async {
    final transactions = await _repository.getAllTransactions();
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    Map<String, double> monthlyData = {};
    
    for (int i = 1; i <= 12; i++) {
      final monthTransactions = transactions
          .where((t) =>
              t.date.year == year &&
              t.date.month == i &&
              t.isExpense)
          .toList();
      
      monthlyData[months[i - 1]] = monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    }
    
    return monthlyData;
  }
} 