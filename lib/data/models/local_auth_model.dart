import '../../domain/entities/auth_entity.dart';
import 'supabase_auth_model.dart';

// Modèle de données pour l'authentification locale (stockage sécurisé)
class LocalAuthModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final DateTime? lastSyncAt;

  LocalAuthModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.lastSyncAt,
  });

  // Conversion JSON pour le stockage local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  // Création depuis JSON local
  factory LocalAuthModel.fromJson(Map<String, dynamic> json) {
    return LocalAuthModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] != null 
          ? DateTime.parse(json['lastSyncAt'] as String) 
          : null,
    );
  }

  // Création depuis un modèle Supabase (sans token)
  factory LocalAuthModel.fromSupabaseModel(SupabaseAuthModel supabaseModel) {
    return LocalAuthModel(
      id: supabaseModel.id,
      email: supabaseModel.email,
      firstName: supabaseModel.firstName,
      lastName: supabaseModel.lastName,
      createdAt: supabaseModel.createdAt,
      lastLoginAt: supabaseModel.lastLoginAt,
      isEmailVerified: supabaseModel.isEmailVerified,
      lastSyncAt: DateTime.now(),
    );
  }

  // Méthodes de copie
  LocalAuthModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    DateTime? lastSyncAt,
  }) {
    return LocalAuthModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  // Vérifier si les données sont périmées (plus de 24h)
  bool get isStale {
    if (lastSyncAt == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastSyncAt!);
    return difference.inHours > 24;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalAuthModel &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      firstName,
      lastName,
      createdAt,
      lastLoginAt,
      isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'LocalAuthModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName)';
  }
} 