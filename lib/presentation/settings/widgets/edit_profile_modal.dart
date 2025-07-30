import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import '../../../utils/user_provider.dart';
import '../../../widgets/app_notification.dart';
import '../controllers/accounts_controller.dart';

class EditProfileModal extends StatelessWidget {
  const EditProfileModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<AccountsController>(
      builder: (context, controller, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height * 0.92,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFFBFBFB),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar amélioré
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 0),
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header avec icône centrée et titre aligné à gauche
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  children: [
                    // Icône centrée
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: isDarkMode ? 0.4 : 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedUserEdit01,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Titre centré
                    Center(
                      child: Text(
                        'Modifier le profil',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Sous-titre centré
                    Center(
                      child: Text(
                        'Personnalisez vos informations',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Enhanced Form with better spacing
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Current user info display
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      userProvider.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Profil actuel',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        userProvider.fullName,
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Enhanced text fields with better styling
                      _buildEnhancedTextField(
                        context: context,
                        label: 'Prénom',
                        controller: controller.firstNameController,
                        hint: 'Entrez votre prénom',
                        icon: HugeIcons.strokeRoundedUser,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildEnhancedTextField(
                        context: context,
                        label: 'Nom de famille',
                        controller: controller.lastNameController,
                        hint: 'Entrez votre nom',
                        icon: HugeIcons.strokeRoundedUser,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildEnhancedTextField(
                        context: context,
                        label: 'Adresse email',
                        controller: controller.emailController,
                        hint: 'Entrez votre email',
                        icon: HugeIcons.strokeRoundedMail01,
                        keyboardType: TextInputType.emailAddress,
                        isDarkMode: isDarkMode,
                      ),
                      
                      const Spacer(),
                      
                      // Enhanced action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                  controller.closeEditProfileModal();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: Text(
                                  'Annuler',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: controller.isLoading ? Colors.grey : Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: controller.isLoading ? [] : [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: controller.isLoading ? null : () async {
                                  HapticFeedback.mediumImpact();
                                  
                                  final success = await controller.saveProfileChanges(context);
                                  
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    controller.closeEditProfileModal();
                                    
                                    // Attendre un petit délai avant d'afficher la notification
                                    await Future.delayed(const Duration(milliseconds: 200));
                                    
                                    if (context.mounted) {
                                      if (success) {
                                        AppNotification.success(
                                          context,
                                          title: 'Profil mis à jour',
                                          subtitle: 'Vos modifications ont été appliquées',
                                        );
                                      } else {
                                        AppNotification.error(
                                          context,
                                          title: 'Erreur',
                                          subtitle: 'Impossible de mettre à jour le profil',
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: controller.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const HugeIcon(
                                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Sauvegarder',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTextField({
    required BuildContext context,
    required String label,
    required TextEditingController? controller,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF2C2C2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.4),
                fontSize: 15,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.2),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: HugeIcon(
                  icon: icon,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 