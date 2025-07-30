import 'package:equatable/equatable.dart';

// Value Objects pour la sécurité
class Email {
  final String value;
  
  Email(this.value) {
    if (!_isValidEmail(value)) {
      throw InvalidEmailException('Email invalide: $value');
    }
  }
  
  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
  
  @override
  String toString() => value;
  
  @override
  bool operator ==(Object other) => other is Email && other.value == value;
  
  @override
  int get hashCode => value.hashCode;
}

class UserId {
  final String value;
  
  UserId(this.value) {
    if (value.isEmpty) {
      throw InvalidUserDataException('ID utilisateur requis');
    }
  }
  
  @override
  String toString() => value;
  
  @override
  bool operator ==(Object other) => other is UserId && other.value == value;
  
  @override
  int get hashCode => value.hashCode;
}

class AuthToken {
  final String value;
  
  AuthToken(this.value) {
    if (value.isEmpty) {
      throw InvalidTokenException('Token d\'authentification requis');
    }
  }
  
  @override
  String toString() => value;
  
  @override
  bool operator ==(Object other) => other is AuthToken && other.value == value;
  
  @override
  int get hashCode => value.hashCode;
}

// Entité principale pour l'authentification
class AuthEntity extends Equatable {
  final UserId id;
  final Email email;
  final String firstName;
  final String lastName;
  final AuthToken? token;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  AuthEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.token,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
  }) {
    if (firstName.trim().isEmpty) {
      throw InvalidUserDataException('Prénom requis');
    }
    if (lastName.trim().isEmpty) {
      throw InvalidUserDataException('Nom requis');
    }
  }

  // Getters métier
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  bool get isAuthenticated => token != null;

  // Méthodes de copie
  AuthEntity copyWith({
    UserId? id,
    Email? email,
    String? firstName,
    String? lastName,
    AuthToken? token,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return AuthEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    token,
    createdAt,
    lastLoginAt,
    isEmailVerified,
  ];
}

// Exceptions du domaine
class InvalidEmailException implements Exception {
  final String message;
  InvalidEmailException(this.message);
  
  @override
  String toString() => 'InvalidEmailException: $message';
}

class InvalidUserDataException implements Exception {
  final String message;
  InvalidUserDataException(this.message);
  
  @override
  String toString() => 'InvalidUserDataException: $message';
}

class InvalidTokenException implements Exception {
  final String message;
  InvalidTokenException(this.message);
  
  @override
  String toString() => 'InvalidTokenException: $message';
} 