import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/constants.dart';
import '../core/widgets/card_container.dart';
import '../utils/user_provider.dart';
import 'app_notification.dart';
import '../core/services/user_session_sync.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:my_flutter_app/presentation/auth/controllers/auth_provider.dart';

class NotificationSettingsModal extends StatefulWidget {
  const NotificationSettingsModal({super.key});

  @override
  State<NotificationSettingsModal> createState() => _NotificationSettingsModalState();
}

class _NotificationSettingsModalState extends State<NotificationSettingsModal> 
    with TickerProviderStateMixin {
  Map<String, bool> _notificationPreferences = {};
  bool _isLoading = true;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _notificationTypes = [
    {
      'iconOutlined': HugeIcons.strokeRoundedWallet01,
      'iconFilled': HugeIcons.strokeRoundedWallet01,
      'title': 'Dépassement de budget',
      'subtitle': 'Être alerté quand vous dépassez votre budget',
      'key': 'budget_exceeded',
      'color': const Color(0xFFFF5757),
      'bgColor': const Color(0xFFFF5757),
    },
    {
      'iconOutlined': HugeIcons.strokeRoundedTarget01,
      'iconFilled': HugeIcons.strokeRoundedTarget01,
      'title': 'Objectif atteint',
      'subtitle': 'Célébrer quand vous atteignez vos objectifs',
      'key': 'goal_achieved',
      'color': const Color(0xFF00C896),
      'bgColor': const Color(0xFF00C896),
    },
    {
      'iconOutlined': HugeIcons.strokeRoundedCalendar01,
      'iconFilled': HugeIcons.strokeRoundedCalendar01,
      'title': 'Fin de mois proche',
      'subtitle': 'Rappel à l\'approche de la fin du mois',
      'key': 'month_end',
      'color': const Color(0xFF5B9BD5),
      'bgColor': const Color(0xFF5B9BD5),
    },
    {
      'iconOutlined': HugeIcons.strokeRoundedAlert02,
      'iconFilled': HugeIcons.strokeRoundedAlert02,
      'title': 'Débit inhabituel',
      'subtitle': 'Détecter les transactions inhabituelles',
      'key': 'unusual_debit',
      'color': const Color(0xFFFF9500),
      'bgColor': const Color(0xFFFF9500),
    },
    {
      'iconOutlined': HugeIcons.strokeRoundedPieChart,
      'iconFilled': HugeIcons.strokeRoundedPieChart,
      'title': 'Résumé hebdomadaire',
      'subtitle': 'Rapport de vos finances chaque semaine',
      'key': 'weekly_summary',
      'color': const Color(0xFF8B5CF6),
      'bgColor': const Color(0xFF8B5CF6),
    },
    {
      'iconOutlined': HugeIcons.strokeRoundedAnalytics01,
      'iconFilled': HugeIcons.strokeRoundedAnalytics01,
      'title': 'Rapport mensuel',
      'subtitle': 'Analyse détaillée de vos dépenses mensuelles',
      'key': 'monthly_report',
      'color': const Color(0xFFEC4899),
      'bgColor': const Color(0xFFEC4899),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadNotificationPreferences();
    _startAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
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
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadNotificationPreferences() async {
    final sessionSync = UserSessionSync();
    
    try {
      final preferences = await sessionSync.loadNotificationPreferences();
      if (mounted) {
        setState(() {
          _notificationPreferences = preferences;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des préférences: $e');
      if (mounted) {
        setState(() {
          _notificationPreferences = {
            'budget_exceeded': true,
            'goal_achieved': true,
            'month_end': false,
            'unusual_debit': true,
            'weekly_summary': false,
            'monthly_report': true,
          };
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveNotificationPreferences() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final sessionSync = UserSessionSync();
      final navigator = Navigator.of(context);

      final success = await sessionSync.updateNotificationPreferences(
        userProvider: userProvider,
        notificationPreferences: Map<String, bool>.from(_notificationPreferences),
      );

      if (mounted) {
        // Fermer la modal d'abord
        navigator.pop();
        
        // Utiliser un callback pour afficher la notification après la fermeture
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (success) {
            AppNotification.success(
              navigator.context,
              title: 'Préférences sauvegardées',
              subtitle: 'Vos paramètres de notification ont été mis à jour',
            );
          } else {
            AppNotification.error(
              navigator.context,
              title: 'Erreur',
              subtitle: 'Impossible de sauvegarder les préférences',
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des préférences: $e');
      if (mounted) {
        final navigator = Navigator.of(context);
        navigator.pop();
        
        // Utiliser un callback pour afficher la notification d'erreur
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppNotification.error(
            navigator.context,
            title: 'Erreur',
            subtitle: 'Une erreur est survenue lors de la sauvegarde',
          );
        });
      }
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return       SlideTransition(
        position: _slideAnimation,
                child: Container(
          height: MediaQuery.of(context).size.height * 0.92,
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
          children: [
            // Handle bar amélioré
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 0),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header centré et amélioré
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: isDarkMode ? 0.4 : 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedNotification01,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        letterSpacing: -0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Personnalisez vos préférences de notification',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Liste des notifications améliorée
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _notificationTypes.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(15 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildNotificationCard(
                                    _notificationTypes[index],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            
            // Boutons d'action modernes
            if (!_isLoading)
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
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
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _saveNotificationPreferences();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notificationType) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = _notificationPreferences[notificationType['key']] ?? false;
    final color = notificationType['color'] as Color;
    final bgColor = notificationType['bgColor'] as Color;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEnabled 
              ? color.withValues(alpha: 0.4)
              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _notificationPreferences[notificationType['key']] = !isEnabled;
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icône avec background conditionnel amélioré
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isEnabled 
                        ? bgColor 
                        : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isEnabled ? [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: HugeIcon(
                    icon: notificationType['iconOutlined'],
                    color: isEnabled 
                        ? Colors.white 
                        : color.withValues(alpha: 0.7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Contenu amélioré
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationType['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificationType['subtitle'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Modern Switch
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _notificationPreferences[notificationType['key']] = !isEnabled;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 50,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isEnabled 
                          ? color
                          : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: isEnabled 
                              ? color.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.1),
                          blurRadius: isEnabled ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: isEnabled
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: color,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}