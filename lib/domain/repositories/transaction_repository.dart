import '../entities/transaction_entity.dart';
import '../entities/transaction_period.dart';

abstract class TransactionRepository {
  /// Récupère toutes les transactions
  Future<List<TransactionEntity>> getAllTransactions();
  
  /// Récupère les transactions selon la période spécifiée
  Future<List<TransactionEntity>> getTransactionsByPeriod(TransactionPeriod period);
  
  /// Récupère les transactions récurrentes avec leurs occurrences générées
  Future<List<TransactionEntity>> getTransactionsWithRecurrences();
  
  /// Ajoute une nouvelle transaction
  Future<TransactionEntity> addTransaction(TransactionEntity transaction);
  
  /// Met à jour une transaction existante
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);
  
  /// Supprime une transaction
  Future<bool> deleteTransaction(String transactionId);
  
  /// Récupère une transaction par son ID
  Future<TransactionEntity?> getTransactionById(String id);
  
  /// Recherche des transactions par titre ou description
  Future<List<TransactionEntity>> searchTransactions(String query);
  
  /// Exporte toutes les transactions en JSON
  Future<String> exportTransactions();
  
  /// Importe des transactions depuis JSON
  Future<int> importTransactions(String jsonData);
  
  /// Efface toutes les transactions
  Future<void> clearAllTransactions();
  
  /// Synchronise les données (placeholder pour future API)
  Future<void> syncTransactions();
  
  /// Obtient la dernière date de synchronisation
  Future<DateTime?> getLastSyncDate();
  
  /// Obtient les transactions par catégorie
  Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId);
  
  /// Obtient les transactions par plage de dates
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end);
} 