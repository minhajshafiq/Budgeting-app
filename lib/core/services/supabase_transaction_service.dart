import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/supabase_transaction_model.dart';
import '../../data/models/supabase_pocket_transaction_model.dart';

class SupabaseTransactionService {
  final SupabaseClient _supabase;
  
  SupabaseTransactionService(this._supabase);

  // Créer une nouvelle transaction
  Future<SupabaseTransactionModel> createTransaction({
    required String userId,
    required String title,
    required double amount,
    required DateTime date,
    String? description,
    required String categoryId,
    required String transactionType,
    String? recurrenceType,
    List<String>? pocketIds,
  }) async {
    try {
      debugPrint('🔄 Création de transaction dans Supabase...');
      
      final now = DateTime.now();
      final transactionData = {
        'user_id': userId,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'description': description,
        'category_id': categoryId,
        'transaction_type': transactionType,
        'recurrence_type': recurrenceType,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('transactions')
          .insert(transactionData)
          .select()
          .single();

      final transaction = SupabaseTransactionModel.fromJson(response);
      debugPrint('✅ Transaction créée: ${transaction.id}');

      // Si des pocketIds sont fournis, créer les relations
      if (pocketIds != null && pocketIds.isNotEmpty) {
        await _createPocketTransactionRelations(
          transactionId: transaction.id,
          pocketIds: pocketIds,
          userId: userId,
        );
      }

      return transaction;
    } catch (e) {
      debugPrint('❌ Erreur lors de la création de la transaction: $e');
      rethrow;
    }
  }

  // Récupérer toutes les transactions d'un utilisateur
  Future<List<SupabaseTransactionModel>> getUserTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? transactionType,
  }) async {
    try {
      debugPrint('🔄 Récupération des transactions utilisateur...');
      
      // Construire la requête de base
      var query = _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId);

      // Appliquer les filtres conditionnels
      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (transactionType != null) {
        query = query.eq('transaction_type', transactionType);
      }

      // Ajouter l'ordre
      final response = await query.order('date', ascending: false);
      
      final transactions = response
          .map((json) => SupabaseTransactionModel.fromJson(json))
          .toList();

      debugPrint('✅ ${transactions.length} transactions récupérées');
      return transactions;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des transactions: $e');
      rethrow;
    }
  }

  // Récupérer une transaction par ID
  Future<SupabaseTransactionModel?> getTransactionById(String transactionId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .single();

      return SupabaseTransactionModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération de la transaction: $e');
      return null;
    }
  }

  // Mettre à jour une transaction
  Future<SupabaseTransactionModel> updateTransaction({
    required String transactionId,
    String? title,
    double? amount,
    DateTime? date,
    String? description,
    String? categoryId,
    String? transactionType,
    String? recurrenceType,
    List<String>? pocketIds,
  }) async {
    try {
      debugPrint('🔄 Mise à jour de la transaction: $transactionId');
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (amount != null) updateData['amount'] = amount;
      if (date != null) updateData['date'] = date.toIso8601String();
      if (description != null) updateData['description'] = description;
      if (categoryId != null) updateData['category_id'] = categoryId;
      if (transactionType != null) updateData['transaction_type'] = transactionType;
      if (recurrenceType != null) updateData['recurrence_type'] = recurrenceType;

      final response = await _supabase
          .from('transactions')
          .update(updateData)
          .eq('id', transactionId)
          .select()
          .single();

      final transaction = SupabaseTransactionModel.fromJson(response);
      debugPrint('✅ Transaction mise à jour: ${transaction.id}');

      // Si des pocketIds sont fournis, mettre à jour les relations
      if (pocketIds != null) {
        await _updatePocketTransactionRelations(
          transactionId: transactionId,
          pocketIds: pocketIds,
        );
      }

      return transaction;
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour de la transaction: $e');
      rethrow;
    }
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      debugPrint('🔄 Suppression de la transaction: $transactionId');
      
      // Supprimer d'abord les relations avec les pockets
      await _supabase
          .from('pocket_transactions')
          .delete()
          .eq('transaction_id', transactionId);

      // Supprimer la transaction
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', transactionId);

      debugPrint('✅ Transaction supprimée: $transactionId');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de la transaction: $e');
      rethrow;
    }
  }

  // Récupérer les transactions d'un pocket spécifique
  Future<List<SupabaseTransactionModel>> getPocketTransactions(String pocketId) async {
    try {
      final response = await _supabase
          .from('pocket_transactions')
          .select('''
            transaction_id,
            transactions (*)
          ''')
          .eq('pocket_id', pocketId);

      final transactions = <SupabaseTransactionModel>[];
      for (final item in response) {
        if (item['transactions'] != null) {
          transactions.add(SupabaseTransactionModel.fromJson(item['transactions']));
        }
      }

      return transactions;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des transactions du pocket: $e');
      rethrow;
    }
  }

  // Créer les relations entre transaction et pockets
  Future<void> _createPocketTransactionRelations({
    required String transactionId,
    required List<String> pocketIds,
    required String userId,
  }) async {
    try {
      final relations = pocketIds.map((pocketId) => {
        'pocket_id': pocketId,
        'transaction_id': transactionId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await _supabase
          .from('pocket_transactions')
          .insert(relations);

      debugPrint('✅ Relations pocket-transaction créées');
    } catch (e) {
      debugPrint('❌ Erreur lors de la création des relations: $e');
      rethrow;
    }
  }

  // Mettre à jour les relations entre transaction et pockets
  Future<void> _updatePocketTransactionRelations({
    required String transactionId,
    required List<String> pocketIds,
  }) async {
    try {
      // Supprimer les anciennes relations
      await _supabase
          .from('pocket_transactions')
          .delete()
          .eq('transaction_id', transactionId);

      // Créer les nouvelles relations
      if (pocketIds.isNotEmpty) {
        final relations = pocketIds.map((pocketId) => {
          'pocket_id': pocketId,
          'transaction_id': transactionId,
          'created_at': DateTime.now().toIso8601String(),
        }).toList();

        await _supabase
            .from('pocket_transactions')
            .insert(relations);
      }

      debugPrint('✅ Relations pocket-transaction mises à jour');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour des relations: $e');
      rethrow;
    }
  }

  // Écouter les changements en temps réel
  RealtimeChannel subscribeToTransactions(String userId) {
    return _supabase
        .channel('transactions_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            debugPrint('🔄 Changement transaction détecté: ${payload.eventType}');
          },
        )
        .subscribe();
  }
} 