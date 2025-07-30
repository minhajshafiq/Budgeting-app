import '../../domain/entities/transaction_entity.dart';
import '../models/transaction.dart' as data_models;
import '../models/pocket.dart' as data_pocket;
import '../../domain/entities/user_entity.dart';
import '../models/user.dart' as data_user;

class TransactionEntityMapper {
  // Domain -> Data
  static data_models.Transaction toData(TransactionEntity entity) {
    return data_models.Transaction(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      categoryId: entity.categoryId,
      type: _toTransactionType(entity.type),
      description: entity.description,
      recurrence: _toRecurrenceType(entity.recurrence),
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Data -> Domain
  static TransactionEntity toEntity(data_models.Transaction model) {
    return TransactionEntity(
      id: model.id,
      title: model.title,
      amount: model.amount,
      date: model.date,
      categoryId: model.categoryId,
      type: model.type,
      description: model.description,
      recurrence: model.recurrence,
      imageUrl: model.imageUrl,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static data_models.TransactionType _toTransactionType(dynamic type) {
    if (type is data_models.TransactionType) return type;
    if (type is String) {
      return data_models.TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => data_models.TransactionType.expense,
      );
    }
    return data_models.TransactionType.expense;
  }

  static data_models.RecurrenceType _toRecurrenceType(dynamic recurrence) {
    if (recurrence is data_models.RecurrenceType) return recurrence;
    if (recurrence is String) {
      return data_models.RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == recurrence,
        orElse: () => data_models.RecurrenceType.none,
      );
    }
    return data_models.RecurrenceType.none;
  }

  // --- PocketEntity <-> Pocket ---
  static data_pocket.Pocket toDataPocket(dynamic entity) {
    // entity: PocketEntity (à adapter selon votre structure)
    return data_pocket.Pocket(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      budget: entity.budget,
      spent: entity.spent,
      transactions: entity.transactions ?? const [],
      createdAt: entity.createdAt,
      type: entity.type,
      savingsGoalType: entity.savingsGoalType,
      targetAmount: entity.targetAmount,
      targetDate: entity.targetDate,
    );
  }

  static dynamic toPocketEntity(data_pocket.Pocket model) {
    // Retourner un PocketEntity (à adapter selon votre structure)
    return {
      'id': model.id,
      'name': model.name,
      'icon': model.icon,
      'color': model.color,
      'budget': model.budget,
      'spent': model.spent,
      'transactions': model.transactions,
      'createdAt': model.createdAt,
      'type': model.type,
      'savingsGoalType': model.savingsGoalType,
      'targetAmount': model.targetAmount,
      'targetDate': model.targetDate,
    };
  }

  // --- UserEntity <-> User ---
  static data_user.User toDataUser(UserEntity entity) {
    return data_user.User(
      id: entity.id.value,
      email: entity.email.value,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      dateOfBirth: entity.dateOfBirth,
      profileImageUrl: entity.profileImageUrl,
      role: _toUserRole(entity.role),
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isEmailVerified: entity.isEmailVerified,
      isPhoneVerified: entity.isPhoneVerified,
      notificationPreferences: entity.notificationPreferences,
      isPremium: entity.isPremium,
      premiumPlan: _toPremiumPlan(entity.premiumPlan),
      premiumExpiresAt: entity.premiumExpiresAt,
      isTrial: entity.isTrial,
      trialExpiresAt: entity.trialExpiresAt,
      stripeCustomerId: entity.stripeCustomerId,
      stripeSubscriptionId: entity.stripeSubscriptionId,
    );
  }

  static UserEntity toUserEntity(dynamic model) {
    // Accepte UserModel ou User
    return UserEntity(
      id: UserId(model.id),
      email: Email(model.email),
      firstName: model.firstName,
      lastName: model.lastName,
      phoneNumber: model.phoneNumber,
      dateOfBirth: model.dateOfBirth,
      profileImageUrl: model.profileImageUrl,
      role: _fromUserRole(model.role),
      createdAt: model.createdAt,
      lastLoginAt: model.lastLoginAt,
      isEmailVerified: model.isEmailVerified,
      isPhoneVerified: model.isPhoneVerified,
      notificationPreferences: model.notificationPreferences,
      isPremium: model.isPremium,
      premiumPlan: _fromPremiumPlan(model.premiumPlan),
      premiumExpiresAt: model.premiumExpiresAt,
      isTrial: model.isTrial,
      trialExpiresAt: model.trialExpiresAt,
      stripeCustomerId: model.stripeCustomerId,
      stripeSubscriptionId: model.stripeSubscriptionId,
    );
  }

  static data_user.UserRole _toUserRole(dynamic role) {
    if (role is data_user.UserRole) return role;
    if (role is String) {
      return data_user.UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == role,
        orElse: () => data_user.UserRole.user,
      );
    }
    return data_user.UserRole.user;
  }

  static dynamic _fromUserRole(data_user.UserRole role) {
    // Adapter selon vos besoins
    switch (role) {
      case data_user.UserRole.user:
        return UserRole.user;
      case data_user.UserRole.premium:
        return UserRole.premium;
      case data_user.UserRole.admin:
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  static data_user.PremiumPlan? _toPremiumPlan(dynamic plan) {
    if (plan == null) return null;
    if (plan is data_user.PremiumPlan) return plan;
    if (plan is String) {
      return data_user.PremiumPlan.values.firstWhere(
        (e) => e.toString().split('.').last == plan,
        orElse: () => data_user.PremiumPlan.monthly,
      );
    }
    return data_user.PremiumPlan.monthly;
  }

  static PremiumPlan? _fromPremiumPlan(dynamic plan) {
    if (plan == null) return null;
    if (plan is PremiumPlan) return plan;
    if (plan is String) {
      return PremiumPlan.values.firstWhere(
        (e) => e.toString().split('.').last == plan,
        orElse: () => PremiumPlan.monthly,
      );
    }
    return PremiumPlan.monthly;
  }
} 