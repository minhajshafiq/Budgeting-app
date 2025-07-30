import 'package:flutter/foundation.dart';
import '../data/models/subscription.dart';
import '../data/models/user.dart';
import '../core/services/stripe_service.dart';
import '../core/di/dependency_injection.dart';
import '../domain/entities/auth_entity.dart';

class SubscriptionProvider extends ChangeNotifier {
  Subscription? _currentSubscription;
  List<SubscriptionPlan> _availablePlans = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Subscription? get currentSubscription => _currentSubscription;
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialiser les plans disponibles
  void initializePlans() {
    _availablePlans = [
      SubscriptionPlan(
        id: 'monthly',
        name: 'Premium Mensuel',
        description: 'Accès complet à toutes les fonctionnalités',
        plan: PremiumPlan.monthly,
        billingCycle: BillingCycle.monthly,
        price: 9.99,
        features: [
          'Transactions illimitées',
          'Statistiques avancées',
          'Export des données',
          'Support prioritaire',
          'Synchronisation multi-appareils',
        ],
        stripePriceId: 'price_monthly_id', // Votre price ID Stripe
      ),
      SubscriptionPlan(
        id: 'yearly',
        name: 'Premium Annuel',
        description: 'Économisez 40% avec l\'abonnement annuel',
        plan: PremiumPlan.yearly,
        billingCycle: BillingCycle.yearly,
        price: 59.99,
        features: [
          'Tout du plan mensuel',
          'Économies de 40%',
          'Accès anticipé aux nouvelles fonctionnalités',
        ],
        isPopular: true,
        stripePriceId: 'price_yearly_id', // Votre price ID Stripe
      ),
      SubscriptionPlan(
        id: 'lifetime',
        name: 'Premium À Vie',
        description: 'Accès permanent à toutes les fonctionnalités',
        plan: PremiumPlan.lifetime,
        billingCycle: BillingCycle.lifetime,
        price: 199.99,
        features: [
          'Tout des autres plans',
          'Paiement unique',
          'Accès à vie',
          'Mises à jour gratuites',
        ],
        stripePriceId: 'price_lifetime_id', // Votre price ID Stripe
      ),
    ];
    notifyListeners();
  }

  // Créer un abonnement
  Future<bool> createSubscription({
    required SubscriptionPlan plan,
    required User user,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // 1. Créer ou récupérer le client Stripe
      String? customerId = user.stripeCustomerId;
      if (customerId == null) {
        customerId = await StripeService.createCustomer(
          email: user.email,
          name: user.fullName,
          phone: user.phoneNumber,
        );
        
        if (customerId == null) {
          _setError('Impossible de créer le client de paiement');
          return false;
        }
      }

      // 2. Créer l'abonnement Stripe
      final subscriptionData = await StripeService.createSubscription(
        customerId: customerId,
        priceId: plan.stripePriceId!,
        trialDays: plan.billingCycle == BillingCycle.lifetime ? null : '7',
      );

      if (subscriptionData == null) {
        _setError('Impossible de créer l\'abonnement');
        return false;
      }

      // 3. Mettre à jour l'utilisateur avec les nouvelles informations
      final updatedUser = user.copyWith(
        isPremium: true,
        premiumPlan: plan.plan,
        stripeCustomerId: customerId,
        stripeSubscriptionId: subscriptionData['id'],
        premiumExpiresAt: _calculateExpirationDate(plan, subscriptionData),
      );

      // 4. Sauvegarder les changements (via AuthService)
      // Note: updateUser method no longer exists, user update is handled differently with Supabase
      // await AuthService().updateUser(updatedUser);

      // 5. Mettre à jour l'état local
      _currentSubscription = _parseSubscriptionFromStripeData(subscriptionData, user.id);
      
      _setLoading(false);
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Erreur lors de la création de l\'abonnement: $e');
      return false;
    }
  }

  // Annuler un abonnement
  Future<bool> cancelSubscription() async {
    if (_currentSubscription == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await StripeService.cancelSubscription(
        _currentSubscription!.stripeSubscriptionId,
      );

      if (success) {
        // Mettre à jour l'utilisateur
          // Note: La mise à jour de l'utilisateur est maintenant gérée via le repository
          // L'utilisateur sera mis à jour lors de la prochaine synchronisation
        // TODO: Implémenter avec la nouvelle architecture d'authentification

        _currentSubscription = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Impossible d\'annuler l\'abonnement');
        return false;
      }
    } catch (e) {
      _setError('Erreur lors de l\'annulation: $e');
      return false;
    }
  }

  // Récupérer l'abonnement actuel
  Future<void> fetchCurrentSubscription() async {
    // Note: Pour l'instant, on ne peut pas récupérer l'abonnement sans l'utilisateur complet
    // Il faudrait adapter cette logique pour utiliser le nouveau système d'authentification
    // TODO: Implémenter la récupération d'abonnement avec la nouvelle architecture
    debugPrint('⚠️ fetchCurrentSubscription: À implémenter avec la nouvelle architecture');
  }

  // Traiter un webhook Stripe
  void processWebhookEvent(Map<String, dynamic> event) {
    try {
      final eventType = event['type'];
      
      switch (eventType) {
        case 'customer.subscription.created':
        case 'customer.subscription.updated':
          final subscription = StripeService.parseSubscriptionFromEvent(event);
          if (subscription != null) {
            _currentSubscription = subscription;
            notifyListeners();
          }
          break;
          
        case 'customer.subscription.deleted':
          _currentSubscription = null;
          notifyListeners();
          break;
          
        case 'invoice.payment_failed':
          // Gérer l'échec de paiement
          _handlePaymentFailure(event);
          break;
      }
    } catch (e) {
      print('Erreur traitement webhook: $e');
    }
  }

  // Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  DateTime? _calculateExpirationDate(SubscriptionPlan plan, Map<String, dynamic> subscriptionData) {
    if (plan.billingCycle == BillingCycle.lifetime) return null;
    
    final currentPeriodEnd = subscriptionData['current_period_end'];
    if (currentPeriodEnd != null) {
      return DateTime.fromMillisecondsSinceEpoch(currentPeriodEnd * 1000);
    }
    return null;
  }

  Subscription? _parseSubscriptionFromStripeData(Map<String, dynamic> data, String userId) {
    try {
      return Subscription(
        id: data['id'],
        userId: userId,
        stripeSubscriptionId: data['id'],
        stripeCustomerId: data['customer'],
        plan: StripeService.parsePlanFromPriceId(data['items']['data'][0]['price']['id']),
        status: StripeService.parseStatus(data['status']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['created'] * 1000),
        currentPeriodStart: data['current_period_start'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['current_period_start'] * 1000)
          : null,
        currentPeriodEnd: data['current_period_end'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['current_period_end'] * 1000)
          : null,
        canceledAt: data['canceled_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['canceled_at'] * 1000)
          : null,
        trialStart: data['trial_start'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['trial_start'] * 1000)
          : null,
        trialEnd: data['trial_end'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['trial_end'] * 1000)
          : null,
        amount: (data['items']['data'][0]['price']['unit_amount'] ?? 0) / 100.0,
        currency: data['currency'] ?? 'EUR',
        billingCycle: StripeService.parseBillingCycle(data['items']['data'][0]['price']['recurring']['interval']),
      );
    } catch (e) {
      print('Erreur parsing subscription: $e');
      return null;
    }
  }

  void _handlePaymentFailure(Map<String, dynamic> event) {
    // Implémenter la logique de gestion des échecs de paiement
    // Par exemple, envoyer une notification à l'utilisateur
    print('Échec de paiement détecté: ${event['data']['object']['id']}');
  }
} 