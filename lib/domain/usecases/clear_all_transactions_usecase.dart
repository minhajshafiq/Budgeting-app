import '../repositories/transaction_repository.dart';

class ClearAllTransactionsUseCase {
  final TransactionRepository _repository;

  ClearAllTransactionsUseCase(this._repository);

  Future<void> execute() async {
    // Cette méthode devra être implémentée dans le repository
    // Pour l'instant, on supprime les transactions une par une
    final allTransactions = await _repository.getAllTransactions();
    
    for (final transaction in allTransactions) {
      await _repository.deleteTransaction(transaction.id);
    }
  }
} 