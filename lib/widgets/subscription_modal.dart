import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/models/subscription.dart';
import '../data/models/user.dart';
import '../providers/subscription_provider.dart';
import '../core/constants/constants.dart';
import 'modern_animations.dart';
import 'package:hugeicons/hugeicons.dart';

class SubscriptionModal extends StatefulWidget {
  final VoidCallback? onSubscriptionComplete;

  const SubscriptionModal({
    Key? key,
    this.onSubscriptionComplete,
  }) : super(key: key);

  @override
  State<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends State<SubscriptionModal> with SingleTickerProviderStateMixin {
  SubscriptionPlan? _selectedPlan;
  bool _isProcessing = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.longDuration,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
      if (provider.availablePlans.isEmpty) {
        provider.initializePlans();
      }
      if (provider.availablePlans.isNotEmpty) {
        setState(() {
    _selectedPlan = provider.availablePlans.firstWhere(
      (plan) => (plan as SubscriptionPlan).isPopular,
      orElse: () => provider.availablePlans.first,
    );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plans = context.watch<SubscriptionProvider>().availablePlans;
    
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -8),
          ),
        ],
      ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.zero,
      child: Column(
                mainAxisSize: MainAxisSize.min,
        children: [
                  // Drag bar
          Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 8),
                    width: 60,
            height: 6,
            decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
            ),
          ),
                  // Animated Icon
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: AnimatedScale(
                      scale: 1.1,
                      duration: AppAnimations.longDuration,
                      curve: Curves.elasticOut,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                  // Title & Subtitle
                  Text(
                    'Passer au Premium',
                    style: AppTextStyles.title(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Débloquez toutes les fonctionnalités et gérez vos finances sans limites',
                    style: AppTextStyles.header(context).copyWith(
                      color: AppColors.getSecondaryTextColor(context),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Plans (3 cards, pas de scroll)
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...plans.map((plan) {
                            final subscriptionPlan = plan as SubscriptionPlan;
                            final isSelected = _selectedPlan?.id == subscriptionPlan.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPlan = subscriptionPlan),
                              child: AnimatedContainer(
                                duration: AppAnimations.defaultDuration,
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.10)
                                      : AppColors.getSurfaceColor(context),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.getBorderColor(context),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.12),
                                            blurRadius: 18,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Radio
                                    AnimatedContainer(
                                      duration: AppAnimations.defaultDuration,
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 12, top: 2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : AppColors.getBorderColor(context),
                                          width: 2,
                                        ),
                                        color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    // Infos
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                subscriptionPlan.name,
                                                style: AppTextStyles.subtitle(context).copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.getTextColor(context),
                                                ),
                                              ),
                                              if (subscriptionPlan.isPopular)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'POPULAIRE',
                                                    style: AppTextStyles.header(context).copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            subscriptionPlan.description,
                                            style: AppTextStyles.header(context).copyWith(
                                              color: AppColors.getSecondaryTextColor(context),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                '${subscriptionPlan.price.toStringAsFixed(2)} €',
                                                style: AppTextStyles.amountSmall(context).copyWith(
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              Text(
                                                subscriptionPlan.billingCycle == BillingCycle.monthly
                                                    ? '/mois'
                                                    : subscriptionPlan.billingCycle == BillingCycle.yearly
                                                        ? '/an'
                                                        : '',
                                                style: AppTextStyles.header(context),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 2,
                                            children: subscriptionPlan.features
                                                .take(3)
                                                .map((feature) => Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.check_circle, color: AppColors.green, size: 14),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          feature,
                                                          style: AppTextStyles.header(context).copyWith(
                                                            color: AppColors.getTextColor(context),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ))
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Bouton sticky
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_selectedPlan != null && !_isProcessing) ? _handleSubscribe : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _selectedPlan != null
                                    ? 'Souscrire à ${_selectedPlan!.name}'
                                    : 'Choisir un plan',
                                style: AppTextStyles.subtitle(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Legal info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'En souscrivant, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.\nVous pouvez annuler votre abonnement à tout moment.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.header(context).copyWith(
                        fontSize: 11,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    if (_selectedPlan == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: Implement subscription logic with real user
      // For now, we'll simulate a subscription process
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSubscriptionComplete?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abonnement ${_selectedPlan!.name} activé avec succès!'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de la souscription. Veuillez réessayer.'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
} 