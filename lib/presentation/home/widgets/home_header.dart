import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../utils/user_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/constants/constants.dart';
import '../../../widgets/modern_animations.dart';
import 'package:my_flutter_app/presentation/notifications/screens/notifications_screen.dart';
import '../../../widgets/user_avatar.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  
  const HomeHeader({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User info avec Consumer optimisé
        Expanded(
          child: Row(
            children: [
              // Avatar avec Consumer pour éviter les rebuilds inutiles
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: UserAvatar(
                      initials: userProvider.initials,
                      size: 44,
                      fontSize: 16,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // Greeting text avec Consumer séparé
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        userProvider.firstName,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        // Notification button statique optimisé
        RepaintBoundary(
          child: ModernRippleEffect(
            onTap: onNotificationTap ?? () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/notifications');
            },
            child: Container(
              decoration: AppDecorations.getCircleButtonDecoration(context),
              child: ListenableBuilder(
                listenable: NotificationService(),
                builder: (context, child) {
                  final unreadCount = NotificationService().unreadCount;
                  return Badge(
                    backgroundColor: Colors.red,
                    smallSize: 6,
                    offset: const Offset(-12, 12),
                    alignment: Alignment.topRight,
                    isLabelVisible: unreadCount > 0,
                    child: IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotification01,
                        size: 24,
                        color: isDark ? AppColors.textDark : AppColors.text,
                      ),
                      onPressed: null, // Géré par ModernRippleEffect
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
} 