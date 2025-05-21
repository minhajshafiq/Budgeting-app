import 'package:flutter/material.dart';

/// Widget qui implémente une transition de type "Fade Through" entre deux écrans.
/// Cette transition est conforme aux recommandations Material Design pour les transitions entre destinations.
class FadeThroughTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Key? childKey;

  const FadeThroughTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.childKey,
  }) : super(key: key);

  @override
  State<FadeThroughTransition> createState() => _FadeThroughTransitionState();
}

class _FadeThroughTransitionState extends State<FadeThroughTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  Widget? _oldChild;
  Key? _oldChildKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: widget.curve),
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: widget.curve),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: widget.curve),
    ));

    _oldChild = widget.child;
    _oldChildKey = widget.childKey;
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Ancien écran qui disparaît
        FadeTransition(
          opacity: _fadeOutAnimation,
          child: _oldChild,
        ),
        // Nouvel écran qui apparaît avec un effet de scale
        FadeTransition(
          opacity: _fadeInAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
