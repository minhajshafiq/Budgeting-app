import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:my_flutter_app/presentation/auth/controllers/auth_provider.dart';
import 'package:my_flutter_app/widgets/app_notification.dart';
import 'package:my_flutter_app/core/constants/constants.dart';
import 'package:my_flutter_app/core/services/user_session_sync.dart';
import 'package:my_flutter_app/utils/user_provider.dart';
import 'package:my_flutter_app/providers/index.dart';
import 'package:my_flutter_app/widgets/modern_animations.dart';
import 'package:my_flutter_app/core/widgets/smart_back_button.dart';
import 'steps/step_1_personal_info.dart';
import 'steps/step_2_email.dart';
import 'steps/step_3_password.dart';
import 'steps/step_4_income_types.dart';
import 'steps/step_5_financial_goals.dart';
import 'steps/step_6_comfort_level.dart';
import 'steps/step_7_notifications.dart';
import 'steps/step_8_tracking_frequency.dart';
import 'package:my_flutter_app/presentation/auth/screens/signup/signup_data.dart';
import 'package:my_flutter_app/core/providers/auth_state_provider.dart';

class SignupPageModular extends StatefulWidget {
  const SignupPageModular({super.key});

  @override
  State<SignupPageModular> createState() => _SignupPageModularState();
}

class _SignupPageModularState extends State<SignupPageModular> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _progressController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.forward();
    _slideController.forward();
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  void _nextStep(SignupDataManager dataManager) async {
    // Fermer automatiquement le clavier
    FocusScope.of(context).unfocus();
    
    if (dataManager!.currentStep < dataManager!.totalSteps - 1) {
      // Validation de l'étape actuelle
      if (await dataManager.validateCurrentStep()) {
        dataManager.nextStep();
        
        _slideController.reset();
        _slideController.forward();
        
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        
        // Mise à jour de la progression
        _progressController.animateTo((dataManager.currentStep + 1) / dataManager.totalSteps);
        
        HapticFeedback.lightImpact();
      }
    } else {
      _createAccount(dataManager);
    }
  }
  
  void _previousStep(SignupDataManager dataManager) {
    if (dataManager!.currentStep > 0) {
      dataManager.previousStep();
      
      _slideController.reset();
      _slideController.forward();
      
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Mise à jour de la progression
      _progressController.animateTo((dataManager.currentStep + 1) / dataManager.totalSteps);
      
      HapticFeedback.lightImpact();
    } else {
      // Retourner à la page d'accueil au lieu de fermer l'application
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    }
  }
  
  void _createAccount(SignupDataManager dataManager) async {
    // Masquer le clavier
    FocusManager.instance.primaryFocus?.unfocus();
    
    // Dernière validation avant soumission finale
    if (await dataManager.validateCurrentStep()) {
      // Créer les données d'inscription
      final signupData = dataManager.toSignupData();
      
      // Tenter l'inscription via AuthProvider
      final authStateProvider = Provider.of<AuthStateProvider>(context, listen: false);
      final success = await authStateProvider.signUp(
        email: signupData.email,
        password: signupData.password,
        firstName: signupData.firstName,
        lastName: signupData.lastName,
      );
      if (!mounted) return;
      if (success) {
        // Inscription réussie
        HapticFeedback.mediumImpact();
        // Synchroniser les informations utilisateur
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final sessionSync = UserSessionSync();
        sessionSync.syncUserInfo(authStateProvider, userProvider);
        // Afficher la notification de succès
        AppNotification.success(
          context,
          title: 'Inscription réussie !',
          subtitle: 'Bienvenue ${authStateProvider.currentUser?.firstName ?? ''}',
        );
        // Animation de succès
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          // Navigation avec nettoyage complet de la pile
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        });
      } else {
        // Erreur d'inscription
        HapticFeedback.heavyImpact();
        // Afficher l'erreur dans l'UI
        final error = authStateProvider.errorMessage ?? 'Une erreur est survenue';
        if (error.toLowerCase().contains('email')) {
          dataManager.goToStep(1); // Revenir à l'étape email
          _pageController.jumpToPage(1);
        } else if (error.toLowerCase().contains('mot de passe')) {
          dataManager.goToStep(2); // Revenir à l'étape mot de passe
          _pageController.jumpToPage(2);
        } else {
          // Afficher une alerte générique
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Erreur d\'inscription'),
                content: Text(error),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignupDataManager(),
      child: Consumer<SignupDataManager>(
        builder: (context, dataManager, child) {
          // Étapes avec saisie de texte (nécessitent scroll pour le clavier)
          final isTextInputStep = dataManager!.currentStep <= 2;
          
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: isTextInputStep,
            appBar: _buildModernAppBar(dataManager),
            body: SafeArea(
              child: Column(
                children: [
                  // Barre de progression moderne
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildModernProgressBar(dataManager),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contenu des étapes
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const Step1PersonalInfo(),
                          const Step2Email(),
                          const Step3Password(),
                          const Step4IncomeTypes(),
                          const Step5FinancialGoals(),
                          const Step6ComfortLevel(),
                          const Step7Notifications(),
                          const Step8TrackingFrequency(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Boutons de navigation modernes
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildModernNavigationButtons(dataManager),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // AppBar moderne avec design amélioré
  PreferredSizeWidget _buildModernAppBar(SignupDataManager dataManager) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: SmartBackButton(
          onPressed: () => _previousStep(dataManager),
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          'Étape ${dataManager.currentStep + 1} sur ${dataManager.totalSteps}',
          key: ValueKey(dataManager.currentStep),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
      centerTitle: true,
    );
  }
  
  // Barre de progression moderne et élégante
  Widget _buildModernProgressBar(SignupDataManager dataManager) {
    final progress = (dataManager!.currentStep + 1) / dataManager!.totalSteps;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Barre de progression principale avec design moderne
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[800]
                  : Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Indicateurs d'étapes modernes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dataManager!.totalSteps, (index) {
              final isCompleted = index < dataManager!.currentStep;
              final isCurrent = index == dataManager!.currentStep;
              final isActive = isCompleted || isCurrent;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 40 : 32,
                height: isCurrent ? 40 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? const Color(0xFF10B981)
                      : isCurrent 
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                  border: Border.all(
                    color: isCompleted 
                        ? const Color(0xFF10B981)
                        : isCurrent 
                            ? const Color(0xFF6366F1)
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[600]!
                                : Colors.grey[400]!),
                    width: isCurrent ? 3 : 2,
                  ),
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: isCurrent ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : Colors.grey,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  // Boutons de navigation modernes
  Widget _buildModernNavigationButtons(SignupDataManager dataManager) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Bouton suivant/créer avec design moderne
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _nextStep(dataManager),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dataManager.currentStep == dataManager.totalSteps - 1
                          ? 'Créer mon compte'
                          : 'Suivant',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      dataManager.currentStep == dataManager.totalSteps - 1
                          ? Icons.check
                          : Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation de succès
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Compte créé avec succès !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            Text(
              'Votre compte a été créé et vous allez être redirigé vers l\'application.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 