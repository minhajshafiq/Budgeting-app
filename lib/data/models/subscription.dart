import 'user.dart';

enum SubscriptionStatus { active, canceled, past_due, unpaid, trialing }
enum BillingCycle { monthly, yearly, lifetime }

class Subscription {
  final String id;
  final String userId;
  final String stripeSubscriptionId;
  final String stripeCustomerId;
  final PremiumPlan plan;
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? canceledAt;
  final DateTime? trialStart;
  final DateTime? trialEnd;
  final double amount;
  final String currency;
  final BillingCycle billingCycle;

  Subscription({
    required this.id,
    required this.userId,
    required this.stripeSubscriptionId,
    required this.stripeCustomerId,
    required this.plan,
    required this.status,
    required this.createdAt,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.canceledAt,
    this.trialStart,
    this.trialEnd,
    required this.amount,
    this.currency = 'EUR',
    required this.billingCycle,
  });

  // Getters utiles
  bool get isActive => status == SubscriptionStatus.active || status == SubscriptionStatus.trialing;
  bool get isTrialing => status == SubscriptionStatus.trialing;
  bool get isCanceled => status == SubscriptionStatus.canceled;
  bool get isPastDue => status == SubscriptionStatus.past_due;
  bool get isUnpaid => status == SubscriptionStatus.unpaid;

  // Getter pour déterminer si l'abonnement est en période d'essai
  bool get hasActiveTrial {
    if (trialStart == null || trialEnd == null) return false;
    final now = DateTime.now();
    return now.isAfter(trialStart!) && now.isBefore(trialEnd!);
  }

  // Getter pour obtenir le nombre de jours restants dans l'essai
  int? get trialDaysLeft {
    if (!hasActiveTrial) return null;
    return trialEnd!.difference(DateTime.now()).inDays;
  }

  // Getter pour obtenir le nombre de jours restants dans la période actuelle
  int? get periodDaysLeft {
    if (currentPeriodEnd == null) return null;
    return currentPeriodEnd!.difference(DateTime.now()).inDays;
  }

  // Méthodes de copie
  Subscription copyWith({
    String? id,
    String? userId,
    String? stripeSubscriptionId,
    String? stripeCustomerId,
    PremiumPlan? plan,
    SubscriptionStatus? status,
    DateTime? createdAt,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? canceledAt,
    DateTime? trialStart,
    DateTime? trialEnd,
    double? amount,
    String? currency,
    BillingCycle? billingCycle,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      canceledAt: canceledAt ?? this.canceledAt,
      trialStart: trialStart ?? this.trialStart,
      trialEnd: trialEnd ?? this.trialEnd,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
    );
  }

  // Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stripeSubscriptionId': stripeSubscriptionId,
      'stripeCustomerId': stripeCustomerId,
      'plan': plan.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'currentPeriodStart': currentPeriodStart?.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'trialStart': trialStart?.toIso8601String(),
      'trialEnd': trialEnd?.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'billingCycle': billingCycle.toString().split('.').last,
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

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      stripeSubscriptionId: json['stripeSubscriptionId'],
      stripeCustomerId: json['stripeCustomerId'],
      plan: PremiumPlan.values.firstWhere(
        (e) => e.toString().split('.').last == json['plan'],
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      currentPeriodStart: _parseDateTime(json['currentPeriodStart']),
      currentPeriodEnd: _parseDateTime(json['currentPeriodEnd']),
      canceledAt: _parseDateTime(json['canceledAt']),
      trialStart: _parseDateTime(json['trialStart']),
      trialEnd: _parseDateTime(json['trialEnd']),
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'EUR',
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.toString().split('.').last == json['billingCycle'],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Subscription(id: $id, plan: $plan, status: $status, isActive: $isActive)';
  }
}

// Modèle pour les plans d'abonnement
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final PremiumPlan plan;
  final BillingCycle billingCycle;
  final double price;
  final String currency;
  final List<String> features;
  final bool isPopular;
  final String? stripePriceId;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.plan,
    required this.billingCycle,
    required this.price,
    this.currency = 'EUR',
    required this.features,
    this.isPopular = false,
    this.stripePriceId,
  });

  // Getter pour le prix formaté
  String get formattedPrice {
    return '${price.toStringAsFixed(2)}€';
  }

  // Getter pour la période de facturation
  String get billingPeriod {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return '/mois';
      case BillingCycle.yearly:
        return '/an';
      case BillingCycle.lifetime:
        return 'à vie';
    }
  }

  // Getter pour le prix par mois (pour comparaison)
  double get monthlyPrice {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return price;
      case BillingCycle.yearly:
        return price / 12;
      case BillingCycle.lifetime:
        return 0; // Pas de prix mensuel pour l'abonnement à vie
    }
  }

  // Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'plan': plan.toString().split('.').last,
      'billingCycle': billingCycle.toString().split('.').last,
      'price': price,
      'currency': currency,
      'features': features,
      'isPopular': isPopular,
      'stripePriceId': stripePriceId,
    };
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      plan: PremiumPlan.values.firstWhere(
        (e) => e.toString().split('.').last == json['plan'],
      ),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.toString().split('.').last == json['billingCycle'],
      ),
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'EUR',
      features: List<String>.from(json['features']),
      isPopular: json['isPopular'] ?? false,
      stripePriceId: json['stripePriceId'],
    );
  }
} 