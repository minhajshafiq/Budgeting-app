import 'package:equatable/equatable.dart';

// Enums du domaine
enum UserRole { user, premium, admin }
enum AuthStatus { authenticated, unauthenticated, loading }
enum PremiumPlan { monthly, yearly, lifetime }

// Value Objects
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

// Entity principale
class UserEntity extends Equatable {
  final UserId id;
  final Email email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? profileImageUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final Map<String, bool> notificationPreferences;
  
  // Propriétés premium
  final bool isPremium;
  final PremiumPlan? premiumPlan;
  final DateTime? premiumExpiresAt;
  final bool isTrial;
  final DateTime? trialExpiresAt;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;

  UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.profileImageUrl,
    this.role = UserRole.user,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.notificationPreferences,
    this.isPremium = false,
    this.premiumPlan,
    this.premiumExpiresAt,
    this.isTrial = false,
    this.trialExpiresAt,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
  }) {
    if (firstName.isEmpty) {
      throw InvalidUserDataException('Prénom requis');
    }
    if (lastName.isEmpty) {
      throw InvalidUserDataException('Nom requis');
    }
  }

  // Getters métier
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  bool get isAdmin => role == UserRole.admin;
  
  // Logique métier pour les permissions
  bool get canEdit {
    // Si premium actif
    if (isPremium && premiumPlan != null) {
      if (premiumPlan == PremiumPlan.lifetime) return true;
      if (premiumExpiresAt != null && premiumExpiresAt!.isAfter(DateTime.now())) {
        return true;
      }
    }
    
    // Si en période d'essai
    if (isTrial && trialExpiresAt != null && trialExpiresAt!.isAfter(DateTime.now())) {
      return true;
    }
    
    return false;
  }

  // Logique métier pour l'abonnement premium
  bool get hasActivePremium {
    if (!isPremium || premiumPlan == null) return false;
    if (premiumPlan == PremiumPlan.lifetime) return true;
    return premiumExpiresAt != null && premiumExpiresAt!.isAfter(DateTime.now());
  }

  // Logique métier pour l'essai gratuit
  bool get hasActiveTrial {
    return isTrial && trialExpiresAt != null && trialExpiresAt!.isAfter(DateTime.now());
  }

  // Logique métier pour le statut d'abonnement
  String get subscriptionStatus {
    if (hasActivePremium) {
      switch (premiumPlan) {
        case PremiumPlan.monthly:
          return 'Premium Mensuel';
        case PremiumPlan.yearly:
          return 'Premium Annuel';
        case PremiumPlan.lifetime:
          return 'Premium À Vie';
        default:
          return 'Premium';
      }
    } else if (hasActiveTrial) {
      final daysLeft = trialExpiresAt!.difference(DateTime.now()).inDays;
      return 'Essai gratuit ($daysLeft jours restants)';
    } else {
      return 'Gratuit (Lecture seule)';
    }
  }

  // Calculs métier
  int? get trialDaysLeft {
    if (!hasActiveTrial) return null;
    return trialExpiresAt!.difference(DateTime.now()).inDays;
  }

  int? get premiumDaysLeft {
    if (!hasActivePremium || premiumPlan == PremiumPlan.lifetime) return null;
    return premiumExpiresAt!.difference(DateTime.now()).inDays;
  }
  
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Méthodes de copie
  UserEntity copyWith({
    UserId? id,
    Email? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, bool>? notificationPreferences,
    bool? isPremium,
    PremiumPlan? premiumPlan,
    DateTime? premiumExpiresAt,
    bool? isTrial,
    DateTime? trialExpiresAt,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      isPremium: isPremium ?? this.isPremium,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      isTrial: isTrial ?? this.isTrial,
      trialExpiresAt: trialExpiresAt ?? this.trialExpiresAt,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
    );
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName, role, createdAt];

  @override
  String toString() {
    return 'UserEntity(id: ${id.value}, email: ${email.value}, fullName: $fullName, canEdit: $canEdit)';
  }
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