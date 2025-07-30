import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';
import '../../../../../core/widgets/animated_text_field.dart';
import '../../../../../widgets/modern_animations.dart';

class Step2Email extends StatelessWidget {
  const Step2Email({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupDataManager>(
      builder: (context, dataManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Titre de l'étape
              Text(
                'Adresse email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Nous utiliserons cette adresse pour vous connecter et vous envoyer des notifications importantes',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Champ email
              AnimatedTextField(
                controller: dataManager.emailController,
                label: 'Adresse email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                errorText: dataManager.emailError,
                onChanged: (value) {
                  if (dataManager.emailError != null) {
                    dataManager.emailError = null;
                    dataManager.notifyListeners();
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              // Informations sur l'email avec design moderne
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.05),
                      const Color(0xFF059669).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.security_outlined,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sécurité et confidentialité',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Votre email est protégé et ne sera jamais partagé',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Liste des avantages
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.shield_outlined,
                      text: 'Votre email ne sera jamais partagé avec des tiers',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.notifications_outlined,
                      text: 'Vous recevrez des notifications importantes',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.lock_reset_outlined,
                      text: 'Vous pourrez réinitialiser votre mot de passe si nécessaire',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF10B981),
          size: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
} 