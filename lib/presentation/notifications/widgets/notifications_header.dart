import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';

class NotificationsHeader extends StatelessWidget {
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;
  final int unreadCount;
  final bool isDark;

  const NotificationsHeader({
    Key? key,
    required this.onMarkAllRead,
    required this.onClearAll,
    required this.unreadCount,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: Column(
        children: [
          Row(
            children: [
              // Bouton retour custom
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 20,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Notifications',
                        style: AppTextStyles.title(context).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _HeaderAction(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                    onTap: onMarkAllRead,
                    isDark: isDark,
                    tooltip: 'Tout marquer comme lu',
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 8),
                  _HeaderAction(
                    icon: HugeIcons.strokeRoundedDelete02,
                    onTap: onClearAll,
                    isDark: isDark,
                    tooltip: 'Effacer tout',
                    color: AppColors.red,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final String tooltip;
  final Color color;

  const _HeaderAction({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
} 