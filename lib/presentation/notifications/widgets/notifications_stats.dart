import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';

class NotificationsStats extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final Animation<double> animation;
  final bool isDark;

  const NotificationsStats({
    Key? key,
    required this.totalCount,
    required this.unreadCount,
    required this.animation,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _buildStatChip(
              icon: HugeIcons.strokeRoundedNotification01,
              label: '$totalCount notification${totalCount > 1 ? 's' : ''}',
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            if (unreadCount > 0)
              _buildStatChip(
                icon: HugeIcons.strokeRoundedAlert01,
                label: '$unreadCount non lu${unreadCount > 1 ? 'es' : 'e'}',
                color: AppColors.orange,
                isPulsing: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    bool isPulsing = false,
  }) {
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: HugeIcon(icon: icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
    if (isPulsing) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 2000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 1.0 + (0.03 * math.sin(value * 2 * math.pi)),
            child: chip,
          );
        },
      );
    }
    return chip;
  }
} 