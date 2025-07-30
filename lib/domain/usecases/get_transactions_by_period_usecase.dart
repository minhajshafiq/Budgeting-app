import '../entities/transaction_entity.dart';
import '../entities/transaction_period.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByPeriodUseCase {
  final TransactionRepository _repository;

  GetTransactionsByPeriodUseCase(this._repository);

  /// Exécute le use case pour récupérer les transactions selon la période
  Future<List<TransactionEntity>> execute(TransactionPeriod period) async {
    // Charger toutes les transactions avec récurrences puis filtrer par période
    final allTransactions = await _repository.getTransactionsWithRecurrences();
    return _filterTransactionsByPeriod(allTransactions, period);
  }

  /// Filtre les transactions selon la période
  List<TransactionEntity> _filterTransactionsByPeriod(List<TransactionEntity> transactions, TransactionPeriod period) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    switch (period) {
      case TransactionPeriod.past:
        return transactions
            .where((t) => t.date.isBefore(todayStart))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

      case TransactionPeriod.today:
        return transactions
            .where((t) => 
                t.date.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
                t.date.isBefore(todayEnd.add(const Duration(seconds: 1))))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

      case TransactionPeriod.future:
        return transactions
            .where((t) => t.date.isAfter(todayEnd))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  /// Récupère toutes les transactions avec leurs occurrences récurrentes
  Future<List<TransactionEntity>> executeWithRecurrences() async {
    return await _repository.getTransactionsWithRecurrences();
  }
} 