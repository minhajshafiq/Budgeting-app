import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final int decimalPlaces;
  final String decimalSeparator;
  final String thousandSeparator;
  final bool enableDigitAnimation;
  final bool enableBounceEffect;
  
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
    this.decimalPlaces = 2,
    this.decimalSeparator = ',',
    this.thousandSeparator = ' ',
    this.enableDigitAnimation = true,
    this.enableBounceEffect = true,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  double _previousValue = 0;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    // Animation principale avec courbe optimisée
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
    
    // Animation de scale pour l'effet de pulsation
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    _previousValue = widget.value;
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  String _formatNumber(double value) {
    // Format the number with specified decimal places
    String formattedValue = value.toStringAsFixed(widget.decimalPlaces);
    
    // Replace decimal separator
    if (widget.decimalSeparator != '.') {
      formattedValue = formattedValue.replaceAll('.', widget.decimalSeparator);
    }
    
    // Add thousand separator
    if (widget.thousandSeparator.isNotEmpty) {
      List<String> parts = formattedValue.split(widget.decimalSeparator);
    String integerPart = parts[0];
      String decimalPart = parts.length > 1 ? parts[1] : '';
      
      // Add thousand separators to integer part
      String reversedInteger = integerPart.split('').reversed.join('');
    String formattedInteger = '';
      for (int i = 0; i < reversedInteger.length; i++) {
        if (i > 0 && i % 3 == 0) {
        formattedInteger += widget.thousandSeparator;
      }
        formattedInteger += reversedInteger[i];
    }
      integerPart = formattedInteger.split('').reversed.join('');
      
      formattedValue = widget.decimalPlaces > 0 
          ? '$integerPart${widget.decimalSeparator}$decimalPart'
          : integerPart;
      }
    
    return '${widget.prefix}$formattedValue${widget.suffix}';
  }
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
      builder: (context, child) {
        // Interpolation entre l'ancienne et la nouvelle valeur
        final currentValue = _previousValue + 
            (widget.value - _previousValue) * _animation.value;
        
        Widget textWidget = Text(
          _formatNumber(currentValue),
          style: widget.style,
        );
        
        // Appliquer l'effet de rebond si activé
        if (widget.enableBounceEffect) {
          textWidget = Transform.scale(
            scale: _scaleAnimation.value,
            child: textWidget,
          );
        }
        
        return textWidget;
      },
      ),
    );
  }
}

/// Widget pour animer des chiffres individuellement avec un effet de roulement
class RollingDigitCounter extends StatefulWidget {
  final int value;
  final TextStyle style;
  final Duration duration;
  final int maxDigits;
  
  const RollingDigitCounter({
    Key? key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
    this.maxDigits = 6,
  }) : super(key: key);

  @override
  State<RollingDigitCounter> createState() => _RollingDigitCounterState();
}

class _RollingDigitCounterState extends State<RollingDigitCounter>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _previousValue = widget.value;
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.maxDigits,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.duration.inMilliseconds + (index * 100),
        ),
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );
    }).toList();
  }

  @override
  void didUpdateWidget(RollingDigitCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animateToNewValue();
    }
  }

  void _animateToNewValue() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].reset();
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
    _previousValue = widget.value;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<int> _getDigits(int value) {
    String valueStr = value.toString().padLeft(widget.maxDigits, '0');
    return valueStr.split('').map((e) => int.parse(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentDigits = _getDigits(widget.value);
    final previousDigits = _getDigits(_previousValue);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxDigits, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final currentDigit = currentDigits[index];
            final previousDigit = previousDigits[index];
            
            // Calculer la position Y pour l'effet de roulement
            final offset = (previousDigit - currentDigit) * 
                          (1 - _animations[index].value);
            
            return ClipRect(
              child: Transform.translate(
                offset: Offset(0, offset * 30), // 30 pixels par chiffre
                child: Text(
                  currentDigit.toString(),
                  style: widget.style,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
