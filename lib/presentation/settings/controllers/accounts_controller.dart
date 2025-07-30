import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../utils/theme_provider.dart';
import '../../../utils/user_provider.dart';
import '../../../utils/navigation_service.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import '../../../core/services/index.dart';
import '../../../widgets/app_notification.dart';
import '../../../widgets/notification_settings_modal.dart';
import '../../../widgets/subscription_modal.dart';
import '../../../core/services/user_session_sync.dart';

class AccountsController extends ChangeNotifier {
  // Controllers pour les champs de texte
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _emailController;
  
  // État interne
  bool _isLoading = false;
  bool _isEditingProfile = false;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isEditingProfile => _isEditingProfile;
  TextEditingController? get firstNameController => _firstNameController;
  TextEditingController? get lastNameController => _lastNameController;
  TextEditingController? get emailController => _emailController;
  
  @override
  void dispose() {
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    _emailController?.dispose();
    super.dispose();
  }
  
  // Méthode pour initialiser les controllers avec les données utilisateur
  void initializeControllers(UserProvider userProvider) {
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    _emailController?.dispose();
    
    _firstNameController = TextEditingController(text: userProvider.firstName);
    _lastNameController = TextEditingController(text: userProvider.lastName);
    _emailController = TextEditingController(text: userProvider.email);
    
    notifyListeners();
  }
  
  // Méthode pour générer les initiales
  String getInitials() {
    String firstInitial = _firstNameController?.text.isNotEmpty == true 
        ? _firstNameController!.text[0].toUpperCase() 
        : '';
    String lastInitial = _lastNameController?.text.isNotEmpty == true 
        ? _lastNameController!.text[0].toUpperCase() 
        : '';
    return '$firstInitial$lastInitial';
  }
  
  // Méthode pour afficher la modal d'édition du profil
  void showEditProfileModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    initializeControllers(userProvider);
    _isEditingProfile = true;
    notifyListeners();
  }
  
  // Méthode pour fermer la modal d'édition
  void closeEditProfileModal() {
    _isEditingProfile = false;
    notifyListeners();
  }
  
  // Méthode pour sauvegarder les modifications du profil
  Future<bool> saveProfileChanges(BuildContext context) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Récupérer les providers et le service de synchronisation
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
      final sessionSync = UserSessionSync();
      
      // Mettre à jour le profil dans les deux providers
      final success = await sessionSync.updateUserInfo(
        userProvider: userProvider,
        firstName: _firstNameController?.text ?? '',
        lastName: _lastNameController?.text ?? '',
        email: _emailController?.text ?? '',
      );
      
      return success;
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du profil: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Méthode de déconnexion unifiée
  Future<void> performLogout(BuildContext context) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('🔄 Début de la déconnexion depuis AccountsController...');
      
      // Récupérer les providers
      final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      debugPrint('🔄 Déconnexion via AuthStateManager...');
      // Déconnecter l'utilisateur des deux providers
      await authStateManager.signOut();
      
      debugPrint('🔄 Déconnexion via UserProvider...');
      userProvider.logout();
      
      debugPrint('🔄 Navigation vers la page d\'accueil...');
      // Navigation propre vers l'écran de bienvenue avec route nommée
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
        debugPrint('✅ Navigation réussie vers la page d\'accueil (WelcomeAuthPage)');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la déconnexion: $e');
      // Gestion d'erreur en cas de problème de déconnexion
      if (context.mounted) {
        AppNotification.error(
          context,
          title: 'Erreur de déconnexion',
          subtitle: 'Impossible de se déconnecter correctement',
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Méthodes pour les différentes actions
  void showNotificationsSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => const NotificationSettingsModal(),
    );
  }
  
  void showSubscriptionModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => const SubscriptionModal(),
    );
  }
  
  void showReportBug(BuildContext context) {
    HapticFeedback.lightImpact();
    AppNotification.comingSoon(context, feature: 'Signalement de bugs');
  }
  
  void showSendFeedback(BuildContext context) {
    HapticFeedback.lightImpact();
    AppNotification.comingSoon(context, feature: 'Envoi de commentaires');
  }
  
  void showHelp(BuildContext context) {
    HapticFeedback.lightImpact();
    AppNotification.comingSoon(context, feature: 'Centre d\'aide');
  }
  
  void showAbout(BuildContext context) {
    HapticFeedback.lightImpact();
    AppNotification.info(
      context,
      title: 'À propos de l\'application',
      subtitle: 'Version 1.0.0 - PocketWise\nApplication de gestion de budget intelligente avec synchronisation cloud et analyse financière avancée.',
    );
  }
  
  // Méthode pour afficher la confirmation de déconnexion
  void showLogoutConfirmation(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_outlined,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Déconnexion'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ? Vous devrez vous reconnecter pour accéder à vos données.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Annuler',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              await performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Déconnecter',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
} 