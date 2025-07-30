import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/subscription.dart';
import '../data/models/user.dart';
import '../utils/constants.dart';

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static const String _secretKey = 'sk_test_...'; // Votre clé secrète Stripe
  static const String _publishableKey = 'pk_test_...'; // Votre clé publique Stripe

  // Headers pour les requêtes Stripe
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_secretKey',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  // Créer un client Stripe
  static Future<String?> createCustomer({
    required String email,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: _headers,
        body: {
          'email': email,
          'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        print('Erreur création client Stripe: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception création client Stripe: $e');
      return null;
    }
  }

  // Créer un abonnement
  static Future<Map<String, dynamic>?> createSubscription({
    required String customerId,
    required String priceId,
    String? trialDays,
  }) async {
    try {
      final body = {
        'customer': customerId,
        'items[0][price]': priceId,
        'payment_behavior': 'default_incomplete',
        'payment_settings[payment_method_types][]': 'card',
        'expand[]': 'latest_invoice.payment_intent',
      };

      if (trialDays != null) {
        body['trial_period_days'] = trialDays;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Erreur création abonnement Stripe: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception création abonnement Stripe: $e');
      return null;
    }
  }

  // Récupérer un abonnement
  static Future<Map<String, dynamic>?> getSubscription(String subscriptionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Erreur récupération abonnement Stripe: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception récupération abonnement Stripe: $e');
      return null;
    }
  }

  // Annuler un abonnement
  static Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Exception annulation abonnement Stripe: $e');
      return false;
    }
  }

  // Créer un PaymentIntent pour les paiements ponctuels
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: _headers,
        body: {
          'amount': (amount * 100).round().toString(), // Stripe utilise les centimes
          'currency': currency.toLowerCase(),
          'customer': customerId,
          if (description != null) 'description': description,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Erreur création PaymentIntent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception création PaymentIntent: $e');
      return null;
    }
  }

  // Récupérer les méthodes de paiement d'un client
  static Future<List<Map<String, dynamic>>> getPaymentMethods(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers/$customerId/payment_methods'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        print('Erreur récupération méthodes de paiement: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception récupération méthodes de paiement: $e');
      return [];
    }
  }

  // Supprimer une méthode de paiement
  static Future<bool> detachPaymentMethod(String paymentMethodId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods/$paymentMethodId/detach'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Exception suppression méthode de paiement: $e');
      return false;
    }
  }

  // Webhook pour traiter les événements Stripe
  static Map<String, dynamic>? processWebhook(String payload, String signature) {
    try {
      // Vérifier la signature du webhook (à implémenter selon votre backend)
      // Pour l'instant, on parse simplement le payload
      return json.decode(payload);
    } catch (e) {
      print('Exception traitement webhook: $e');
      return null;
    }
  }

  // Convertir un événement Stripe en objet Subscription
  static Subscription? parseSubscriptionFromEvent(Map<String, dynamic> event) {
    try {
      final subscriptionData = event['data']['object'];
      
      return Subscription(
        id: subscriptionData['id'],
        userId: subscriptionData['metadata']['user_id'] ?? '',
        stripeSubscriptionId: subscriptionData['id'],
        stripeCustomerId: subscriptionData['customer'],
        plan: parsePlanFromPriceId(subscriptionData['items']['data'][0]['price']['id']),
        status: parseStatus(subscriptionData['status']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(subscriptionData['created'] * 1000),
        currentPeriodStart: subscriptionData['current_period_start'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(subscriptionData['current_period_start'] * 1000)
          : null,
        currentPeriodEnd: subscriptionData['current_period_end'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(subscriptionData['current_period_end'] * 1000)
          : null,
        canceledAt: subscriptionData['canceled_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(subscriptionData['canceled_at'] * 1000)
          : null,
        trialStart: subscriptionData['trial_start'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(subscriptionData['trial_start'] * 1000)
          : null,
        trialEnd: subscriptionData['trial_end'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(subscriptionData['trial_end'] * 1000)
          : null,
        amount: (subscriptionData['items']['data'][0]['price']['unit_amount'] ?? 0) / 100.0,
        currency: subscriptionData['currency'] ?? 'EUR',
        billingCycle: parseBillingCycle(subscriptionData['items']['data'][0]['price']['recurring']['interval']),
      );
    } catch (e) {
      print('Exception parsing subscription from event: $e');
      return null;
    }
  }

  // Méthodes utilitaires publiques
  static PremiumPlan parsePlanFromPriceId(String priceId) {
    // Mapper vos price IDs Stripe vers les plans
    if (priceId.contains('monthly')) return PremiumPlan.monthly;
    if (priceId.contains('yearly')) return PremiumPlan.yearly;
    if (priceId.contains('lifetime')) return PremiumPlan.lifetime;
    return PremiumPlan.monthly; // Par défaut
  }

  static SubscriptionStatus parseStatus(String status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'past_due':
        return SubscriptionStatus.past_due;
      case 'unpaid':
        return SubscriptionStatus.unpaid;
      case 'trialing':
        return SubscriptionStatus.trialing;
      default:
        return SubscriptionStatus.active;
    }
  }

  static BillingCycle parseBillingCycle(String interval) {
    switch (interval) {
      case 'month':
        return BillingCycle.monthly;
      case 'year':
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }
} 