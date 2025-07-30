import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/models/transaction.dart';
import 'secure_storage_service.dart';

class TransactionService {
  // Service de stockage sécurisé
  final SecureStorageService _secureStorage = SecureStorageService();
  
  // Instance singleton
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  // Cache local des transactions
  List<Transaction> _cachedTransactions = [];
  bool _isInitialized = false;

  /// Initialiser le service et charger les données
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadTransactionsFromStorage();
      _isInitialized = true;
      debugPrint('TransactionService initialisé avec ${_cachedTransactions.length} transactions');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du TransactionService: $e');
      _cachedTransactions = [];
      _isInitialized = true;
    }
  }

  /// Obtenir toutes les transactions
  Future<List<Transaction>> getAllTransactions() async {
    await initialize();
    return List.unmodifiable(_cachedTransactions);
  }

  /// Obtenir une transaction par ID
  Future<Transaction?> getTransactionById(String id) async {
    await initialize();
    try {
      return _cachedTransactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Ajouter une nouvelle transaction
  Future<Transaction> addTransaction(Transaction transaction) async {
    await initialize();
    
    try {
      // Vérifier que l'ID est unique
      final existingTransaction = await getTransactionById(transaction.id);
      if (existingTransaction != null) {
        throw Exception('Une transaction avec cet ID existe déjà');
      }

      // Ajouter à la liste
      _cachedTransactions.add(transaction);
      
      // Trier par date (plus récentes en premier)
      _sortTransactions();
      
      // Sauvegarder
      await _saveTransactionsToStorage();
      
      debugPrint('Transaction ajoutée: ${transaction.title} - ${transaction.formattedAmount}');
      return transaction;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la transaction: $e');
      rethrow;
    }
  }

  /// Modifier une transaction existante
  Future<Transaction> updateTransaction(Transaction updatedTransaction) async {
    await initialize();
    
    try {
      final index = _cachedTransactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (index == -1) {
        throw Exception('Transaction non trouvée');
      }

      // Mettre à jour avec timestamp
      final transactionWithTimestamp = updatedTransaction.copyWith(
        updatedAt: DateTime.now(),
      );

      _cachedTransactions[index] = transactionWithTimestamp;
      
      // Trier après modification
      _sortTransactions();
      
      // Sauvegarder
      await _saveTransactionsToStorage();
      
      debugPrint('Transaction modifiée: ${transactionWithTimestamp.title}');
      return transactionWithTimestamp;
    } catch (e) {
      debugPrint('Erreur lors de la modification de la transaction: $e');
      rethrow;
    }
  }

  /// Supprimer une transaction
  Future<bool> deleteTransaction(String transactionId) async {
    await initialize();
    
    try {
      final initialLength = _cachedTransactions.length;
      _cachedTransactions.removeWhere((t) => t.id == transactionId);
      
      if (_cachedTransactions.length == initialLength) {
        debugPrint('Transaction non trouvée pour suppression: $transactionId');
        return false;
      }

      // Sauvegarder
      await _saveTransactionsToStorage();
      
      debugPrint('Transaction supprimée: $transactionId');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la transaction: $e');
      rethrow;
    }
  }

  /// Obtenir les transactions par catégorie
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    final transactions = await getAllTransactions();
    return transactions.where((t) => t.categoryId == categoryId).toList();
  }

  /// Obtenir les transactions par plage de dates
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final transactions = await getAllTransactions();
    return transactions.where((t) => 
      t.date.isAfter(start.subtract(Duration(days: 1))) && 
      t.date.isBefore(end.add(Duration(days: 1)))
    ).toList();
  }

  /// Obtenir les transactions du mois actuel
  Future<List<Transaction>> getCurrentMonthTransactions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  /// Obtenir les transactions récentes (30 derniers jours)
  Future<List<Transaction>> getRecentTransactions({int days = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final transactions = await getAllTransactions();
    return transactions.where((t) => t.date.isAfter(cutoffDate)).toList();
  }

  /// Calculer les statistiques rapides
  Future<Map<String, double>> getTransactionStats() async {
    final transactions = await getAllTransactions();
    
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

  /// Obtenir les dépenses par catégorie
  Future<Map<String, double>> getExpensesByCategory() async {
    final transactions = await getAllTransactions();
    final Map<String, double> result = {};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      result[transaction.categoryId] = 
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    
    return result;
  }

  /// Obtenir les revenus par catégorie
  Future<Map<String, double>> getIncomeByCategory() async {
    final transactions = await getAllTransactions();
    final Map<String, double> result = {};
    
    for (final transaction in transactions.where((t) => t.isIncome)) {
      result[transaction.categoryId] = 
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    
    return result;
  }

  /// Rechercher des transactions par titre ou description
  Future<List<Transaction>> searchTransactions(String query) async {
    if (query.trim().isEmpty) return [];
    
    final transactions = await getAllTransactions();
    final lowerQuery = query.toLowerCase();
    
    return transactions.where((t) => 
      t.title.toLowerCase().contains(lowerQuery) ||
      (t.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  /// Exporter les transactions en JSON
  Future<String> exportTransactionsToJson() async {
    final transactions = await getAllTransactions();
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'transactionCount': transactions.length,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
    return json.encode(exportData);
  }

  /// Importer des transactions depuis JSON
  Future<int> importTransactionsFromJson(String jsonData) async {
    try {
      final data = json.decode(jsonData);
      final List<dynamic> transactionsList = data['transactions'] ?? [];
      
      int importedCount = 0;
      for (final transactionData in transactionsList) {
        try {
          final transaction = Transaction.fromJson(transactionData);
          
          // Vérifier si la transaction existe déjà
          final existing = await getTransactionById(transaction.id);
          if (existing == null) {
            await addTransaction(transaction);
            importedCount++;
          }
        } catch (e) {
          debugPrint('Erreur lors de l\'import d\'une transaction: $e');
        }
      }
      
      debugPrint('$importedCount transactions importées');
      return importedCount;
    } catch (e) {
      debugPrint('Erreur lors de l\'import JSON: $e');
      rethrow;
    }
  }

  /// Effacer toutes les transactions (avec confirmation)
  Future<void> clearAllTransactions() async {
    try {
      _cachedTransactions.clear();
      await _saveTransactionsToStorage();
      debugPrint('Toutes les transactions ont été supprimées');
    } catch (e) {
      debugPrint('Erreur lors de la suppression de toutes les transactions: $e');
      rethrow;
    }
  }

  /// Synchroniser les données (placeholder pour future API)
  Future<void> syncTransactions() async {
    try {
      // TODO: Implémenter la synchronisation avec l'API
      debugPrint('Synchronisation terminée');
    } catch (e) {
      debugPrint('Erreur lors de la synchronisation: $e');
      rethrow;
    }
  }

  /// Obtenir la dernière date de synchronisation
  Future<DateTime?> getLastSyncDate() async {
    try {
      // TODO: Implémenter avec le stockage sécurisé si nécessaire
      return null;
    } catch (e) {
      return null;
    }
  }

  // Méthodes privées

  /// Charger les transactions depuis le stockage sécurisé
  Future<void> _loadTransactionsFromStorage() async {
    try {
      final transactionsJson = await _secureStorage.getTransactions();
      
      if (transactionsJson != null) {
        final List<dynamic> transactionsList = json.decode(transactionsJson);
        _cachedTransactions = transactionsList
            .map((json) => Transaction.fromJson(json))
            .toList();
        
        _sortTransactions();
        debugPrint('${_cachedTransactions.length} transactions chargées depuis le stockage sécurisé');
      } else {
        // Pas de données d'exemple - liste vide pour un nouveau compte
        _cachedTransactions = [];
        await _saveTransactionsToStorage();
        debugPrint('Nouveau compte initialisé sans données d\'exemple');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des transactions: $e');
      _cachedTransactions = [];
    }
  }

  /// Sauvegarder les transactions dans le stockage sécurisé
  Future<void> _saveTransactionsToStorage() async {
    try {
      final transactionsJson = json.encode(
        _cachedTransactions.map((t) => t.toJson()).toList()
      );
      await _secureStorage.saveTransactions(transactionsJson);
      debugPrint('${_cachedTransactions.length} transactions sauvegardées dans le stockage sécurisé');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des transactions: $e');
      rethrow;
    }
  }

  /// Trier les transactions par date (plus récentes en premier)
  void _sortTransactions() {
    _cachedTransactions.sort((a, b) => b.date.compareTo(a.date));
  }


} 