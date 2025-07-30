import 'package:flutter/foundation.dart';
import '../data/models/transaction.dart';
import '../core/di/dependency_injection.dart';
import '../core/services/supabase_sync_service.dart';

class SupabaseTransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final SupabaseSyncService _syncService = di.supabaseSyncService;
  
  DateTime? _lastSyncTime;
  bool _isSyncing = false;
  String? _currentUserId;

  // Getters
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;
  int get transactionCount => _transactions.length;

  // Initialiser avec l'ID utilisateur
  void initialize(String userId) {
    _currentUserId = userId;
    debugPrint('🔄 Initialisation du provider pour l\'utilisateur: $userId');
  }

  // Synchroniser toutes les données depuis Supabase
  Future<void> syncFromSupabase() async {
    if (_currentUserId == null) {
      debugPrint('❌ Utilisateur non initialisé');
      return;
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
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  // Ajouter une transaction et la synchroniser
  Future<void> addTransaction(Transaction transaction, {List<String>? pocketIds}) async {
    if (_currentUserId == null) {
      debugPrint('❌ Utilisateur non initialisé');
      return;
    }

    try {
      debugPrint('🔄 Ajout de transaction: ${transaction.title}');
      
      // Ajouter localement d'abord pour l'UI
      _transactions.add(transaction);
      notifyListeners();
      
      // Synchroniser avec Supabase
      final syncedTransaction = await _syncService.createAndSyncTransaction(
        userId: _currentUserId!,
        transaction: transaction,
        pocketIds: pocketIds,
      );
      
      // Remplacer par la version synchronisée (avec l'ID de Supabase)
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = syncedTransaction;
        notifyListeners();
      }
      
      _lastSyncTime = DateTime.now();
      debugPrint('✅ Transaction synchronisée: ${syncedTransaction.id}');
      
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ajout: $e');
      // Retirer la transaction locale en cas d'erreur
      _transactions.removeWhere((t) => t.id == transaction.id);
      notifyListeners();
      rethrow;
    }
  }

  // Mettre à jour une transaction
  Future<void> updateTransaction(Transaction transaction, {List<String>? pocketIds}) async {
    if (_currentUserId == null) {
      debugPrint('❌ Utilisateur non initialisé');
      return;
    }

    try {
      debugPrint('🔄 Mise à jour de transaction: ${transaction.id}');
      
      // Mettre à jour localement
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
      
      // Synchroniser avec Supabase
      final syncedTransaction = await _syncService.updateAndSyncTransaction(
        transactionId: transaction.id,
        transaction: transaction,
        pocketIds: pocketIds,
      );
      
      // Mettre à jour avec la version synchronisée
      if (index != -1) {
        _transactions[index] = syncedTransaction;
        notifyListeners();
      }
      
      _lastSyncTime = DateTime.now();
      debugPrint('✅ Transaction mise à jour: ${syncedTransaction.id}');
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour: $e');
      rethrow;
    }
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    if (_currentUserId == null) {
      debugPrint('❌ Utilisateur non initialisé');
      return;
    }

    try {
      debugPrint('🔄 Suppression de transaction: $transactionId');
      
      // Supprimer localement
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
      
      // Synchroniser avec Supabase
      await _syncService.deleteAndSyncTransaction(transactionId);
      
      _lastSyncTime = DateTime.now();
      debugPrint('✅ Transaction supprimée: $transactionId');
      
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression: $e');
      rethrow;
    }
  }

  // Configurer les écouteurs en temps réel
  void setupRealtimeListeners() {
    if (_currentUserId == null) {
      debugPrint('❌ Utilisateur non initialisé pour les écouteurs temps réel');
      return;
    }

    debugPrint('🔄 Configuration des écouteurs temps réel...');
    
    _syncService.setupRealtimeListeners(
      _currentUserId!,
      onTransactionChanged: () {
        debugPrint('🔄 Changement de transaction détecté');
        // Rafraîchir les données
        syncFromSupabase();
      },
      onPocketChanged: () {
        debugPrint('🔄 Changement de pocket détecté');
        // Les changements de pocket peuvent affecter les transactions
        syncFromSupabase();
      },
    );
    
    debugPrint('✅ Écouteurs temps réel configurés');
  }

  // Arrêter les écouteurs temps réel
  void stopRealtimeListeners() {
    debugPrint('🔄 Arrêt des écouteurs temps réel...');
    _syncService.stopRealtimeListeners();
    debugPrint('✅ Écouteurs temps réel arrêtés');
  }

  // Obtenir les transactions d'un pocket spécifique
  List<Transaction> getTransactionsForPocket(String pocketId) {
    // Cette méthode nécessiterait une jointure avec pocket_transactions
    // Pour l'instant, retourne toutes les transactions
    return _transactions;
  }

  // Statistiques
  double get totalAmount => _transactions.fold(0.0, (sum, t) => sum + t.amount);
  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpenses => _transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

  // Méthodes utilitaires
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // Nettoyer les données
  void clear() {
    _transactions.clear();
    _lastSyncTime = null;
    _isSyncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopRealtimeListeners();
    super.dispose();
  }
} 