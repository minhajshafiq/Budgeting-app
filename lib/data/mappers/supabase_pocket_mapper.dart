import '../models/supabase_pocket_model.dart';
import '../models/pocket.dart' as local_models;

class SupabasePocketMapper {
  // Convertir du modèle local vers Supabase
  static SupabasePocketModel fromLocalPocket(
    local_models.Pocket localPocket,
    String userId,
  ) {
    return SupabasePocketModel(
      id: localPocket.id,
      userId: userId,
      name: localPocket.name,
      icon: localPocket.icon,
      color: localPocket.color,
      budget: localPocket.budget,
      spent: localPocket.spent,
      pocketType: localPocket.type.toString().split('.').last,
      savingsGoalType: localPocket.savingsGoalType?.toString().split('.').last,
      targetAmount: localPocket.targetAmount,
      targetDate: localPocket.targetDate,
      createdAt: localPocket.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Convertir du modèle Supabase vers local
  static local_models.Pocket toLocalPocket(
    SupabasePocketModel supabasePocket,
  ) {
    return local_models.Pocket(
      id: supabasePocket.id,
      name: supabasePocket.name,
      icon: supabasePocket.icon,
      color: supabasePocket.color,
      budget: supabasePocket.budget,
      spent: supabasePocket.spent,
      type: local_models.PocketType.values.firstWhere(
        (e) => e.toString().split('.').last == supabasePocket.pocketType,
        orElse: () => local_models.PocketType.needs,
      ),
      savingsGoalType: supabasePocket.savingsGoalType != null
          ? local_models.SavingsGoalType.values.firstWhere(
              (e) => e.toString().split('.').last == supabasePocket.savingsGoalType,
              orElse: () => local_models.SavingsGoalType.other,
            )
          : null,
      targetAmount: supabasePocket.targetAmount,
      targetDate: supabasePocket.targetDate,
      createdAt: supabasePocket.createdAt,
    );
  }

  // Convertir une liste de modèles Supabase vers locaux
  static List<local_models.Pocket> toLocalPocketList(
    List<SupabasePocketModel> supabasePockets,
  ) {
    return supabasePockets
        .map((supabasePocket) => toLocalPocket(supabasePocket))
        .toList();
  }

  // Convertir une liste de modèles locaux vers Supabase
  static List<SupabasePocketModel> fromLocalPocketList(
    List<local_models.Pocket> localPockets,
    String userId,
  ) {
    return localPockets
        .map((localPocket) => fromLocalPocket(localPocket, userId))
        .toList();
  }
} 