import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import '../../../utils/theme_provider.dart';
import '../../../widgets/theme_switcher.dart';
import '../../../core/widgets/smart_back_button.dart';
import '../controllers/accounts_controller.dart';
import '../widgets/index.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late AccountsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AccountsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDarkMode = themeProvider.isDarkMode;
          
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec bouton smart et titre centré
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 40,
                      child: Stack(
                        children: [
                          // Bouton de retour smart à gauche
                          const Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: SmartBackButton(),
                          ),
                          
                          // Titre centré
                          Center(
                            child: Text(
                              'Settings',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 8),
                        
                        // Profile Section
                        Consumer<AccountsController>(
                          builder: (context, controller, child) {
                            return ProfileCard(
                              isDarkMode: isDarkMode,
                              onEditPressed: () => _showEditProfileModal(context),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // General Section
                        SettingsSection(
                          title: 'GENERAL',
                          children: [
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedUser,
                                  title: 'Profile',
                                  subtitle: 'Gérer vos informations personnelles',
                                  onTap: () => _showEditProfileModal(context),
                                  iconColor: const Color(0xFF6366F1),
                                  iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                );
                              },
                            ),
                            const SettingsDivider(),
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedNotification01,
                                  title: 'Notifications',
                                  subtitle: 'Configurer vos préférences',
                                  onTap: () => controller.showNotificationsSettings(context),
                                  iconColor: const Color(0xFFEF4444),
                                  iconBgColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                );
                              },
                            ),
                            const SettingsDivider(),
                            SettingsItem(
                              icon: HugeIcons.strokeRoundedPaintBrush01,
                              title: 'Appearance',
                              subtitle: 'Choisir le thème de l\'application',
                              onTap: () {}, // No action needed, handled by ThemeSwitcher
                              iconColor: const Color(0xFF8B5CF6),
                              iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              trailing: const ThemeSwitcher(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Subscriptions Section
                        SettingsSection(
                          title: 'SUBSCRIPTIONS',
                          children: [
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedCrown,
                                  title: 'Gérer mon abonnement',
                                  subtitle: 'Premium, factures et paiements',
                                  onTap: () => controller.showSubscriptionModal(context),
                                  iconColor: const Color(0xFF8B5CF6),
                                  iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Feedback Section
                        SettingsSection(
                          title: 'FEEDBACK',
                          children: [
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedAlert01,
                                  title: 'Report a bug',
                                  subtitle: 'Signaler un problème',
                                  onTap: () => controller.showReportBug(context),
                                  iconColor: const Color(0xFFEF4444),
                                  iconBgColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                );
                              },
                            ),
                            const SettingsDivider(),
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedSent,
                                  title: 'Send feedback',
                                  subtitle: 'Partager vos commentaires',
                                  onTap: () => controller.showSendFeedback(context),
                                  iconColor: const Color(0xFF10B981),
                                  iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                                );
                              },
                            ),
                            const SettingsDivider(),
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedHelpCircle,
                                  title: 'Help',
                                  subtitle: 'Centre d\'aide et support',
                                  onTap: () => controller.showHelp(context),
                                  iconColor: const Color(0xFF06B6D4),
                                  iconBgColor: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                                );
                              },
                            ),
                            const SettingsDivider(),
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedInformationCircle,
                                  title: 'About',
                                  subtitle: 'À propos de l\'application',
                                  onTap: () => controller.showAbout(context),
                                  iconColor: const Color(0xFF8B5CF6),
                                  iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                );
                              },
                            ),
                            const SettingsDivider(),
                            SettingsItem(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Politique de confidentialité',
                              subtitle: 'Comment nous protégeons vos données',
                              onTap: () => Navigator.pushNamed(context, '/privacy_policy'),
                              iconColor: const Color(0xFF10B981),
                              iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                            ),
                            const SettingsDivider(),
                            SettingsItem(
                              icon: Icons.description_outlined,
                              title: 'Conditions d\'utilisation',
                              subtitle: 'Règles d\'utilisation de l\'application',
                              onTap: () => Navigator.pushNamed(context, '/terms_of_service'),
                              iconColor: const Color(0xFF8B5CF6),
                              iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            ),
                            const SettingsDivider(),
                            SettingsItem(
                              icon: Icons.gavel_outlined,
                              title: 'Mentions légales',
                              subtitle: 'Informations légales de l\'application',
                              onTap: () => Navigator.pushNamed(context, '/legal_notices'),
                              iconColor: const Color(0xFFF59E0B),
                              iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Account Section
                        SettingsSection(
                          title: 'COMPTE',
                          children: [
                            Consumer<AccountsController>(
                              builder: (context, controller, child) {
                                return SettingsItem(
                                  icon: HugeIcons.strokeRoundedLogout01,
                                  title: 'Se déconnecter',
                                  subtitle: 'Fermer votre compte',
                                  onTap: () => controller.showLogoutConfirmation(context),
                                  iconColor: const Color(0xFFEF4444),
                                  iconBgColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileModal(BuildContext context) {
    _controller.showEditProfileModal(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }
}

// Extension pour afficher la modal d'édition du profil
extension AccountsScreenExtension on AccountsScreen {
  static void showEditProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }
} 