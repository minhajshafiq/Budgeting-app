import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final int decimalPlaces;
  final String decimalSeparator;
  final String thousandSeparator;
  
  const AnimatedCounter({
    Key? key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1500),
    this.decimalPlaces = 2,
    this.decimalSeparator = ',',
    this.thousandSeparator = ' ',
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
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
      curve: Curves.easeOutCubic,
    );
    
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
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
    // Arrondir à la précision demandée
    double roundedValue = (value * pow(10, widget.decimalPlaces)).round() / pow(10, widget.decimalPlaces);
    
    // Séparer la partie entière et décimale
    String valueStr = roundedValue.toString();
    List<String> parts = valueStr.split('.');
    
    // Formater la partie entière avec des séparateurs de milliers
    String integerPart = parts[0];
    String formattedInteger = '';
    
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += widget.thousandSeparator;
      }
      formattedInteger += integerPart[i];
    }
    
    // Formater la partie décimale
    String decimalPart = '';
    if (parts.length > 1) {
      decimalPart = parts[1];
      // Ajouter des zéros si nécessaire
      while (decimalPart.length < widget.decimalPlaces) {
        decimalPart += '0';
      }
      // Tronquer si trop long
      if (decimalPart.length > widget.decimalPlaces) {
        decimalPart = decimalPart.substring(0, widget.decimalPlaces);
      }
    } else {
      // Ajouter des zéros si pas de partie décimale
      for (int i = 0; i < widget.decimalPlaces; i++) {
        decimalPart += '0';
      }
    }
    
    // Assembler le résultat final
    return widget.prefix + formattedInteger + 
           (widget.decimalPlaces > 0 ? widget.decimalSeparator + decimalPart : '') + 
           widget.suffix;
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = widget.value * _animation.value;
        return Text(
          _formatNumber(value),
          style: widget.style,
        );
      },
    );
  }
}
