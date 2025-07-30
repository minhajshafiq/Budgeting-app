import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_period.dart';
import '../../domain/usecases/get_transactions_by_period_usecase.dart';
import '../../domain/usecases/search_transactions_usecase.dart';
import '../../domain/usecases/export_transactions_usecase.dart';
import '../../domain/usecases/import_transactions_usecase.dart';
import '../../domain/usecases/clear_all_transactions_usecase.dart';
import '../../domain/usecases/get_transaction_statistics_usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/transaction.dart';
import 'package:my_flutter_app/data/mappers/transaction_entity_mapper.dart';

class TransactionProviderClean extends ChangeNotifier {
  final GetTransactionsByPeriodUseCase _getTransactionsByPeriodUseCase;
  final SearchTransactionsUseCase _searchTransactionsUseCase;
  final ExportTransactionsUseCase _exportTransactionsUseCase;
  final ImportTransactionsUseCase _importTransactionsUseCase;
  final ClearAllTransactionsUseCase _clearAllTransactionsUseCase;
  final GetTransactionStatisticsUseCase _getTransactionStatisticsUseCase;
  final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;
  final TransactionRepository _repository;
  final NotificationService _notificationService = NotificationService();

  // État
  TransactionPeriod _selectedPeriod = TransactionPeriod.today;
  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  TransactionPeriod get selectedPeriod => _selectedPeriod;
  List<TransactionEntity> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters pour les statistiques
  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpenses => _transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpenses;

  // Getters pour les transactions filtrées
  List<TransactionEntity> get incomeTransactions => _transactions.where((t) => t.isIncome).toList();
  List<TransactionEntity> get expenseTransactions => _transactions.where((t) => t.isExpense).toList();

  TransactionProviderClean(
    this._getTransactionsByPeriodUseCase,
    this._searchTransactionsUseCase,
    this._exportTransactionsUseCase,
    this._importTransactionsUseCase,
    this._clearAllTransactionsUseCase,
    this._getTransactionStatisticsUseCase,
    this._getRecentTransactionsUseCase,
    this._repository,
  );

  /// Initialiser le provider
  Future<void> initialize() async {
    await loadTransactionsByPeriod(_selectedPeriod);
  }

  /// Charger les transactions selon la période sélectionnée
  Future<void> loadTransactionsByPeriod(TransactionPeriod period) async {
    try {
      _isLoading = true;
      _error = null;
      _selectedPeriod = period;
      notifyListeners();

      _transactions = await _getTransactionsByPeriodUseCase.execute(period);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des transactions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger toutes les transactions avec récurrences
  Future<void> loadAllTransactionsWithRecurrences() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _getTransactionsByPeriodUseCase.executeWithRecurrences();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des transactions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une transaction
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final addedTransaction = await _repository.addTransaction(transaction);
      
      // Recharger toutes les transactions avec récurrences pour synchroniser
      // car la page d'historique utilise loadAllTransactionsWithRecurrences
      await loadAllTransactionsWithRecurrences();
      
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la transaction: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Modifier une transaction
  Future<void> updateTransaction(TransactionEntity updatedTransaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateTransaction(updatedTransaction);
      
      // Recharger toutes les transactions avec récurrences pour synchroniser
      // car la page d'historique utilise loadAllTransactionsWithRecurrences
      await loadAllTransactionsWithRecurrences();
      
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final deleted = await _repository.deleteTransaction(transactionId);
      
      if (!deleted) {
        throw Exception('Transaction non trouvée');
      }
      
      // Recharger toutes les transactions avec récurrences pour synchroniser
      // car la page d'historique utilise loadAllTransactionsWithRecurrences
      await loadAllTransactionsWithRecurrences();
      
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir une transaction par ID
  TransactionEntity? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les transactions par catégorie
  List<TransactionEntity> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  /// Obtenir les transactions par plage de dates
  List<TransactionEntity> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
      t.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
      t.date.isBefore(end.add(const Duration(seconds: 1)))
    ).toList();
  }

  /// Statistiques par catégorie
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

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Obtenir le nombre de transactions par période
  Future<Map<TransactionPeriod, int>> getTransactionCountsByPeriod() async {
    final Map<TransactionPeriod, int> counts = {};
    
    for (final period in TransactionPeriod.values) {
      try {
        final transactions = await _getTransactionsByPeriodUseCase.execute(period);
        counts[period] = transactions.length;
      } catch (e) {
        counts[period] = 0;
      }
    }
    
    return counts;
  }

  // === MÉTHODES FUSIONNÉES DE TRANSACTIONPROVIDER ===

  /// Ajout batch de transactions
  void addTransactions(List<TransactionEntity> transactions) {
    _transactions.addAll(transactions);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// Mise à jour batch de transactions
  void updateTransactions(List<TransactionEntity> transactions) {
    for (final transaction in transactions) {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
    }
    notifyListeners();
  }

  /// Forcer la notification immédiate
  void forceNotify() {
    notifyListeners();
  }

  /// setState avec debounce (optionnel, simple debounce)
  void setState(VoidCallback fn) {
    fn();
    // Pour un vrai debounce, il faudrait utiliser un Timer, mais on garde simple ici
    notifyListeners();
  }

  /// Trier les transactions par date (plus récentes en premier)
  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Transactions récentes (30 derniers jours, jusqu'à aujourd'hui uniquement) - version synchrone
  List<TransactionEntity> get recentTransactions {
    final today = DateTime.now();
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    return _transactions
        .where((t) => t.date.isAfter(thirtyDaysAgo) && t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Transactions du mois en cours - version synchrone
  List<TransactionEntity> get currentMonthTransactions {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    return _transactions
        .where((t) => t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
                     t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Filtrer les transactions jusqu'à aujourd'hui uniquement (synchrone)
  List<TransactionEntity> getTransactionsUpToTodaySync([List<TransactionEntity>? transactions]) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final transactionsToFilter = transactions ?? _transactions;
    return transactionsToFilter
        .where((t) => t.date.isBefore(today.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Obtenir toutes les transactions (passées et futures) - version synchrone
  List<TransactionEntity> getAllTransactionsIncludingFutureSync([List<TransactionEntity>? transactions]) {
    final transactionsToFilter = transactions ?? _transactions;
    return transactionsToFilter
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Statistiques avancées : dépenses hebdomadaires
  Map<String, double> getWeeklyExpenses(DateTime day) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    Map<String, double> weeklyData = {};
    for (int i = 1; i <= 7; i++) {
      final dayTransactions = _transactions
          .where((t) =>
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day &&
              t.isExpense)
          .toList();
      weeklyData[days[day.weekday - 1]] = dayTransactions.fold(0.0, (sum, t) => sum + t.amount);
    }
    return weeklyData;
  }

  /// Rechercher des transactions
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    return await _searchTransactionsUseCase.execute(query);
  }

  /// Synchroniser les données
  Future<void> syncTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.syncTransactions();
      await loadAllTransactionsWithRecurrences();
      
    } catch (e) {
      _error = 'Erreur lors de la synchronisation: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exporter les transactions
  Future<String> exportTransactions() async {
    try {
      return await _exportTransactionsUseCase.execute();
    } catch (e) {
      debugPrint('Erreur lors de l\'export: $e');
      rethrow;
    }
  }

  /// Importer des transactions
  Future<int> importTransactions(String jsonData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final importedCount = await _importTransactionsUseCase.execute(jsonData);
      await loadAllTransactionsWithRecurrences();
      
      return importedCount;
    } catch (e) {
      _error = 'Erreur lors de l\'import: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Effacer toutes les transactions
  Future<void> clearAllTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _clearAllTransactionsUseCase.execute();
      _transactions.clear();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir la dernière synchronisation
  Future<DateTime?> getLastSyncDate() async {
    return await _repository.getLastSyncDate();
  }

  /// Calculer les statistiques rapides
  Future<Map<String, double>> getTransactionStats() async {
    return await _getTransactionStatisticsUseCase.execute();
  }

  /// Obtenir les dépenses mensuelles
  Future<Map<String, double>> getMonthlyExpenses(int year) async {
    return await _getTransactionStatisticsUseCase.getMonthlyExpenses(year);
  }

  /// Analyser et déclencher les notifications appropriées
  void _triggerNotificationChecks(TransactionEntity? newTransaction) {
    // Vérifier les dépenses récentes pour les alertes
    final recentExpenses = _transactions
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

  /// Déclencher les analyses complètes (à appeler périodiquement)
  void performComprehensiveAnalysis(List<dynamic> pockets) {
    try {
      // Bilan mensuel
      _notificationService.generateMonthlyFinancialSummary(_transactions.map((e) => TransactionEntityMapper.toData(e)).toList(), pockets);
      
      // Suivi des objectifs d'épargne
      _notificationService.checkSavingsGoalProgress(pockets);
      
      // Toutes les autres vérifications
      _triggerNotificationChecks(null);
      
    } catch (e) {
      debugPrint('Erreur lors de l\'analyse complète: $e');
    }
  }
} 