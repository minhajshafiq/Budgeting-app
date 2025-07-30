import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/constants.dart';
import '../../../../utils/validators.dart';
import '../../../../utils/user_provider.dart';
import '../../../../widgets/modern_animations.dart';
import '../../../../core/widgets/animated_text_field.dart';
import '../../../../widgets/app_notification.dart';
import '../../../../screens/main_screen.dart';
import '../signup/signup_page_modular.dart';
import '../../../../core/services/user_session_sync.dart';
import 'package:my_flutter_app/presentation/auth/core/types/auth_types.dart';
import 'package:my_flutter_app/core/providers/auth_state_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // État du formulaire
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    // Masquer le clavier
    FocusManager.instance.primaryFocus?.unfocus();
    
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Créer les données de connexion
      final loginData = LoginData(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );
      
      // Tenter la connexion
      final authStateProvider = Provider.of<AuthStateProvider>(context, listen: false);
      final success = await authStateProvider.signIn(
        email: loginData.email,
        password: loginData.password,
      );
      
      if (!mounted) return;
      
      if (success) {
        // Connexion réussie
        HapticFeedback.mediumImpact();
        
        // Effacer le mot de passe pour des raisons de sécurité
        _passwordController.clear();
        
        // Synchroniser les informations utilisateur
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final sessionSync = UserSessionSync();
        sessionSync.syncUserInfo(authStateProvider, userProvider);
        
        // Afficher notification de succès
        AppNotification.success(
          context,
          title: 'Connexion réussie !',
          subtitle: 'Bienvenue ${authStateProvider.currentUser?.firstName ?? ''}',
        );
        
        // Naviguer vers l'écran principal
        _navigateToMainScreen();
      } else {
        // Erreur de connexion
        HapticFeedback.heavyImpact();
        
        AppNotification.error(
          context,
          title: 'Erreur de connexion',
          subtitle: authStateProvider.errorMessage ?? 'Email ou mot de passe incorrect',
        );
      }
    } catch (e) {
      // Gestion des erreurs imprévues
      AppNotification.error(
        context,
        title: 'Erreur de connexion',
        subtitle: 'Une erreur est survenue. Veuillez réessayer.',
      );
    } finally {
      if (mounted) {
      setState(() {
          _isLoading = false;
      });
      }
    }
  }
  
  void _navigateToMainScreen() {
    // Navigation avec nettoyage complet de la pile pour éviter le retour vers les écrans d'authentification
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false, // Supprimer toutes les routes précédentes
    );
  }
  
  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      AppNotification.error(
        context,
        title: 'Email requis',
        subtitle: 'Veuillez entrer votre adresse email',
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final authStateProvider = Provider.of<AuthStateProvider>(context, listen: false);
      final success = await authStateProvider.resetPassword(_emailController.text.trim().toLowerCase());
      if (!mounted) return;
      if (success) {
        AppNotification.success(
          context,
          title: 'Email envoyé',
          subtitle: 'Vérifiez votre boîte de réception',
        );
      } else {
        AppNotification.error(
          context,
          title: 'Erreur',
          subtitle: authStateProvider.errorMessage ?? 'Impossible d\'envoyer l\'email',
        );
      }
    } catch (e) {
      AppNotification.error(
        context,
        title: 'Erreur',
        subtitle: 'Une erreur est survenue. Veuillez réessayer.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Titre
              SlideInAnimation(
                beginOffset: const Offset(-0.3, 0),
                duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Bon retour\nparmi nous !',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              SlideInAnimation(
                beginOffset: const Offset(-0.2, 0),
                delay: const Duration(milliseconds: 100),
                      child: Text(
                  'Connectez-vous à votre compte',
                        style: TextStyle(
                          fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.textSecondaryDark 
                        : AppColors.textSecondary,
                        ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Formulaire avec champs animés
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Champ email avec animation
              SlideInAnimation(
                beginOffset: const Offset(0, 0.3),
                delay: const Duration(milliseconds: 200),
                      child: _AnimatedFormField(
                  controller: _emailController,
                        label: 'Adresse email',
                  icon: HugeIcons.strokeRoundedMail01,
                  keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value ?? '').validateEmail,
                ),
              ),
              
              const SizedBox(height: 20),
              
                    // Champ mot de passe avec animation
              SlideInAnimation(
                beginOffset: const Offset(0, 0.3),
                delay: const Duration(milliseconds: 300),
                      child: _AnimatedPasswordField(
                  controller: _passwordController,
                        label: 'Mot de passe',
                        isVisible: _isPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) => (value ?? '').validatePassword(),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Mot de passe oublié
              SlideInAnimation(
                beginOffset: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 400),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _isLoading ? null : () {
                      HapticFeedback.lightImpact();
                      _forgotPassword();
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Bouton de connexion avec état de chargement
              SlideInAnimation(
                beginOffset: const Offset(0, 0.5),
                delay: const Duration(milliseconds: 500),
                child: Consumer<AuthStateProvider>(
                  builder: (context, authStateProvider, child) {
                    final isButtonDisabled = _isLoading || authStateProvider.isLoading;
                    
                    return GestureDetector(
                      onTap: isButtonDisabled ? null : _login,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isButtonDisabled 
                                ? [Colors.grey, Colors.grey.shade400]
                                : [AppColors.primary, const Color(0xFF4A90E2)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                              color: (isButtonDisabled ? Colors.grey : AppColors.primary)
                                  .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                        child: Center(
                          child: isButtonDisabled
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Lien vers inscription
              SlideInAnimation(
                beginOffset: const Offset(0, 0.3),
                delay: const Duration(milliseconds: 600),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : () {
                          HapticFeedback.lightImpact();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPageModular()),
                          );
                        },
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget personnalisé pour champ de formulaire animé
  Widget _AnimatedFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedTextField(
              controller: controller,
              label: label,
              icon: icon,
              keyboardType: keyboardType,
              errorText: field.errorText,
              onChanged: (value) {
                field.didChange(value);
              },
            ),
          ],
        );
      },
    );
  }

  // Widget personnalisé pour champ mot de passe animé
  Widget _AnimatedPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
            children: [
                AnimatedTextField(
                  controller: controller,
                  label: label,
                  icon: HugeIcons.strokeRoundedLock,
                  obscureText: !isVisible,
                  errorText: field.errorText,
                  onChanged: (value) {
                    field.didChange(value);
                  },
                ),
                // Bouton de visibilité personnalisé
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: field.errorText != null ? 24 : 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onVisibilityToggle();
                      },
                child: Container(
                        padding: const EdgeInsets.all(8),
                  child: HugeIcon(
                          icon: isVisible 
                              ? HugeIcons.strokeRoundedView 
                              : HugeIcons.strokeRoundedViewOff,
                          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7) ?? Colors.grey,
                          size: 20,
                ),
              ),
                    ),
          ),
        ),
              ],
      ),
          ],
        );
      },
    );
  }
} 