import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';

class SearchTransactionsUseCase {
  final TransactionRepository _repository;

  SearchTransactionsUseCase(this._repository);

  Future<List<TransactionEntity>> execute(String query) async {
    if (query.trim().isEmpty) return [];
    
    final allTransactions = await _repository.getAllTransactions();
    final lowerQuery = query.toLowerCase();
    
    return allTransactions.where((t) => 
      t.title.toLowerCase().contains(lowerQuery) ||
      (t.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
} 