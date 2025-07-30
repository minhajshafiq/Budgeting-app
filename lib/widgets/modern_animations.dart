/// 🎨 Widgets d'animations modernes unifiés
/// Ce fichier contient tous les widgets d'animation pour l'application
/// Version unifiée qui remplace modern_animation_widgets.dart
/// 
/// Widgets disponibles :
/// - ModernRippleEffect : Effets de ripple avec détection de scroll
/// - SlideInAnimation : Animations de slide avec rebond
/// - PulseAnimation : Animations de pulsation
/// - RotationAnimation : Animations de rotation
/// - ShimmerAnimation : Effets de shimmer pour le loading
/// - MorphingContainer : Containers avec morphing animé
/// - ParallaxWidget : Effets de parallax
/// - BubbleNotification : Notifications en bulle animées

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget pour créer des effets de ripple modernes
class ModernRippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final Duration duration;
  final double borderRadius;
  final bool enableHaptic;
  final bool enableScrolling;

  const ModernRippleEffect({
    Key? key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.duration = const Duration(milliseconds: 300),
    this.borderRadius = 12.0,
    this.enableHaptic = true,
    this.enableScrolling = true,
  }) : super(key: key);

  @override
  State<ModernRippleEffect> createState() => _ModernRippleEffectState();
}

class _ModernRippleEffectState extends State<ModernRippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  // Pour détecter si nous sommes en train de scroller
  bool _isScrolling = false;
  Offset? _touchStartPosition;
  static const _scrollThreshold = 10.0; // pixels

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableScrolling) {
      // Version classique sans détection de scroll
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        if (widget.enableHaptic) {
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        _controller.reverse();
      },
        child: _buildAnimatedChild(),
      );
    }
    
    // Version avec détection de scroll pour éviter de bloquer les gestes de défilement
    return GestureDetector(
      // Capturer le début du toucher pour détecter potentiellement un scroll
      onPanDown: (details) {
        _touchStartPosition = details.globalPosition;
        _isScrolling = false;
      },
      // Détecter si l'utilisateur commence à scroller
      onPanUpdate: (details) {
        if (_touchStartPosition != null) {
          final dx = (_touchStartPosition!.dx - details.globalPosition.dx).abs();
          final dy = (_touchStartPosition!.dy - details.globalPosition.dy).abs();
          
          // Si le mouvement dépasse le seuil, considérer comme scroll
          if (dx > _scrollThreshold || dy > _scrollThreshold) {
            _isScrolling = true;
            _controller.reverse(); // Annuler l'effet si on détecte un scroll
          }
        }
      },
      // Réinitialiser au relâchement
      onPanEnd: (_) {
        _touchStartPosition = null;
        _isScrolling = false;
      },
      // Gestion des taps normaux
      onTapDown: (_) {
        if (!_isScrolling) {
          _controller.forward();
          if (widget.enableHaptic) {
            HapticFeedback.lightImpact();
          }
        }
      },
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onTap != null && !_isScrolling) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: _buildAnimatedChild(),
    );
  }
  
  Widget _buildAnimatedChild() {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          );
        },
    );
  }
}

/// Widget pour des animations de slide avec rebond
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset beginOffset;
  final Duration duration;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0.3, 0),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Démarrer l'animation avec délai
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
            child: widget.child,
          ),
    );
  }
}

/// Widget pour des animations de pulsation
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

      _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
          child: widget.child,
    );
  }
}

/// Widget pour des animations de rotation fluides
class RotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double turns;
  final bool repeat;
  final Curve curve;

  const RotationAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.turns = 1.0,
    this.repeat = false,
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<RotationAnimation> createState() => _RotationAnimationState();
}

class _RotationAnimationState extends State<RotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.turns,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: widget.child,
        );
      },
    );
  }
}

/// Widget pour des animations de shimmer/loading
class ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Widget pour des animations de morphing entre formes
class MorphingContainer extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final BorderRadius borderRadius;
  final Duration duration;
  final Widget? child;

  const MorphingContainer({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
    required this.borderRadius,
    this.duration = const Duration(milliseconds: 300),
    this.child,
  }) : super(key: key);

  @override
  State<MorphingContainer> createState() => _MorphingContainerState();
}

class _MorphingContainerState extends State<MorphingContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeInOut,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );
  }
}

/// Widget pour des animations de parallaxe
class ParallaxWidget extends StatefulWidget {
  final Widget child;
  final double offset;
  final Axis direction;

  const ParallaxWidget({
    Key? key,
    required this.child,
    this.offset = 0.0,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  State<ParallaxWidget> createState() => _ParallaxWidgetState();
}

class _ParallaxWidgetState extends State<ParallaxWidget> {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: widget.direction == Axis.vertical
          ? Offset(0, widget.offset)
          : Offset(widget.offset, 0),
      child: widget.child,
    );
  }
}

/// Widget pour afficher des notifications en bulle
class BubbleNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Duration duration;
  final VoidCallback? onTap;

  const BubbleNotification({
    Key? key,
    required this.message,
    this.icon = Icons.check_circle,
    this.color = const Color(0xFF4CAF50),
    this.duration = const Duration(seconds: 3),
    this.onTap,
  }) : super(key: key);

  @override
  State<BubbleNotification> createState() => _BubbleNotificationState();

  /// Méthode statique pour afficher une notification
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle,
    Color? color,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationColor = color ?? (isDark ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50));
    
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => BubbleNotification(
        message: message,
        icon: icon,
        color: notificationColor,
        duration: duration,
        onTap: onTap ?? () => overlayEntry.remove(),
      ),
    );
    
    overlayState.insert(overlayEntry);
    
    // Auto-remove après la durée spécifiée
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _BubbleNotificationState extends State<BubbleNotification> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
    
    // Auto-reverse avant la fin pour l'animation de sortie
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: ModernRippleEffect(
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF333333),
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: widget.color,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Animation de scale avec bounce
class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double beginScale;
  final Duration duration;

  const ScaleInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginScale = 0.8,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Démarrer l'animation avec délai
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}

// Animation de révélation
class RevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Axis direction;

  const RevealAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
    this.direction = Axis.vertical,
  });

  @override
  State<RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<RevealAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
    
    // Démarrer l'animation avec délai
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Align(
            alignment: widget.direction == Axis.vertical 
                ? Alignment.topCenter 
                : Alignment.centerLeft,
            heightFactor: widget.direction == Axis.vertical 
                ? _animation.value 
                : 1.0,
            widthFactor: widget.direction == Axis.horizontal 
                ? _animation.value 
                : 1.0,
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

// Animation de stagger pour listes
class StaggeredListAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration itemDelay;
  final Duration duration;

  const StaggeredListAnimation({
    super.key,
    required this.child,
    required this.index,
    this.itemDelay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Calculer le délai basé sur l'index
    final delay = Duration(milliseconds: widget.itemDelay.inMilliseconds * widget.index);
    
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}

// Animation de shake pour erreurs
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;

  const ShakeAnimation({
    super.key,
    required this.child,
    required this.trigger,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final shakeValue = _animation.value;
        final offset = 10 * (1 - shakeValue) * (shakeValue < 0.5 ? 1 : -1);
        
        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
} 