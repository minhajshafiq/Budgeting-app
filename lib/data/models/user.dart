enum UserRole { user, premium, admin }
enum AuthStatus { authenticated, unauthenticated, loading }
enum PremiumPlan { monthly, yearly, lifetime }

class User {
  final String id;
  final String email;
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
  
  // Propriétés freemium
  final bool isPremium;
  final PremiumPlan? premiumPlan;
  final DateTime? premiumExpiresAt;
  final bool isTrial;
  final DateTime? trialExpiresAt;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;

  User({
    String? id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    DateTime? dateOfBirth,
    this.profileImageUrl,
    this.role = UserRole.user,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    Map<String, bool>? notificationPreferences,
    // Propriétés freemium
    bool? isPremium,
    this.premiumPlan,
    DateTime? premiumExpiresAt,
    bool? isTrial,
    DateTime? trialExpiresAt,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
  })  : id = id ?? _generateUserId(),
        dateOfBirth = _parseDateTime(dateOfBirth),
        createdAt = _parseDateTime(createdAt) ?? DateTime.now(),
        lastLoginAt = _parseDateTime(lastLoginAt),
        premiumExpiresAt = _parseDateTime(premiumExpiresAt),
        notificationPreferences = notificationPreferences ?? _defaultNotificationPreferences(),
        // Initialisation des propriétés freemium
        isPremium = isPremium ?? (role == UserRole.premium || role == UserRole.admin),
        isTrial = isTrial ?? _shouldBeInTrial(_parseDateTime(createdAt) ?? DateTime.now()),
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

  // Getters utiles
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  bool get isAdmin => role == UserRole.admin;
  
  // Getter pour déterminer si l'utilisateur peut éditer
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

  // Getter pour déterminer si l'abonnement premium est actif
  bool get hasActivePremium {
    if (!isPremium || premiumPlan == null) return false;
    if (premiumPlan == PremiumPlan.lifetime) return true;
    return premiumExpiresAt != null && premiumExpiresAt!.isAfter(DateTime.now());
  }

  // Getter pour déterminer si l'utilisateur est en période d'essai active
  bool get hasActiveTrial {
    return isTrial && trialExpiresAt != null && trialExpiresAt!.isAfter(DateTime.now());
  }

  // Getter pour obtenir le statut d'abonnement
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

  // Getter pour obtenir le nombre de jours restants dans l'essai
  int? get trialDaysLeft {
    if (!hasActiveTrial) return null;
    return trialExpiresAt!.difference(DateTime.now()).inDays;
  }

  // Getter pour obtenir le nombre de jours restants dans l'abonnement premium
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
  User copyWith({
    String? id,
    String? email,
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
    // Propriétés freemium
    bool? isPremium,
    PremiumPlan? premiumPlan,
    DateTime? premiumExpiresAt,
    bool? isTrial,
    DateTime? trialExpiresAt,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
  }) {
    return User(
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
      // Propriétés freemium
      isPremium: isPremium ?? this.isPremium,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      isTrial: isTrial ?? this.isTrial,
      trialExpiresAt: trialExpiresAt ?? this.trialExpiresAt,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
    );
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
      // Propriétés freemium
      'isPremium': isPremium,
      'premiumPlan': premiumPlan?.toString().split('.').last,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'isTrial': isTrial,
      'trialExpiresAt': trialExpiresAt?.toIso8601String(),
      'stripeCustomerId': stripeCustomerId,
      'stripeSubscriptionId': stripeSubscriptionId,
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      dateOfBirth: _parseDateTime(json['dateOfBirth']),
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] != null
        ? UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == json['role'],
            orElse: () => UserRole.user,
          )
        : UserRole.user,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      notificationPreferences: Map<String, bool>.from(
        json['notificationPreferences'] ?? _defaultNotificationPreferences()
      ),
      // Propriétés freemium
      isPremium: json['isPremium'] ?? false,
      premiumPlan: json['premiumPlan'] != null 
        ? PremiumPlan.values.firstWhere(
            (e) => e.toString().split('.').last == json['premiumPlan'],
            orElse: () => PremiumPlan.monthly,
          )
        : null,
      premiumExpiresAt: _parseDateTime(json['premiumExpiresAt']),
      isTrial: json['isTrial'] ?? false,
      trialExpiresAt: _parseDateTime(json['trialExpiresAt']),
      stripeCustomerId: json['stripeCustomerId'],
      stripeSubscriptionId: json['stripeSubscriptionId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, canEdit: $canEdit)';
  }
}

// Classe pour les données d'inscription
class SignupData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final Set<String> incomeTypes;
  final String? financialGoal;
  final String? comfortLevel;
  final Map<String, bool> notificationPreferences;
  final String? trackingFrequency;

  SignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.dateOfBirth,
    required this.incomeTypes,
    this.financialGoal,
    this.comfortLevel,
    Map<String, bool>? notificationPreferences,
    this.trackingFrequency,
  }) : notificationPreferences = notificationPreferences ?? {
    'budget_exceeded': true,
    'goal_achieved': true,
    'month_end': true,
    'unusual_debit': true,
  };

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'incomeTypes': incomeTypes,
      'financialGoal': financialGoal,
      'comfortLevel': comfortLevel,
      'notificationPreferences': notificationPreferences,
      'trackingFrequency': trackingFrequency,
    };
  }
}

// Classe pour les données de connexion
class LoginData {
  final String email;
  final String password;

  LoginData({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Résultat d'authentification
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? token;

  AuthResult._({
    required this.success,
    this.user,
    this.error,
    this.token,
  });

  factory AuthResult.success(User user, {String? token}) {
    return AuthResult._(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}

// Alias pour User pour éviter les conflits
typedef AppUser = User; 