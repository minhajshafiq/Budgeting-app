import '../repositories/transaction_repository.dart';
import 'dart:convert';

class ExportTransactionsUseCase {
  final TransactionRepository _repository;

  ExportTransactionsUseCase(this._repository);

  Future<String> execute() async {
    final transactions = await _repository.getAllTransactions();
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'transactionCount': transactions.length,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
    return json.encode(exportData);
  }
} 