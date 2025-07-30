enum TransactionType { income, expense, savings_deposit }
enum RecurrenceType { none, daily, weekly, monthly, quarterly, yearly }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final String? description;
  final RecurrenceType recurrence;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.description,
    this.recurrence = RecurrenceType.none,
    this.imageUrl,
    DateTime? createdAt,
    this.updatedAt,
  }) : 
    id = id ?? _generateId(),
    createdAt = createdAt ?? DateTime.now();

  // Générateur d'ID simple
  static String _generateId() {
    return 'tx_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  // Getters utiles
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isSavingsDeposit => type == TransactionType.savings_deposit;
  bool get isRecurring => recurrence != RecurrenceType.none;
  
  String get formattedAmount {
    final sign = isIncome ? '+' : (isSavingsDeposit ? '→' : '-');
    return '$sign${amount.toStringAsFixed(2)}€';
  }

  String get displayAmount {
    return '${amount.toStringAsFixed(2)}€';
  }

  // Méthodes de copie
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    TransactionType? type,
    String? description,
    RecurrenceType? recurrence,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      description: description ?? this.description,
      recurrence: recurrence ?? this.recurrence,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.toString().split('.').last,
      'description': description,
      'recurrence': recurrence.toString().split('.').last,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Fonction utilitaire pour parser les dates de manière sûre
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Erreur parsing DateTime: $value - $e');
        return null;
      }
    }
    return null;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: _parseDateTime(json['date']) ?? DateTime.now(),
      categoryId: json['categoryId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      description: json['description'],
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['recurrence'],
        orElse: () => RecurrenceType.none,
      ),
      imageUrl: json['imageUrl'],
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  // Méthodes utilitaires
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $formattedAmount, date: $date)';
  }
}

// Extensions utiles
extension TransactionListExtensions on List<Transaction> {
  double get totalIncome => 
    where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  
  double get totalExpenses => 
    where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
  
  double get totalSavingsDeposits => 
    where((t) => t.isSavingsDeposit).fold(0.0, (sum, t) => sum + t.amount);
  
  double get balance => totalIncome - totalExpenses - totalSavingsDeposits;
  
  List<Transaction> get incomeTransactions => 
    where((t) => t.isIncome).toList();
  
  List<Transaction> get expenseTransactions => 
    where((t) => t.isExpense).toList();
  
  List<Transaction> get savingsTransactions => 
    where((t) => t.isSavingsDeposit).toList();
  
  List<Transaction> forCategory(String categoryId) => 
    where((t) => t.categoryId == categoryId).toList();
  
  List<Transaction> forDateRange(DateTime start, DateTime end) => 
    where((t) => t.date.isAfter(start) && t.date.isBefore(end)).toList();
} 