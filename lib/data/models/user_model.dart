import '../../domain/entities/user_entity.dart';

// Enums pour la sérialisation (doivent correspondre aux enums du domaine)
enum UserRoleModel { user, premium, admin }
enum AuthStatusModel { authenticated, unauthenticated, loading }
enum PremiumPlanModel { monthly, yearly, lifetime }

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? profileImageUrl;
  final UserRoleModel role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final Map<String, bool> notificationPreferences;
  
  // Propriétés premium
  final bool isPremium;
  final PremiumPlanModel? premiumPlan;
  final DateTime? premiumExpiresAt;
  final bool isTrial;
  final DateTime? trialExpiresAt;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;

  UserModel({
    String? id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    DateTime? dateOfBirth,
    this.profileImageUrl,
    this.role = UserRoleModel.user,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    Map<String, bool>? notificationPreferences,
    this.isPremium = false,
    this.premiumPlan,
    DateTime? premiumExpiresAt,
    this.isTrial = false,
    DateTime? trialExpiresAt,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
  })  : id = id ?? _generateUserId(),
        dateOfBirth = _parseDateTime(dateOfBirth),
        createdAt = _parseDateTime(createdAt) ?? DateTime.now(),
        lastLoginAt = _parseDateTime(lastLoginAt),
        premiumExpiresAt = _parseDateTime(premiumExpiresAt),
        notificationPreferences = notificationPreferences ?? _defaultNotificationPreferences(),
        trialExpiresAt = _parseDateTime(trialExpiresAt) ?? (_shouldBeInTrial(_parseDateTime(createdAt) ?? DateTime.now()) 
          ? _calculateTrialExpiration(_parseDateTime(createdAt) ?? DateTime.now()) 
          : null);

  // Générateur d'ID utilisateur
  static String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  // Détermine si l'utilisateur devrait être en période d'essai
  static bool _shouldBeInTrial(DateTime createdAt) {
    final now = DateTime.now();
    final trialDuration = Duration(days: 30);
    return now.isBefore(createdAt.add(trialDuration));
  }

  // Calcule la date d'expiration de l'essai gratuit
  static DateTime _calculateTrialExpiration(DateTime createdAt) {
    return createdAt.add(const Duration(days: 30));
  }

  // Préférences de notification par défaut
  static Map<String, bool> _defaultNotificationPreferences() {
    return {
      'budget_exceeded': true,
      'goal_achieved': true,
      'month_end': true,
      'unusual_debit': true,
      'transaction_added': false,
      'weekly_summary': true,
      'monthly_report': true,
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

  // Méthodes de conversion des enums
  static UserRole _convertRole(UserRoleModel role) {
    switch (role) {
      case UserRoleModel.user:
        return UserRole.user;
      case UserRoleModel.premium:
        return UserRole.premium;
      case UserRoleModel.admin:
        return UserRole.admin;
    }
  }

  static UserRoleModel _convertRoleToModel(UserRole role) {
    switch (role) {
      case UserRole.user:
        return UserRoleModel.user;
      case UserRole.premium:
        return UserRoleModel.premium;
      case UserRole.admin:
        return UserRoleModel.admin;
    }
  }

  static PremiumPlan _convertPremiumPlan(PremiumPlanModel plan) {
    switch (plan) {
      case PremiumPlanModel.monthly:
        return PremiumPlan.monthly;
      case PremiumPlanModel.yearly:
        return PremiumPlan.yearly;
      case PremiumPlanModel.lifetime:
        return PremiumPlan.lifetime;
    }
  }

  static PremiumPlanModel _convertPremiumPlanToModel(PremiumPlan plan) {
    switch (plan) {
      case PremiumPlan.monthly:
        return PremiumPlanModel.monthly;
      case PremiumPlan.yearly:
        return PremiumPlanModel.yearly;
      case PremiumPlan.lifetime:
        return PremiumPlanModel.lifetime;
    }
  }

  // Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'notificationPreferences': notificationPreferences,
      'isPremium': isPremium,
      'premiumPlan': premiumPlan?.toString().split('.').last,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'isTrial': isTrial,
      'trialExpiresAt': trialExpiresAt?.toIso8601String(),
      'stripeCustomerId': stripeCustomerId,
      'stripeSubscriptionId': stripeSubscriptionId,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      dateOfBirth: _parseDateTime(json['dateOfBirth']),
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] != null
        ? UserRoleModel.values.firstWhere(
            (e) => e.toString().split('.').last == json['role'],
            orElse: () => UserRoleModel.user,
          )
        : UserRoleModel.user,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      notificationPreferences: Map<String, bool>.from(
        json['notificationPreferences'] ?? _defaultNotificationPreferences()
      ),
      isPremium: json['isPremium'] ?? false,
      premiumPlan: json['premiumPlan'] != null 
        ? PremiumPlanModel.values.firstWhere(
            (e) => e.toString().split('.').last == json['premiumPlan'],
            orElse: () => PremiumPlanModel.monthly,
          )
        : null,
      premiumExpiresAt: _parseDateTime(json['premiumExpiresAt']),
      isTrial: json['isTrial'] ?? false,
      trialExpiresAt: _parseDateTime(json['trialExpiresAt']),
      stripeCustomerId: json['stripeCustomerId'],
      stripeSubscriptionId: json['stripeSubscriptionId'],
    );
  }

  // Méthodes de copie
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    UserRoleModel? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, bool>? notificationPreferences,
    bool? isPremium,
    PremiumPlanModel? premiumPlan,
    DateTime? premiumExpiresAt,
    bool? isTrial,
    DateTime? trialExpiresAt,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
  }) {
    return UserModel(
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName)';
  }
}

// Classes pour les données d'authentification (Data Layer)
class SignupDataModel {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final Map<String, bool> notificationPreferences;

  SignupDataModel({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    Map<String, bool>? notificationPreferences,
  }) : notificationPreferences = notificationPreferences ?? UserModel._defaultNotificationPreferences();

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'notificationPreferences': notificationPreferences,
    };
  }
}

class LoginDataModel {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginDataModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}

class AuthResultModel {
  final bool success;
  final UserModel? user;
  final String? error;
  final String? token;

  const AuthResultModel({
    required this.success,
    this.user,
    this.error,
    this.token,
  });

  factory AuthResultModel.success(UserModel user, {String? token}) {
    return AuthResultModel(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResultModel.failure(String error) {
    return AuthResultModel(
      success: false,
      error: error,
    );
  }
} 