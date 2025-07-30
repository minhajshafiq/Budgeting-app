import 'package:equatable/equatable.dart';

class SupabasePocketModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String color;
  final double budget;
  final double spent;
  final String pocketType;
  final String? savingsGoalType;
  final double? targetAmount;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupabasePocketModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.budget,
    required this.spent,
    required this.pocketType,
    this.savingsGoalType,
    this.targetAmount,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Créer depuis JSON (depuis Supabase)
  factory SupabasePocketModel.fromJson(Map<String, dynamic> json) {
    return SupabasePocketModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      pocketType: json['pocket_type'] as String,
      savingsGoalType: json['savings_goal_type'] as String?,
      targetAmount: json['target_amount'] != null 
          ? (json['target_amount'] as num).toDouble() 
          : null,
      targetDate: json['target_date'] != null 
          ? DateTime.parse(json['target_date'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convertir vers JSON (pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'budget': budget,
      'spent': spent,
      'pocket_type': pocketType,
      'savings_goal_type': savingsGoalType,
      'target_amount': targetAmount,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Créer une copie avec modifications
  SupabasePocketModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? color,
    double? budget,
    double? spent,
    String? pocketType,
    String? savingsGoalType,
    double? targetAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabasePocketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      pocketType: pocketType ?? this.pocketType,
      savingsGoalType: savingsGoalType ?? this.savingsGoalType,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        icon,
        color,
        budget,
        spent,
        pocketType,
        savingsGoalType,
        targetAmount,
        targetDate,
        createdAt,
        updatedAt,
      ];
} 