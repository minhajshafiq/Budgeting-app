import 'package:equatable/equatable.dart';

class SupabaseTransactionModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final String? description;
  final String categoryId;
  final String transactionType;
  final String? recurrenceType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupabaseTransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    this.description,
    required this.categoryId,
    required this.transactionType,
    this.recurrenceType,
    required this.createdAt,
    required this.updatedAt,
  });

  // Créer depuis JSON (depuis Supabase)
  factory SupabaseTransactionModel.fromJson(Map<String, dynamic> json) {
    return SupabaseTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      categoryId: json['category_id'] as String,
      transactionType: json['transaction_type'] as String,
      recurrenceType: json['recurrence_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convertir vers JSON (pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'category_id': categoryId,
      'transaction_type': transactionType,
      'recurrence_type': recurrenceType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Créer une copie avec modifications
  SupabaseTransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    String? description,
    String? categoryId,
    String? transactionType,
    String? recurrenceType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabaseTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      transactionType: transactionType ?? this.transactionType,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        amount,
        date,
        description,
        categoryId,
        transactionType,
        recurrenceType,
        createdAt,
        updatedAt,
      ];
} 