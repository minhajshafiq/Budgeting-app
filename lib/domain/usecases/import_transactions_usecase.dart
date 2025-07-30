import '../repositories/transaction_repository.dart';
import '../entities/transaction_entity.dart';
import 'dart:convert';

class ImportTransactionsUseCase {
  final TransactionRepository _repository;

  ImportTransactionsUseCase(this._repository);

  Future<int> execute(String jsonData) async {
    try {
      final data = json.decode(jsonData);
      final List<dynamic> transactionsList = data['transactions'] ?? [];
      
      int importedCount = 0;
      for (final transactionData in transactionsList) {
        try {
          final transaction = TransactionEntity.fromJson(transactionData);
          
          // Vérifier si la transaction existe déjà
          final existing = await _repository.getTransactionById(transaction.id);
          if (existing == null) {
            await _repository.addTransaction(transaction);
            importedCount++;
          }
        } catch (e) {
          print('Erreur lors de l\'import d\'une transaction: $e');
        }
      }
      
      return importedCount;
    } catch (e) {
      print('Erreur lors de l\'import JSON: $e');
      rethrow;
    }
  }
} 