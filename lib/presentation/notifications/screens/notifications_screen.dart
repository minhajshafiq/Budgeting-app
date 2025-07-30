import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notifications_header.dart';
import '../widgets/notifications_stats.dart';
import '../widgets/notifications_list.dart';
import '../widgets/notifications_empty_state.dart';
import '../widgets/notifications_utils.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../widgets/app_notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsController(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView({Key? key}) : super(key: key);

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutExpo),
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.elasticOut,
    );
    _startAnimations();
  }

  void _startAnimations() async {
    _headerAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _statsAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NotificationsController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = controller.notifications;
    final unreadCount = controller.unreadCount;

    void showSnackBar(String message) {
      AppNotification.success(
        context,
        title: message,
        duration: const Duration(seconds: 2),
      );
    }

    Future<void> showClearAllDialog() async {
      HapticFeedback.mediumImpact();
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      size: 32,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Effacer toutes les notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cette action supprimera définitivement toutes vos notifications. Cette action est irréversible.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Annuler',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textDark : AppColors.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Effacer tout',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (result == true) {
        controller.clearAll();
        showSnackBar('Toutes les notifications supprimées');
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: NotificationsHeader(
                  onMarkAllRead: () {
                    HapticFeedback.lightImpact();
                    controller.markAllAsRead();
                    showSnackBar('Toutes les notifications marquées comme lues');
                  },
                  onClearAll: showClearAllDialog,
                  unreadCount: unreadCount,
                  isDark: isDark,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return NotificationsStats(
                  totalCount: notifications.length,
                  unreadCount: unreadCount,
                  animation: _statsAnimation,
                  isDark: isDark,
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  if (notifications.isEmpty) {
                    return NotificationsEmptyState(isDark: isDark);
                  }
                  return FadeTransition(
                    opacity: _listAnimation,
                    child: NotificationsList(
                      notifications: notifications,
                      unreadCount: unreadCount,
                      onMarkAsRead: controller.markAsRead,
                      onRemove: controller.removeNotification,
                      isDark: isDark,
                      onShowSnackBar: showSnackBar,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 