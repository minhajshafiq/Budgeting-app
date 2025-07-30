import 'package:flutter/foundation.dart';
import '../../utils/user_provider.dart';
import '../../data/models/user.dart';
import 'secure_storage_service.dart';
import 'dart:convert';
import 'package:my_flutter_app/core/providers/auth_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../providers/transaction_provider.dart';

/// Service pour synchroniser les informations utilisateur entre AuthStateManager et UserProvider
class UserSessionSync {
  static final UserSessionSync _instance = UserSessionSync._internal();
  factory UserSessionSync() => _instance;
  UserSessionSync._internal();
  
  final SecureStorageService _secureStorage = SecureStorageService();
  static const String _notificationPrefsKey = 'notification_preferences';
  
  /// Synchroniser les informations utilisateur de AuthStateProvider vers UserProvider
  void syncUserInfo(AuthStateProvider authStateProvider, UserProvider userProvider) {
    final currentUser = authStateProvider.currentUser;
    if (currentUser != null) {
      userProvider.updateProfile(
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        email: currentUser.email.value,
      );
      debugPrint('Session utilisateur synchronisée: ${currentUser.fullName}');
    } else {
      userProvider.logout();
      debugPrint('Session utilisateur déconnectée');
    }
  }

  /// Synchroniser les informations utilisateur et initialiser les providers
  void syncUserInfoAndInitializeProviders(
    BuildContext context,
    AuthStateProvider authStateProvider,
    UserProvider userProvider,
  ) {
    final currentUser = authStateProvider.currentUser;
    if (currentUser != null) {
      // Synchroniser les informations utilisateur
      userProvider.updateProfile(
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        email: currentUser.email.value,
      );
      debugPrint('Session utilisateur synchronisée: ${currentUser.fullName}');
      
      // Initialiser le TransactionProvider avec l'ID utilisateur
      try {
        final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
        transactionProvider.initializeWithUser(currentUser.id.value);
        debugPrint('🔄 TransactionProvider initialisé avec l\'utilisateur: ${currentUser.id.value}');
        
        // Initialiser avec synchronisation intelligente (seulement si nécessaire)
        transactionProvider.initialize();
      } catch (e) {
        debugPrint('❌ Erreur lors de l\'initialisation du TransactionProvider: $e');
      }
    } else {
      userProvider.logout();
      debugPrint('Session utilisateur déconnectée');
    }
  }
  
  /// Mettre à jour les informations utilisateur dans les deux providers
  Future<bool> updateUserInfo({
    required UserProvider userProvider,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      // TODO: Implémenter la mise à jour du profil dans AuthStateManager si besoin
      // final success = await authProvider.updateProfile(...);
      // if (success) { ... }
      // Pour l'instant, on ne fait que mettre à jour le UserProvider
        userProvider.updateProfile(
          firstName: firstName ?? userProvider.firstName,
          lastName: lastName ?? userProvider.lastName,
          email: email ?? userProvider.email,
        );
        return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }
  
  /// Charger les préférences de notifications depuis le stockage sécurisé
  Future<Map<String, bool>> loadNotificationPreferences() async {
    try {
      final prefsJson = await _secureStorage.getSecureValue(_notificationPrefsKey);
      if (prefsJson != null) {
        final Map<String, dynamic> decodedPrefs = json.decode(prefsJson);
        return decodedPrefs.map((key, value) => MapEntry(key, value as bool));
      }
      
      // Préférences par défaut si aucune sauvegarde
      return {
        'budget_exceeded': true,
        'goal_achieved': true,
        'month_end': false,
        'unusual_debit': true,
        'weekly_summary': false,
        'monthly_report': true,
      };
    } catch (e) {
      debugPrint('Erreur lors du chargement des préférences de notification: $e');
      // Retourner les préférences par défaut en cas d'erreur
      return {
        'budget_exceeded': true,
        'goal_achieved': true,
        'month_end': false,
        'unusual_debit': true,
        'weekly_summary': false,
        'monthly_report': true,
      };
    }
  }
  
  /// Mettre à jour les préférences de notifications dans le stockage sécurisé
  Future<bool> updateNotificationPreferences({
    required UserProvider userProvider,
    required Map<String, bool> notificationPreferences,
  }) async {
    try {
      // Sauvegarder dans le stockage sécurisé
      final prefsJson = json.encode(notificationPreferences);
      await _secureStorage.saveSecureValue(_notificationPrefsKey, prefsJson);
      
      debugPrint('Préférences de notification sauvegardées: $notificationPreferences');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des préférences de notification: $e');
      return false;
    }
  }
  
  /// Supprimer les préférences de notification (lors de la déconnexion)
  Future<void> clearNotificationPreferences() async {
    try {
      await _secureStorage.deleteSecureValue(_notificationPrefsKey);
      debugPrint('Préférences de notification supprimées');
    } catch (e) {
      debugPrint('Erreur lors de la suppression des préférences de notification: $e');
    }
  }
} 