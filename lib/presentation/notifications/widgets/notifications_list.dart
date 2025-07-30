import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/notification_service.dart';
import 'notifications_utils.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class NotificationsList extends StatelessWidget {
  final List<NotificationData> notifications;
  final int unreadCount;
  final void Function(String id) onMarkAsRead;
  final void Function(String id) onRemove;
  final bool isDark;
  final void Function(String message)? onShowSnackBar;

  const NotificationsList({
    Key? key,
    required this.notifications,
    required this.unreadCount,
    required this.onMarkAsRead,
    required this.onRemove,
    required this.isDark,
    this.onShowSnackBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (unread.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.orange, AppColors.red],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nouvelles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${unread.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notification = unread[index];
                return SlideInAnimation(
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  beginOffset: const Offset(0.3, 0),
                  child: _NotificationItem(
                    notification: notification,
                    isDark: isDark,
                    isUnread: true,
                    onMarkAsRead: onMarkAsRead,
                    onRemove: onRemove,
                    onShowSnackBar: onShowSnackBar,
                  ),
                );
              },
              childCount: unread.length,
            ),
          ),
        ],
        if (read.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, unread.isNotEmpty ? 24 : 16, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Précédentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.8),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notification = read[index];
                final globalIndex = unread.length + index;
                return SlideInAnimation(
                  delay: Duration(milliseconds: 100 + (globalIndex * 50)),
                  beginOffset: const Offset(0.3, 0),
                  child: _NotificationItem(
                    notification: notification,
                    isDark: isDark,
                    isUnread: false,
                    onMarkAsRead: onMarkAsRead,
                    onRemove: onRemove,
                    onShowSnackBar: onShowSnackBar,
                  ),
                );
              },
              childCount: read.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class SlideInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Offset beginOffset;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0.3, 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(begin: beginOffset, end: Offset.zero),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: child,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value.dx * MediaQuery.of(context).size.width, value.dy),
            child: child,
          );
        },
      ),
    );
  }
}

class _DelayedAnimation extends StatefulWidget {
  final Duration delay;
  final Widget child;
  const _DelayedAnimation({Key? key, required this.delay, required this.child}) : super(key: key);
  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation> {
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }
  @override
  Widget build(BuildContext context) {
    return _visible ? widget.child : const SizedBox.shrink();
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationData notification;
  final bool isDark;
  final bool isUnread;
  final void Function(String id) onMarkAsRead;
  final void Function(String id) onRemove;
  final void Function(String message)? onShowSnackBar;

  const _NotificationItem({
    Key? key,
    required this.notification,
    required this.isDark,
    required this.isUnread,
    required this.onMarkAsRead,
    required this.onRemove,
    this.onShowSnackBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: _buildSwipeBackground(isDark),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          return await _showDeleteConfirmation(context, notification.title, isDark);
        },
        onDismissed: (direction) {
          onRemove(notification.id);
          onShowSnackBar?.call('Notification supprimée');
        },
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (!notification.isRead) {
              onMarkAsRead(notification.id);
              onShowSnackBar?.call('Notification marquée comme lue');
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: notification.isRead
                  ? (isDark ? AppColors.surfaceDark : Colors.white)
                  : (isDark
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.primary.withOpacity(0.05)),
              border: Border.all(
                color: notification.isRead
                    ? (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)
                    : AppColors.primary.withOpacity(0.2),
                width: notification.isRead ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(notification.isRead ? 0.02 : 0.06),
                  blurRadius: notification.isRead ? 4 : 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône moderne avec animation et gradients
                  Hero(
                    tag: 'notification_icon_${notification.id}',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            getNotificationColor(notification.color).withOpacity(0.15),
                            getNotificationColor(notification.color).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: getNotificationColor(notification.color).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: getNotificationIcon(notification.icon),
                          color: getNotificationColor(notification.color),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Contenu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                  color: isDark ? AppColors.textDark : AppColors.text,
                                  letterSpacing: -0.2,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orange.withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.9),
                            height: 1.4,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedClock01,
                              size: 14,
                              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatNotificationTimestamp(notification.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.7),
                                letterSpacing: -0.1,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getNotificationColor(notification.color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                getNotificationTypeLabel(notification.type),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: getNotificationColor(notification.color),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isDark) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.red.withOpacity(0.1),
            AppColors.red,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Supprimer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String notificationTitle, bool isDark) async {
    return await showDialog<bool>(
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
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    size: 32,
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Supprimer la notification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Êtes-vous sûr de vouloir supprimer\n"${notificationTitle.length > 30 ? '${notificationTitle.substring(0, 30)}...' : notificationTitle}" ?',
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
                            'Supprimer',
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
    ) ?? false;
  }
} 