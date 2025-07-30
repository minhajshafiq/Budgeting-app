import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';
import '../../../../../core/widgets/animated_text_field.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../widgets/modern_animations.dart';

class Step1PersonalInfo extends StatelessWidget {
  const Step1PersonalInfo({super.key});

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
                'Informations personnelles',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Commençons par vos informations de base',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Champs de saisie
              Column(
                children: [
                  // Champs prénom et nom
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedTextField(
                          controller: dataManager.firstNameController,
                          label: 'Prénom',
                          icon: Icons.person_outline,
                          errorText: dataManager.firstNameError,
                          onChanged: (value) {
                            if (dataManager.firstNameError != null) {
                              dataManager.firstNameError = null;
                              dataManager.notifyListeners();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedTextField(
                          controller: dataManager.lastNameController,
                          label: 'Nom',
                          icon: Icons.person_outline,
                          errorText: dataManager.lastNameError,
                          onChanged: (value) {
                            if (dataManager.lastNameError != null) {
                              dataManager.lastNameError = null;
                              dataManager.notifyListeners();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Informations supplémentaires avec design moderne
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.05),
                      const Color(0xFF8B5CF6).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personnalisation',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ces informations nous aident à personnaliser votre expérience et à vous appeler par votre prénom.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
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
} 