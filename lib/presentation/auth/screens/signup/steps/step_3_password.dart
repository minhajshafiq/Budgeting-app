import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';
import '../../../../../core/widgets/animated_text_field.dart';
import 'package:hugeicons/hugeicons.dart';

class Step3Password extends StatefulWidget {
  const Step3Password({super.key});

  @override
  State<Step3Password> createState() => _Step3PasswordState();
}

class _Step3PasswordState extends State<Step3Password> {
  bool _obscurePassword = true;
  final _scrollController = ScrollController();
  final _fieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupDataManager>(
      builder: (context, dataManager, child) {
        final password = dataManager.passwordController.text;
        
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Titre de l'étape
              Text(
                'Créer un mot de passe sécurisé',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Choisissez un mot de passe fort pour protéger votre compte',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Champ mot de passe
              AnimatedTextField(
                key: _fieldKey,
                controller: dataManager.passwordController,
                label: 'Mot de passe',
                icon: Icons.lock_outlined,
                obscureText: _obscurePassword,
                errorText: dataManager.passwordError,
                onChanged: (value) {
                  // Effacer l'erreur quand l'utilisateur tape
                  if (dataManager.passwordError != null) {
                    dataManager.passwordError = null;
                    dataManager.notifyListeners();
                  }
                  setState(() {}); // Pour feedback temps réel
                },
                suffixIcon: IconButton(
                  icon: HugeIcon(
                    icon: _obscurePassword ? HugeIcons.strokeRoundedViewOff : HugeIcons.strokeRoundedView,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                    // Scroll pour garantir la visibilité de la barre de force
                    Future.delayed(const Duration(milliseconds: 100), () {
                      final ctx = _fieldKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.2);
                      }
                    });
                  },
                  splashRadius: 20,
                ),
              ),
              
              // Critères de sécurité détaillés
              if (password.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPasswordStrengthIndicator(dataManager, password),
              ],
              
              // Conseil (optionnel, compact)
              if (password.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Utilisez une phrase mémorable ou combinez des mots avec des chiffres et symboles',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
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

  Widget _buildPasswordStrengthIndicator(SignupDataManager dataManager, String password) {
    final criteria = [
      {
        'label': '12 caractères',
        'met': dataManager.hasMinLength(password),
      },
      {
        'label': 'Majuscule',
        'met': dataManager.hasUppercase(password),
      },
      {
        'label': 'Minuscule',
        'met': dataManager.hasLowercase(password),
      },
      {
        'label': 'Chiffre',
        'met': dataManager.hasDigit(password),
      },
      {
        'label': 'Spécial',
        'met': dataManager.hasSpecialChar(password),
      },
    ];
    
    final metCriteria = criteria.where((c) => c['met'] as bool).length;
    final strength = metCriteria / criteria.length;
    
    String strengthText;
    Color strengthColor;
    IconData strengthIcon;
    
    if (strength < 0.4) {
      strengthText = 'Faible';
      strengthColor = Colors.red;
      strengthIcon = Icons.warning;
    } else if (strength < 0.8) {
      strengthText = 'Moyen';
      strengthColor = Colors.orange;
      strengthIcon = Icons.info;
    } else {
      strengthText = 'Fort';
      strengthColor = Colors.green;
      strengthIcon = Icons.check_circle;
    }
    
    // Critères manquants
    final missingCriteria = criteria.where((c) => !(c['met'] as bool)).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec force et icône
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: strengthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  strengthIcon,
                  color: strengthColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Force du mot de passe',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$metCriteria sur ${criteria.length} critères respectés',
                      style: TextStyle(
                        fontSize: 11,
                        color: strengthColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                strengthText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Barre de progression
          LinearProgressIndicator(
            value: strength,
            backgroundColor: strengthColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 4,
          ),
          
          // Critères manquants
          if (missingCriteria.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Il manque :',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: missingCriteria.map((criterion) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      criterion['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
          
          // Critères respectés (optionnel, plus discret)
          if (metCriteria > 0) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: criteria.where((c) => c['met'] as bool).map((criterion) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      criterion['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
} 