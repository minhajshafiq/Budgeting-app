import 'package:flutter/material.dart';

/// Widget qui implémente une transition moderne de type "Fade Through" entre deux écrans.
/// Cette transition utilise les dernières courbes d'animation et des effets de parallaxe.
class FadeThroughTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Key? childKey;
  final bool enableParallax;
  final double parallaxOffset;

  const FadeThroughTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
    this.childKey,
    this.enableParallax = true,
    this.parallaxOffset = 30.0,
  }) : super(key: key);

  @override
  State<FadeThroughTransition> createState() => _FadeThroughTransitionState();
}

class _FadeThroughTransitionState extends State<FadeThroughTransition> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _blurAnimation;
  Widget? _oldChild;
  Key? _oldChildKey;
  bool _isInitialized = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Ajouter un listener pour suivre l'état de l'animation
    _controller.addStatusListener(_animationStatusListener);

    _initializeAnimations();
    
    _oldChild = widget.child;
    _oldChildKey = widget.childKey;
    _isInitialized = true;
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
      if (!_isAnimating && mounted) {
        setState(() {
          _isAnimating = true;
        });
      }
    } else if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      if (_isAnimating && mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    }
  }

  void _initializeAnimations() {
    // Animation de fade out plus douce
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInCubic),
    ));

    // Animation de fade in avec courbe moderne
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Animation de scale plus subtile
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Animation de slide pour l'effet parallaxe
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.parallaxOffset / 1000),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Animation de blur pour un effet moderne
    _blurAnimation = Tween<double>(
      begin: 2.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void didUpdateWidget(FadeThroughTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.childKey != _oldChildKey) {
      _oldChild = oldWidget.child;
      _oldChildKey = oldWidget.childKey;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_animationStatusListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return widget.child;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Ancien écran qui disparaît avec effet de blur
        if (_oldChild != null)
          IgnorePointer(
            // Ignorer les interactions pendant l'animation
            ignoring: _isAnimating,
            child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeOutAnimation,
                child: Transform.scale(
                  scale: 1.0 + (0.05 * _controller.value), // Léger zoom out
                  child: _oldChild!,
                ),
              );
            },
            ),
          ),
        
        // Nouvel écran qui apparaît avec effets modernes
        IgnorePointer(
          // Ne pas ignorer les interactions une fois l'animation terminée
          ignoring: false,
          child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: widget.enableParallax
                    ? SlideTransition(
                        position: _slideAnimation,
                        child: widget.child,
                      )
                    : widget.child,
              ),
            );
          },
          ),
        ),
      ],
    );
  }
}

/// Transition moderne pour les pages avec effet de slide
class SlidePageTransition extends PageRouteBuilder {
  final Widget child;
  final AxisDirection direction;
  final Duration duration;

  SlidePageTransition({
    required this.child,
    this.direction = AxisDirection.left,
    this.duration = const Duration(milliseconds: 350),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case AxisDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
              case AxisDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
              case AxisDirection.left:
              default:
                begin = const Offset(1.0, 0.0);
                break;
            }

            const end = Offset.zero;
            final curve = Curves.easeInOutCubic;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
