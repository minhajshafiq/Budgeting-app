import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

class GetRecentTransactionsUseCase {
  final TransactionRepository _repository;

  GetRecentTransactionsUseCase(this._repository);

  Future<List<TransactionEntity>> execute({int days = 30}) async {
    final allTransactions = await _repository.getAllTransactions();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return allTransactions
        .where((t) => t.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<TransactionEntity>> getCurrentMonthTransactions() async {
    final allTransactions = await _repository.getAllTransactions();
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    
    return allTransactions
        .where((t) => t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
                     t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<TransactionEntity>> getTransactionsUpToToday() async {
    final allTransactions = await _repository.getAllTransactions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return allTransactions
        .where((t) => t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<TransactionEntity>> getAllTransactionsIncludingFuture() async {
    final allTransactions = await _repository.getAllTransactions();
    return allTransactions
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
} 