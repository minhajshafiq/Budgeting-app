import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/constants/constants.dart';

enum NotificationType { success, error, info, warning }

class AppNotification {
  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required NotificationType type,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color backgroundColor;
    Color iconColor;
    IconData icon;
    
    switch (type) {
      case NotificationType.success:
        backgroundColor = AppColors.green;
        iconColor = Colors.white;
        icon = HugeIcons.strokeRoundedCheckmarkCircle02;
        break;
      case NotificationType.error:
        backgroundColor = AppColors.red;
        iconColor = Colors.white;
        icon = HugeIcons.strokeRoundedAlert01;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade600;
        iconColor = Colors.white;
        icon = HugeIcons.strokeRoundedAlert01;
        break;
      case NotificationType.info:
        backgroundColor = AppColors.primary;
        iconColor = Colors.white;
        icon = HugeIcons.strokeRoundedInformationCircle;
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        top: MediaQuery.of(context).padding.top + 16,
        backgroundColor: backgroundColor,
        icon: icon,
        iconColor: iconColor,
        title: title,
        subtitle: subtitle,
        onTap: onTap != null ? () {
          overlayEntry.remove();
          onTap();
        } : null,
        onDismiss: () => overlayEntry.remove(),
        isDark: isDark,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove après la durée spécifiée
    Future.delayed(duration ?? const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // Méthodes raccourcies pour chaque type
  static void success(
    BuildContext context, {
    required String title,
    String? subtitle,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    show(
      context,
      title: title,
      subtitle: subtitle,
      type: NotificationType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  static void error(
    BuildContext context, {
    required String title,
    String? subtitle,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    show(
      context,
      title: title,
      subtitle: subtitle,
      type: NotificationType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  static void info(
    BuildContext context, {
    required String title,
    String? subtitle,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    show(
      context,
      title: title,
      subtitle: subtitle,
      type: NotificationType.info,
      duration: duration,
      onTap: onTap,
    );
  }

  static void warning(
    BuildContext context, {
    required String title,
    String? subtitle,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    show(
      context,
      title: title,
      subtitle: subtitle,
      type: NotificationType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  // Notification "Coming Soon" spécialisée
  static void comingSoon(
    BuildContext context, {
    required String feature,
  }) {
    info(
      context,
      title: 'Fonctionnalité en développement',
      subtitle: '$feature sera bientôt disponible !',
      duration: const Duration(seconds: 2),
    );
  }
}

class _NotificationWidget extends StatefulWidget {
  final double top;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;
  final bool isDark;

  const _NotificationWidget({
    required this.top,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.onDismiss,
    required this.isDark,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: (details) {
            // Détecter le swipe vers le haut
            if (details.delta.dy < -3) {
              _dismiss();
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: widget.isDark ? null : Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isDark 
                            ? Colors.black.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.1),
                          blurRadius: widget.isDark ? 12 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: widget.backgroundColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: HugeIcon(
                            icon: widget.icon,
                            color: widget.iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark ? Colors.white : Colors.grey.shade800,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.isDark 
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.grey.shade600,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.onTap != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: widget.isDark 
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                color: widget.isDark ? Colors.white : Colors.grey.shade700,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 