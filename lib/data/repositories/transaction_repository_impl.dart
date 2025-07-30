import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_period.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../core/services/transaction_service.dart';
import '../models/transaction.dart';
import '../mappers/transaction_entity_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionService _transactionService;

  TransactionRepositoryImpl(this._transactionService);

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final transactions = await _transactionService.getAllTransactions();
    return transactions.map((t) => TransactionEntityMapper.toEntity(t)).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByPeriod(TransactionPeriod period) async {
    final allTransactions = await getTransactionsWithRecurrences();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    switch (period) {
      case TransactionPeriod.past:
        return allTransactions
            .where((t) => t.date.isBefore(todayStart))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

      case TransactionPeriod.today:
        return allTransactions
            .where((t) => 
                t.date.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
                t.date.isBefore(todayEnd.add(const Duration(seconds: 1))))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

      case TransactionPeriod.future:
        return allTransactions
            .where((t) => t.date.isAfter(todayEnd))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsWithRecurrences() async {
    final transactions = await _transactionService.getAllTransactions();
    final allOccurrences = _generateRecurringOccurrences(transactions);
    return allOccurrences.map((t) => TransactionEntityMapper.toEntity(t)).toList();
  }

  @override
  Future<TransactionEntity> addTransaction(TransactionEntity transaction) async {
    final model = TransactionEntityMapper.toData(transaction);
    final addedTransaction = await _transactionService.addTransaction(model);
    return TransactionEntityMapper.toEntity(addedTransaction);
  }

  @override
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction) async {
    final model = TransactionEntityMapper.toData(transaction);
    final updatedTransaction = await _transactionService.updateTransaction(model);
    return TransactionEntityMapper.toEntity(updatedTransaction);
  }

  @override
  Future<bool> deleteTransaction(String transactionId) async {
    return await _transactionService.deleteTransaction(transactionId);
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    final transaction = await _transactionService.getTransactionById(id);
    return transaction != null ? TransactionEntityMapper.toEntity(transaction) : null;
  }

  @override
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    final transactions = await _transactionService.searchTransactions(query);
    return transactions.map((t) => TransactionEntityMapper.toEntity(t)).toList();
  }

  @override
  Future<String> exportTransactions() async {
    return await _transactionService.exportTransactionsToJson();
  }

  @override
  Future<int> importTransactions(String jsonData) async {
    return await _transactionService.importTransactionsFromJson(jsonData);
  }

  @override
  Future<void> clearAllTransactions() async {
    await _transactionService.clearAllTransactions();
  }

  @override
  Future<void> syncTransactions() async {
    await _transactionService.syncTransactions();
  }

  @override
  Future<DateTime?> getLastSyncDate() async {
    return await _transactionService.getLastSyncDate();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId) async {
    final transactions = await _transactionService.getTransactionsByCategory(categoryId);
    return transactions.map((t) => TransactionEntityMapper.toEntity(t)).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final transactions = await _transactionService.getTransactionsByDateRange(start, end);
    return transactions.map((t) => TransactionEntityMapper.toEntity(t)).toList();
  }

  // Méthode pour générer les occurrences récurrentes
  List<Transaction> _generateRecurringOccurrences(List<Transaction> transactions) {
    final List<Transaction> allOccurrences = [];
    final now = DateTime.now();
    
    for (final transaction in transactions) {
      // Ajouter la transaction originale
      allOccurrences.add(transaction);
      
      // Si c'est une transaction récurrente, générer les occurrences futures
      if (transaction.isRecurring && transaction.recurrence != RecurrenceType.none) {
        final occurrences = _generateFutureOccurrences(transaction, now);
        allOccurrences.addAll(occurrences);
      }
    }
    
    return allOccurrences;
  }

  // Méthode pour générer les occurrences futures d'une transaction récurrente
  List<Transaction> _generateFutureOccurrences(Transaction transaction, DateTime fromDate) {
    final List<Transaction> occurrences = [];
    
    // Date de départ : la date originale de la transaction
    final startDate = transaction.date;
    
    // Générer les occurrences pour les 12 prochains mois à partir de la date de départ
    final endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
    
    DateTime currentDate = startDate;
    int occurrenceCount = 0;
    const maxOccurrences = 100; // Limite de sécurité
    
    while (currentDate.isBefore(endDate) && occurrenceCount < maxOccurrences) {
      // Calculer la prochaine date selon le type de récurrence
      final nextDate = _getNextOccurrenceDate(currentDate, transaction.recurrence);
      
      // Si la prochaine date est dans le futur par rapport à la date de départ
      if (nextDate.isAfter(startDate)) {
        // Créer une nouvelle occurrence
        final occurrence = transaction.copyWith(
          id: '${transaction.id}_occ_${occurrenceCount}',
          date: nextDate,
        );
        occurrences.add(occurrence);
        occurrenceCount++;
      }
      
      currentDate = nextDate;
    }
    
    return occurrences;
  }

  // Méthode pour calculer la prochaine date d'occurrence selon la logique exacte
  DateTime _getNextOccurrenceDate(DateTime currentDate, RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.daily:
        // Quotidienne : se répète tous les jours
        return currentDate.add(const Duration(days: 1));
        
      case RecurrenceType.weekly:
        // Hebdomadaire : se répète chaque semaine, le même jour de la semaine
        return currentDate.add(const Duration(days: 7));
        
      case RecurrenceType.monthly:
        // Mensuelle : se répète chaque mois à la même date
        final nextMonth = currentDate.month + 1;
        final nextYear = currentDate.year + (nextMonth > 12 ? 1 : 0);
        final adjustedMonth = nextMonth > 12 ? 1 : nextMonth;
        
        // Gérer les cas où le jour n'existe pas dans le mois suivant
        final lastDayOfNextMonth = DateTime(nextYear, adjustedMonth + 1, 0).day;
        final adjustedDay = currentDate.day > lastDayOfNextMonth ? lastDayOfNextMonth : currentDate.day;
        
        return DateTime(nextYear, adjustedMonth, adjustedDay);
        
      case RecurrenceType.quarterly:
        // Trimestrielle : se répète tous les 3 mois à la même date
        final nextMonth = currentDate.month + 3;
        final nextYear = currentDate.year + (nextMonth > 12 ? 1 : 0);
        final adjustedMonth = nextMonth > 12 ? nextMonth - 12 : nextMonth;
        
        // Gérer les cas où le jour n'existe pas dans le trimestre suivant
        final lastDayOfNextMonth = DateTime(nextYear, adjustedMonth + 1, 0).day;
        final adjustedDay = currentDate.day > lastDayOfNextMonth ? lastDayOfNextMonth : currentDate.day;
        
        return DateTime(nextYear, adjustedMonth, adjustedDay);
        
      case RecurrenceType.yearly:
        // Annuelle : se répète chaque année à la même date
        final nextYear = currentDate.year + 1;
        
        // Gérer les années bissextiles pour le 29 février
        if (currentDate.month == 2 && currentDate.day == 29) {
          final isLeapYear = (nextYear % 4 == 0 && nextYear % 100 != 0) || (nextYear % 400 == 0);
          return DateTime(nextYear, 2, isLeapYear ? 29 : 28);
        }
        
        return DateTime(nextYear, currentDate.month, currentDate.day);
        
      case RecurrenceType.none:
      default:
        return currentDate;
    }
  }

  /// Méthode de validation pour tester les récurrences selon les spécifications
  /// Cette méthode peut être utilisée pour déboguer et valider le comportement
  void validateRecurrenceLogic() {
    // Test quotidienne
    final dailyStart = DateTime(2025, 7, 11);
    var nextDate = _getNextOccurrenceDate(dailyStart, RecurrenceType.daily);
    print('Quotidienne: $dailyStart -> $nextDate'); // Devrait être 2025-07-12
    
    // Test hebdomadaire
    final weeklyStart = DateTime(2025, 7, 11); // Vendredi
    nextDate = _getNextOccurrenceDate(weeklyStart, RecurrenceType.weekly);
    print('Hebdomadaire: $weeklyStart -> $nextDate'); // Devrait être 2025-07-18
    
    // Test mensuelle
    final monthlyStart = DateTime(2025, 7, 11);
    nextDate = _getNextOccurrenceDate(monthlyStart, RecurrenceType.monthly);
    print('Mensuelle: $monthlyStart -> $nextDate'); // Devrait être 2025-08-11
    
    // Test trimestrielle
    final quarterlyStart = DateTime(2025, 7, 11);
    nextDate = _getNextOccurrenceDate(quarterlyStart, RecurrenceType.quarterly);
    print('Trimestrielle: $quarterlyStart -> $nextDate'); // Devrait être 2025-10-11
    
    // Test annuelle
    final yearlyStart = DateTime(2025, 7, 11);
    nextDate = _getNextOccurrenceDate(yearlyStart, RecurrenceType.yearly);
    print('Annuelle: $yearlyStart -> $nextDate'); // Devrait être 2026-07-11
  }
} 