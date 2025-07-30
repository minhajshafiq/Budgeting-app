import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/supabase_pocket_model.dart';

class SupabasePocketService {
  final SupabaseClient _supabase;
  
  SupabasePocketService(this._supabase);

  // Créer un nouveau pocket
  Future<SupabasePocketModel> createPocket({
    required String userId,
    required String name,
    required String icon,
    required String color,
    required double budget,
    required String pocketType,
    String? savingsGoalType,
    double? targetAmount,
    DateTime? targetDate,
  }) async {
    try {
      debugPrint('🔄 Création de pocket dans Supabase...');
      
      final now = DateTime.now();
      final pocketData = {
        'user_id': userId,
        'name': name,
        'icon': icon,
        'color': color,
        'budget': budget,
        'spent': 0.0,
        'pocket_type': pocketType,
        'savings_goal_type': savingsGoalType,
        'target_amount': targetAmount,
        'target_date': targetDate?.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('pockets')
          .insert(pocketData)
          .select()
          .single();

      final pocket = SupabasePocketModel.fromJson(response);
      debugPrint('✅ Pocket créé: ${pocket.id}');
      return pocket;
    } catch (e) {
      debugPrint('❌ Erreur lors de la création du pocket: $e');
      rethrow;
    }
  }

  // Récupérer tous les pockets d'un utilisateur
  Future<List<SupabasePocketModel>> getUserPockets(String userId) async {
    try {
      debugPrint('🔄 Récupération des pockets utilisateur...');
      
      final response = await _supabase
          .from('pockets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final pockets = response
          .map((json) => SupabasePocketModel.fromJson(json))
          .toList();

      debugPrint('✅ ${pockets.length} pockets récupérés');
      return pockets;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des pockets: $e');
      rethrow;
    }
  }

  // Récupérer un pocket par ID
  Future<SupabasePocketModel?> getPocketById(String pocketId) async {
    try {
      final response = await _supabase
          .from('pockets')
          .select()
          .eq('id', pocketId)
          .single();

      return SupabasePocketModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du pocket: $e');
      return null;
    }
  }

  // Mettre à jour un pocket
  Future<SupabasePocketModel> updatePocket({
    required String pocketId,
    String? name,
    String? icon,
    String? color,
    double? budget,
    double? spent,
    String? pocketType,
    String? savingsGoalType,
    double? targetAmount,
    DateTime? targetDate,
  }) async {
    try {
      debugPrint('🔄 Mise à jour du pocket: $pocketId');
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (icon != null) updateData['icon'] = icon;
      if (color != null) updateData['color'] = color;
      if (budget != null) updateData['budget'] = budget;
      if (spent != null) updateData['spent'] = spent;
      if (pocketType != null) updateData['pocket_type'] = pocketType;
      if (savingsGoalType != null) updateData['savings_goal_type'] = savingsGoalType;
      if (targetAmount != null) updateData['target_amount'] = targetAmount;
      if (targetDate != null) updateData['target_date'] = targetDate.toIso8601String();

      final response = await _supabase
          .from('pockets')
          .update(updateData)
          .eq('id', pocketId)
          .select()
          .single();

      final pocket = SupabasePocketModel.fromJson(response);
      debugPrint('✅ Pocket mis à jour: ${pocket.id}');
      return pocket;
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du pocket: $e');
      rethrow;
    }
  }

  // Supprimer un pocket
  Future<void> deletePocket(String pocketId) async {
    try {
      debugPrint('🔄 Suppression du pocket: $pocketId');
      
      // Supprimer d'abord les relations avec les transactions
      await _supabase
          .from('pocket_transactions')
          .delete()
          .eq('pocket_id', pocketId);

      // Supprimer le pocket
      await _supabase
          .from('pockets')
          .delete()
          .eq('id', pocketId);

      debugPrint('✅ Pocket supprimé: $pocketId');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression du pocket: $e');
      rethrow;
    }
  }

  // Mettre à jour le montant dépensé d'un pocket
  Future<void> updatePocketSpent(String pocketId, double newSpent) async {
    try {
      await _supabase
          .from('pockets')
          .update({
            'spent': newSpent,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', pocketId);

      debugPrint('✅ Montant dépensé mis à jour pour le pocket: $pocketId');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du montant dépensé: $e');
      rethrow;
    }
  }

  // Récupérer les pockets par type
  Future<List<SupabasePocketModel>> getPocketsByType(String userId, String pocketType) async {
    try {
      final response = await _supabase
          .from('pockets')
          .select()
          .eq('user_id', userId)
          .eq('pocket_type', pocketType)
          .order('created_at', ascending: false);

      return response
          .map((json) => SupabasePocketModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des pockets par type: $e');
      rethrow;
    }
  }

  // Écouter les changements en temps réel
  RealtimeChannel subscribeToPockets(String userId) {
    return _supabase
        .channel('pockets_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pockets',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            debugPrint('🔄 Changement pocket détecté: ${payload.eventType}');
          },
        )
        .subscribe();
  }
} 