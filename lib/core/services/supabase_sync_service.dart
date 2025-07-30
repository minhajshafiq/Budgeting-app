import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/supabase_transaction_model.dart';
import '../../data/models/supabase_pocket_model.dart';
import '../../data/mappers/supabase_transaction_mapper.dart';
import '../../data/mappers/supabase_pocket_mapper.dart';
import '../../data/models/transaction.dart' as local_models;
import '../../data/models/pocket.dart' as local_models;
import 'supabase_transaction_service.dart';
import 'supabase_pocket_service.dart';

class SupabaseSyncService {
  final SupabaseClient _supabase;
  final SupabaseTransactionService _transactionService;
  final SupabasePocketService _pocketService;
  
  SupabaseSyncService(this._supabase)
      : _transactionService = SupabaseTransactionService(_supabase),
        _pocketService = SupabasePocketService(_supabase);

  // Synchroniser toutes les données au login
  Future<SyncResult> syncAllData(String userId) async {
    try {
      debugPrint('🔄 Début de la synchronisation complète pour l\'utilisateur: $userId');
      
      final result = SyncResult();
      
      // Synchroniser les pockets
      final pockets = await _pocketService.getUserPockets(userId);
      result.pockets = SupabasePocketMapper.toLocalPocketList(pockets);
      
      // Synchroniser les transactions
      final transactions = await _transactionService.getUserTransactions(userId: userId);
      result.transactions = SupabaseTransactionMapper.toLocalTransactionList(transactions);
      
      debugPrint('✅ Synchronisation terminée: ${result.pockets.length} pockets, ${result.transactions.length} transactions');
      return result;
    } catch (e) {
      debugPrint('❌ Erreur lors de la synchronisation: $e');
      rethrow;
    }
  }

  // Créer une transaction et la synchroniser
  Future<local_models.Transaction> createAndSyncTransaction({
    required String userId,
    required local_models.Transaction transaction,
    List<String>? pocketIds,
  }) async {
    try {
      debugPrint('🔄 Création et synchronisation de transaction...');
      
      final supabaseTransaction = await _transactionService.createTransaction(
        userId: userId,
        title: transaction.title,
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
        categoryId: transaction.categoryId,
        transactionType: transaction.type.toString().split('.').last,
        recurrenceType: transaction.recurrence.toString().split('.').last,
        pocketIds: pocketIds,
      );

      final localTransaction = SupabaseTransactionMapper.toLocalTransaction(supabaseTransaction);
      debugPrint('✅ Transaction créée et synchronisée: ${localTransaction.id}');
      return localTransaction;
    } catch (e) {
      debugPrint('❌ Erreur lors de la création de la transaction: $e');
      rethrow;
    }
  }

  // Mettre à jour une transaction et la synchroniser
  Future<local_models.Transaction> updateAndSyncTransaction({
    required String transactionId,
    required local_models.Transaction transaction,
    List<String>? pocketIds,
  }) async {
    try {
      debugPrint('🔄 Mise à jour et synchronisation de transaction...');
      
      final supabaseTransaction = await _transactionService.updateTransaction(
        transactionId: transactionId,
        title: transaction.title,
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
        categoryId: transaction.categoryId,
        transactionType: transaction.type.toString().split('.').last,
        recurrenceType: transaction.recurrence.toString().split('.').last,
        pocketIds: pocketIds,
      );

      final localTransaction = SupabaseTransactionMapper.toLocalTransaction(supabaseTransaction);
      debugPrint('✅ Transaction mise à jour et synchronisée: ${localTransaction.id}');
      return localTransaction;
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour de la transaction: $e');
      rethrow;
    }
  }

  // Supprimer une transaction et la synchroniser
  Future<void> deleteAndSyncTransaction(String transactionId) async {
    try {
      debugPrint('🔄 Suppression et synchronisation de transaction...');
      await _transactionService.deleteTransaction(transactionId);
      debugPrint('✅ Transaction supprimée et synchronisée: $transactionId');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de la transaction: $e');
      rethrow;
    }
  }

  // Créer un pocket et le synchroniser
  Future<local_models.Pocket> createAndSyncPocket({
    required String userId,
    required local_models.Pocket pocket,
  }) async {
    try {
      debugPrint('🔄 Création et synchronisation de pocket...');
      
      final supabasePocket = await _pocketService.createPocket(
        userId: userId,
        name: pocket.name,
        icon: pocket.icon,
        color: pocket.color,
        budget: pocket.budget,
        pocketType: pocket.type.toString().split('.').last,
        savingsGoalType: pocket.savingsGoalType?.toString().split('.').last,
        targetAmount: pocket.targetAmount,
        targetDate: pocket.targetDate,
      );

      final localPocket = SupabasePocketMapper.toLocalPocket(supabasePocket);
      debugPrint('✅ Pocket créé et synchronisé: ${localPocket.id}');
      return localPocket;
    } catch (e) {
      debugPrint('❌ Erreur lors de la création du pocket: $e');
      rethrow;
    }
  }

  // Mettre à jour un pocket et le synchroniser
  Future<local_models.Pocket> updateAndSyncPocket({
    required String pocketId,
    required local_models.Pocket pocket,
  }) async {
    try {
      debugPrint('🔄 Mise à jour et synchronisation de pocket...');
      
      final supabasePocket = await _pocketService.updatePocket(
        pocketId: pocketId,
        name: pocket.name,
        icon: pocket.icon,
        color: pocket.color,
        budget: pocket.budget,
        spent: pocket.spent,
        pocketType: pocket.type.toString().split('.').last,
        savingsGoalType: pocket.savingsGoalType?.toString().split('.').last,
        targetAmount: pocket.targetAmount,
        targetDate: pocket.targetDate,
      );

      final localPocket = SupabasePocketMapper.toLocalPocket(supabasePocket);
      debugPrint('✅ Pocket mis à jour et synchronisé: ${localPocket.id}');
      return localPocket;
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du pocket: $e');
      rethrow;
    }
  }

  // Supprimer un pocket et le synchroniser
  Future<void> deleteAndSyncPocket(String pocketId) async {
    try {
      debugPrint('🔄 Suppression et synchronisation de pocket...');
      await _pocketService.deletePocket(pocketId);
      debugPrint('✅ Pocket supprimé et synchronisé: $pocketId');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression du pocket: $e');
      rethrow;
    }
  }

  // Mettre à jour le montant dépensé d'un pocket
  Future<void> updatePocketSpent(String pocketId, double newSpent) async {
    try {
      await _pocketService.updatePocketSpent(pocketId, newSpent);
      debugPrint('✅ Montant dépensé mis à jour pour le pocket: $pocketId');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du montant dépensé: $e');
      rethrow;
    }
  }

  // Récupérer les transactions d'un pocket spécifique
  Future<List<local_models.Transaction>> getPocketTransactions(String pocketId) async {
    try {
      final supabaseTransactions = await _transactionService.getPocketTransactions(pocketId);
      return SupabaseTransactionMapper.toLocalTransactionList(supabaseTransactions);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des transactions du pocket: $e');
      rethrow;
    }
  }

  // Configurer les écouteurs en temps réel
  void setupRealtimeListeners(String userId, {
    required Function() onTransactionChanged,
    required Function() onPocketChanged,
  }) {
    // Écouter les changements de transactions
    _transactionService.subscribeToTransactions(userId);
    
    // Écouter les changements de pockets
    _pocketService.subscribeToPockets(userId);
    
    debugPrint('✅ Écouteurs en temps réel configurés pour l\'utilisateur: $userId');
  }

  // Arrêter les écouteurs en temps réel
  void stopRealtimeListeners() {
    try {
      _supabase.removeAllChannels();
      debugPrint('✅ Écouteurs en temps réel arrêtés');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'arrêt des écouteurs: $e');
    }
  }
}

// Classe pour stocker le résultat de la synchronisation
class SyncResult {
  List<local_models.Pocket> pockets = [];
  List<local_models.Transaction> transactions = [];
  
  SyncResult();
} 