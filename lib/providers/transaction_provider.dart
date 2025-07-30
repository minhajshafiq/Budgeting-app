import 'package:flutter/foundation.dart';
import '../core/services/transaction_service.dart';
import '../core/services/notification_service.dart' show NotificationService, NotificationData;
import '../core/services/supabase_sync_service.dart';
import '../core/di/dependency_injection.dart';
import '../data/models/transaction.dart';
import '../data/models/category.dart';
import '../utils/performance_utils.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final NotificationService _notificationService = NotificationService();
  final SupabaseSyncService _syncService = di.supabaseSyncService;
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  // Getters
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;
  String? get currentUserId => _currentUserId;

  // Getters pour les statistiques
  double get totalIncome => _transactions.cast<Transaction>().totalIncome;
  double get totalExpenses => _transactions.cast<Transaction>().totalExpenses;
  double get balance => _transactions.cast<Transaction>().balance;

  // Getters pour les transactions filtrées
  List<Transaction> get incomeTransactions => _transactions.cast<Transaction>().incomeTransactions;
  List<Transaction> get expenseTransactions => _transactions.cast<Transaction>().expenseTransactions;

  // Transactions récentes (30 derniers jours, jusqu'à aujourd'hui uniquement)
  List<Transaction> get recentTransactions {
    final today = DateTime.now();
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    
    return _transactions
        .cast<Transaction>()
        .where((t) => t.date.isAfter(thirtyDaysAgo) && t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Transactions du mois en cours
  List<Transaction> get currentMonthTransactions {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    
    return _transactions
        .cast<Transaction>()
        .where((t) => t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
                     t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Initialiser avec l'ID utilisateur pour Supabase
  void initializeWithUser(String userId) {
    _currentUserId = userId;
    debugPrint('🔄 TransactionProvider initialisé pour l\'utilisateur: $userId');
    debugPrint('🔄 _currentUserId après initialisation: $_currentUserId');
  }

  // Initialiser les transactions depuis le service
  Future<void> initialize({bool forceSync = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _transactionService.initialize();
      
      // Si un utilisateur est connecté, synchroniser avec Supabase
      if (_currentUserId != null) {
        await syncFromSupabase(forceSync: forceSync);
      } else {
        // Sinon, charger depuis le stockage local
        await loadTransactions();
      }
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Synchroniser depuis Supabase avec logique intelligente
  Future<void> syncFromSupabase({bool forceSync = false}) async {
    debugPrint('🔄 Tentative de synchronisation...');
    debugPrint('🔄 _currentUserId: $_currentUserId');
    
    if (_currentUserId == null) {
      debugPrint('❌ Utilisateur non initialisé pour la synchronisation');
      return;
    }

    // Vérifier si une synchronisation récente a été effectuée (dans les 5 dernières minutes)
    if (!forceSync && _lastSyncTime != null) {
      final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
      if (timeSinceLastSync.inMinutes < 5) {
        debugPrint('⏭️ Synchronisation ignorée - dernière sync il y a ${timeSinceLastSync.inMinutes}min');
        return;
      }
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      debugPrint('🔄 Synchronisation depuis Supabase...');
      
      final syncResult = await _syncService.syncAllData(_currentUserId!);
      
      // S'assurer que nous travaillons avec une liste modifiable
      final newTransactions = List<Transaction>.from(syncResult.transactions);
      
      _transactions.clear();
      _transactions.addAll(newTransactions);
      
      _lastSyncTime = DateTime.now();
      
      debugPrint('✅ ${_transactions.length} transactions synchronisées');
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Erreur de synchronisation: $e');
      _error = 'Erreur de synchronisation: $e';
    } finally {
      setState(() {
        _isSyncing = false;
        _isLoading = false;
      });
    }
  }

  // Charger toutes les transactions (local uniquement)
  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Créer une nouvelle liste modifiable à partir du service
      final transactionsFromService = await _transactionService.getAllTransactions();
      _transactions = List<Transaction>.from(transactionsFromService);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des transactions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Transaction addedTransaction;

      // Si un utilisateur est connecté, synchroniser avec Supabase
      if (_currentUserId != null) {
        debugPrint('🔄 Ajout de transaction avec synchronisation Supabase...');
        
        // Ajouter localement d'abord pour l'UI
        _transactions.add(transaction);
        notifyListeners();
        
        // Synchroniser avec Supabase
        addedTransaction = await _syncService.createAndSyncTransaction(
          userId: _currentUserId!,
          transaction: transaction,
        );
        
        // Remplacer par la version synchronisée (avec l'ID de Supabase)
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _transactions[index] = addedTransaction;
          notifyListeners();
        }
        
        _lastSyncTime = DateTime.now();
        debugPrint('✅ Transaction synchronisée: ${addedTransaction.id}');
      } else {
        // Sinon, utiliser le service local
        addedTransaction = await _transactionService.addTransaction(transaction);
        await loadTransactions(); // Recharger pour synchroniser
      }
      
      // Déclencher les vérifications de notifications
      _triggerNotificationChecks(addedTransaction);
      
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la transaction: $e';
      debugPrint('❌ Erreur lors de l\'ajout: $e');
      
      // Retirer la transaction locale en cas d'erreur
      if (_currentUserId != null) {
        _transactions.removeWhere((t) => t.id == transaction.id);
        notifyListeners();
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }

  // Modifier une transaction
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Transaction updated;

      // Si un utilisateur est connecté, synchroniser avec Supabase
      if (_currentUserId != null) {
        debugPrint('🔄 Mise à jour de transaction avec synchronisation Supabase...');
        
        updated = await _syncService.updateAndSyncTransaction(
          transactionId: updatedTransaction.id,
          transaction: updatedTransaction,
        );
        
        // Mettre à jour dans la liste locale
        final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
        if (index != -1) {
          _transactions[index] = updated;
          notifyListeners();
        }
        
        _lastSyncTime = DateTime.now();
      } else {
        // Sinon, utiliser le service local
        updated = await _transactionService.updateTransaction(updatedTransaction);
        await loadTransactions(); // Recharger pour synchroniser
      }
      
      // Déclencher les vérifications de notifications après modification
      _triggerNotificationChecks(updated);
      
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Si un utilisateur est connecté, synchroniser avec Supabase
      if (_currentUserId != null) {
        debugPrint('🔄 Suppression de transaction avec synchronisation Supabase...');
        
        await _syncService.deleteAndSyncTransaction(transactionId);
        
        // Supprimer de la liste locale
        _transactions.removeWhere((t) => t.id == transactionId);
        notifyListeners();
        
        _lastSyncTime = DateTime.now();
      } else {
        // Sinon, utiliser le service local
        final deleted = await _transactionService.deleteTransaction(transactionId);
        
        if (!deleted) {
          throw Exception('Transaction non trouvée');
        }
        
        await loadTransactions(); // Recharger pour synchroniser
      }
      
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir une transaction par ID
  Transaction? getTransactionById(String id) {
    try {
      return _transactions.cast<Transaction>().firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir une transaction par ID (async depuis le service)
  Future<Transaction?> getTransactionByIdAsync(String id) async {
    return await _transactionService.getTransactionById(id);
  }

  // Obtenir les transactions par catégorie
  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactions.cast<Transaction>().forCategory(categoryId);
  }

  // Obtenir les transactions par plage de dates
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.cast<Transaction>().forDateRange(start, end);
  }

  // Statistiques par catégorie
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> result = {};
    for (final transaction in expenseTransactions) {
      result[transaction.categoryId] = 
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return result;
  }

  Map<String, double> getIncomeByCategory() {
    final Map<String, double> result = {};
    for (final transaction in incomeTransactions) {
      result[transaction.categoryId] = 
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return result;
  }

  // Trier les transactions par date (plus récentes en premier)
  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filtrer les transactions jusqu'à aujourd'hui uniquement (optionnel)
  List<Transaction> getTransactionsUpToToday([List<Transaction>? transactions]) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final transactionsToFilter = transactions ?? _transactions;
    
    return transactionsToFilter
        .where((t) => t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Obtenir toutes les transactions (passées et futures)
  List<Transaction> getAllTransactionsIncludingFuture([List<Transaction>? transactions]) {
    final transactionsToFilter = transactions ?? _transactions;
    return transactionsToFilter
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Rechercher des transactions
  Future<List<Transaction>> searchTransactions(String query) async {
    try {
      return await _transactionService.searchTransactions(query);
    } catch (e) {
      debugPrint('Erreur lors de la recherche: $e');
      return [];
    }
  }

  // Synchroniser les données
  Future<void> syncTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _transactionService.syncTransactions();
      await loadTransactions();
      
    } catch (e) {
      _error = 'Erreur lors de la synchronisation: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Exporter les transactions
  Future<String> exportTransactions() async {
    try {
      return await _transactionService.exportTransactionsToJson();
    } catch (e) {
      debugPrint('Erreur lors de l\'export: $e');
      rethrow;
    }
  }

  // Importer des transactions
  Future<int> importTransactions(String jsonData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final importedCount = await _transactionService.importTransactionsFromJson(jsonData);
      await loadTransactions();
      
      return importedCount;
    } catch (e) {
      _error = 'Erreur lors de l\'import: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Effacer toutes les transactions
  Future<void> clearAllTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _transactionService.clearAllTransactions();
      _transactions.clear();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir la dernière synchronisation
  Future<DateTime?> getLastSyncDate() async {
    return await _transactionService.getLastSyncDate();
  }

  // Méthodes pour les statistiques avancées
  Map<String, double> getMonthlyExpenses(int year) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    Map<String, double> monthlyData = {};
    
    for (int i = 1; i <= 12; i++) {
      final monthTransactions = _transactions
          .cast<Transaction>()
          .where((t) =>
              t.date.year == year &&
              t.date.month == i &&
              t.type == TransactionType.expense)
          .toList();
      
      monthlyData[months[i - 1]] = monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    }
    
    return monthlyData;
  }

  Map<String, double> getWeeklyExpenses(DateTime day) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    
    Map<String, double> weeklyData = {};
    
    for (int i = 1; i <= 7; i++) {
      final dayTransactions = _transactions
          .cast<Transaction>()
          .where((t) =>
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day &&
              t.type == TransactionType.expense)
          .toList();
      
      weeklyData[days[day.weekday - 1]] = dayTransactions.fold(0.0, (sum, t) => sum + t.amount);
    }
    
    return weeklyData;
  }

  // Analyser et déclencher les notifications appropriées
  void _triggerNotificationChecks(Transaction? newTransaction) {
    // Vérifier les dépenses récentes pour les alertes
    final recentExpenses = _transactions
        .cast<Transaction>()
        .where((t) => t.isExpense &&
                     DateTime.now().difference(t.date).inDays <= 30)
        .toList();

    if (recentExpenses.isNotEmpty) {
      final averageExpense = recentExpenses
          .fold(0.0, (sum, t) => sum + t.amount) / recentExpenses.length;
      
      // Logique de notification basée sur la moyenne
      if (newTransaction != null && newTransaction.isExpense && newTransaction.amount > averageExpense * 1.5) {
        final notification = NotificationData(
          id: 'high_expense_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Dépense élevée détectée',
          message: 'Votre dépense de ${newTransaction.amount.toStringAsFixed(2)}€ est supérieure à votre moyenne habituelle.',
          type: 'expense_alert',
          timestamp: DateTime.now(),
          icon: 'warning',
          color: 'orange',
        );
        _notificationService.addNotification(notification);
      }
    }
  }

  // Déclencher les analyses complètes (à appeler périodiquement)
  void performComprehensiveAnalysis(List<dynamic> pockets) {
    try {
      // Bilan mensuel
      _notificationService.generateMonthlyFinancialSummary(_transactions, pockets);
      
      // Suivi des objectifs d'épargne
      _notificationService.checkSavingsGoalProgress(pockets);
      
      // Toutes les autres vérifications
      _triggerNotificationChecks(null);
      
    } catch (e) {
      debugPrint('Erreur lors de l\'analyse complète: $e');
    }
  }

  // Méthode helper pour setState avec debounce
  void setState(VoidCallback fn) {
    fn();
    // Debounce les notifications pour éviter les rebuilds excessifs
    PerformanceUtils.debounce(() {
      notifyListeners();
    }, const Duration(milliseconds: 100));
  }
  
  // Méthode pour forcer une notification immédiate
  void forceNotify() {
    notifyListeners();
  }
  
  // Méthode optimisée pour ajouter plusieurs transactions
  void addTransactions(List<Transaction> transactions) {
    _transactions.addAll(transactions);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    
    // Une seule notification pour toutes les transactions
    notifyListeners();
  }
  
  // Méthode optimisée pour mettre à jour plusieurs transactions
  void updateTransactions(List<Transaction> transactions) {
    for (final transaction in transactions) {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
    }
    
    // Une seule notification pour toutes les mises à jour
    notifyListeners();
  }
  
  // Méthode pour forcer une synchronisation complète
  Future<void> forceSyncFromSupabase() async {
    await syncFromSupabase(forceSync: true);
  }
} 