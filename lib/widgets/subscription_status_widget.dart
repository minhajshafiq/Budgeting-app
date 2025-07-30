import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../data/models/subscription.dart';
import '../data/models/user.dart';
import '../core/constants/constants.dart';

/// Widget qui affiche le statut d'abonnement de l'utilisateur
/// Ce widget est un exemple d'utilisation du SubscriptionProvider
class SubscriptionStatusWidget extends StatelessWidget {
  final bool showDetails;
  final bool showUpgradeButton;
  
  const SubscriptionStatusWidget({
    Key? key,
    this.showDetails = true,
    this.showUpgradeButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisation du Consumer pour accéder au SubscriptionProvider
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        // Récupération de l'abonnement actuel
        final subscription = subscriptionProvider.currentSubscription;
        
        // Si l'utilisateur n'a pas d'abonnement
        if (subscription == null) {
          return _buildNoSubscription(context);
        }
        
        // Si l'utilisateur a un abonnement
        return _buildSubscriptionInfo(context, subscription, subscriptionProvider);
      },
    );
  }

  // Widget affiché quand l'utilisateur n'a pas d'abonnement
  Widget _buildNoSubscription(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version gratuite',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous utilisez actuellement la version gratuite de l\'application.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (showUpgradeButton) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Afficher la modal d'abonnement
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildSubscriptionModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Passer à la version premium'),
            ),
          ],
        ],
      ),
    );
  }

  // Widget affiché quand l'utilisateur a un abonnement
  Widget _buildSubscriptionInfo(
    BuildContext context, 
    Subscription subscription,
    SubscriptionProvider provider
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = subscription.status == SubscriptionStatus.active;
    final isTrial = subscription.trialEnd != null && 
                   DateTime.now().isBefore(subscription.trialEnd!);
    
    // Déterminer le type d'abonnement pour l'affichage
    String planName;
    switch (subscription.plan) {
      case PremiumPlan.monthly:
        planName = 'Premium Mensuel';
        break;
      case PremiumPlan.yearly:
        planName = 'Premium Annuel';
        break;
      case PremiumPlan.lifetime:
        planName = 'Premium À Vie';
        break;
      default:
        planName = 'Premium';
    }
    
    // Ajouter l'indication d'essai si applicable
    if (isTrial) {
      planName += ' (Essai)';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                planName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 12),
            if (subscription.currentPeriodEnd != null && !isTrial) ...[
              Text(
                'Prochain renouvellement: ${_formatDate(subscription.currentPeriodEnd!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (isTrial) ...[
              Text(
                'Fin de la période d\'essai: ${_formatDate(subscription.trialEnd!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (subscription.status == SubscriptionStatus.canceled) ...[
              Text(
                'Abonnement annulé. Expire le: ${_formatDate(subscription.currentPeriodEnd!)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
          if (subscription.status == SubscriptionStatus.canceled && showUpgradeButton) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Afficher la modal d'abonnement pour réactiver
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildSubscriptionModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Réactiver l\'abonnement'),
            ),
          ],
        ],
      ),
    );
  }

  // Formater une date pour l'affichage
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Construire la modal d'abonnement
  Widget _buildSubscriptionModal() {
    // Importer et utiliser votre modal d'abonnement existante
    // Ceci est juste un placeholder
    return Container(
      height: 500,
      color: Colors.white,
      child: const Center(
        child: Text('Modal d\'abonnement'),
      ),
    );
  }
} 