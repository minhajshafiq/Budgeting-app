import 'package:equatable/equatable.dart';

class SupabasePocketTransactionModel extends Equatable {
  final String id;
  final String pocketId;
  final String transactionId;
  final String userId;
  final DateTime createdAt;

  const SupabasePocketTransactionModel({
    required this.id,
    required this.pocketId,
    required this.transactionId,
    required this.userId,
    required this.createdAt,
  });

  // Créer depuis JSON (depuis Supabase)
  factory SupabasePocketTransactionModel.fromJson(Map<String, dynamic> json) {
    return SupabasePocketTransactionModel(
      id: json['id'] as String,
      pocketId: json['pocket_id'] as String,
      transactionId: json['transaction_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convertir vers JSON (pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pocket_id': pocketId,
      'transaction_id': transactionId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Créer une copie avec modifications
  SupabasePocketTransactionModel copyWith({
    String? id,
    String? pocketId,
    String? transactionId,
    String? userId,
    DateTime? createdAt,
  }) {
    return SupabasePocketTransactionModel(
      id: id ?? this.id,
      pocketId: pocketId ?? this.pocketId,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pocketId,
        transactionId,
        userId,
        createdAt,
      ];
} 