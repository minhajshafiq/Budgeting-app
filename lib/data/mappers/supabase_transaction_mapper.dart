import '../models/supabase_transaction_model.dart';
import '../models/transaction.dart' as local_models;

class SupabaseTransactionMapper {
  // Convertir du modèle local vers Supabase
  static SupabaseTransactionModel fromLocalTransaction(
    local_models.Transaction localTransaction,
    String userId,
  ) {
    return SupabaseTransactionModel(
      id: localTransaction.id,
      userId: userId,
      title: localTransaction.title,
      amount: localTransaction.amount,
      date: localTransaction.date,
      description: localTransaction.description,
      categoryId: localTransaction.categoryId,
      transactionType: localTransaction.type.toString().split('.').last,
      recurrenceType: localTransaction.recurrence.toString().split('.').last,
      createdAt: localTransaction.createdAt,
      updatedAt: localTransaction.updatedAt ?? DateTime.now(),
    );
  }

  // Convertir du modèle Supabase vers local
  static local_models.Transaction toLocalTransaction(
    SupabaseTransactionModel supabaseTransaction,
  ) {
    return local_models.Transaction(
      id: supabaseTransaction.id,
      title: supabaseTransaction.title,
      amount: supabaseTransaction.amount,
      date: supabaseTransaction.date,
      description: supabaseTransaction.description,
      categoryId: supabaseTransaction.categoryId,
      type: local_models.TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == supabaseTransaction.transactionType,
        orElse: () => local_models.TransactionType.expense,
      ),
      recurrence: local_models.RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == (supabaseTransaction.recurrenceType ?? 'none'),
        orElse: () => local_models.RecurrenceType.none,
      ),
      createdAt: supabaseTransaction.createdAt,
      updatedAt: supabaseTransaction.updatedAt,
    );
  }

  // Convertir une liste de modèles Supabase vers locaux
  static List<local_models.Transaction> toLocalTransactionList(
    List<SupabaseTransactionModel> supabaseTransactions,
  ) {
    return supabaseTransactions
        .map((supabaseTransaction) => toLocalTransaction(supabaseTransaction))
        .toList();
  }

  // Convertir une liste de modèles locaux vers Supabase
  static List<SupabaseTransactionModel> fromLocalTransactionList(
    List<local_models.Transaction> localTransactions,
    String userId,
  ) {
    return localTransactions
        .map((localTransaction) => fromLocalTransaction(localTransaction, userId))
        .toList();
  }
} 