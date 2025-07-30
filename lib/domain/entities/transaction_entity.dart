class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final dynamic type; // Adapter le type si besoin
  final String? description;
  final dynamic recurrence; // Adapter le type si besoin
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.description,
    required this.recurrence,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  // Getters utiles
  bool get isIncome => type.toString() == 'income';
  bool get isExpense => type.toString() == 'expense';
  bool get isSavingsDeposit => type.toString() == 'savings_deposit';
  bool get isRecurring => recurrence.toString() != 'none';

  // Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.toString(),
      'description': description,
      'recurrence': recurrence.toString(),
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Désérialisation JSON
  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
      type: json['type'],
      description: json['description'],
      recurrence: json['recurrence'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransactionEntity(id: $id, title: $title, amount: $amount, date: $date)';
  }
} 