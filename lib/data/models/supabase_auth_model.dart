import '../../domain/entities/auth_entity.dart';

// Modèle de données pour l'authentification Supabase (données distantes)
class SupabaseAuthModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? token;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? userMetadata;
  final String? phoneNumber;

  SupabaseAuthModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.token,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.userMetadata,
    this.phoneNumber,
  });

  // Conversion JSON pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'userMetadata': userMetadata,
      'phoneNumber': phoneNumber,
    };
  }

  // Création depuis JSON Supabase
  factory SupabaseAuthModel.fromJson(Map<String, dynamic> json) {
    return SupabaseAuthModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      token: json['token'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      userMetadata: json['userMetadata'] as Map<String, dynamic>?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  // Création depuis la réponse Supabase Auth
  factory SupabaseAuthModel.fromSupabaseResponse({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? token,
    required DateTime createdAt,
    DateTime? lastLoginAt,
    bool isEmailVerified = false,
    Map<String, dynamic>? userMetadata,
    String? phoneNumber,
  }) {
    return SupabaseAuthModel(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      token: token,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isEmailVerified: isEmailVerified,
      userMetadata: userMetadata,
      phoneNumber: phoneNumber,
    );
  }

  // Méthodes de copie
  SupabaseAuthModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? token,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    Map<String, dynamic>? userMetadata,
    String? phoneNumber,
  }) {
    return SupabaseAuthModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      userMetadata: userMetadata ?? this.userMetadata,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseAuthModel &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.token == token &&
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
      token,
      createdAt,
      lastLoginAt,
      isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'SupabaseAuthModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName)';
  }
} 