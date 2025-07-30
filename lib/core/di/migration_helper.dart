import '../../presentation/providers/transaction_provider_clean.dart';
import '../../providers/transaction_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../data/models/transaction.dart';

/// Helper pour faciliter la migration de l'ancien vers le nouveau provider
class MigrationHelper {
  
  /// Convertit une TransactionEntity en Transaction (modèle)
  static Transaction entityToModel(TransactionEntity entity) {
    return entity.toModel();
  }
  
  /// Convertit une Transaction (modèle) en TransactionEntity
  static TransactionEntity modelToEntity(Transaction model) {
    return TransactionEntity.fromModel(model);
  }
  
  /// Synchronise les données entre l'ancien et le nouveau provider
  static Future<void> syncProviders(
    TransactionProvider oldProvider,
    TransactionProviderClean newProvider,
  ) async {
    // Recharger les données dans le nouveau provider
    await newProvider.loadAllTransactionsWithRecurrences();
  }
  
  /// Détermine quel provider utiliser selon le contexte
  static bool shouldUseNewProvider(String context) {
    // Liste des contextes qui utilisent déjà le nouveau provider
    const newProviderContexts = [
      'transaction_history',
      'statistics',
      'clean_architecture',
    ];
    
    return newProviderContexts.contains(context);
  }
  
  /// Obtient le provider approprié selon le contexte
  static dynamic getProviderForContext(
    String context,
    TransactionProvider oldProvider,
    TransactionProviderClean newProvider,
  ) {
    return shouldUseNewProvider(context) ? newProvider : oldProvider;
  }
} 