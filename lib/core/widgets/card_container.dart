import 'package:flutter/material.dart';
import '../constants/constants.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;

  const CardContainer({
    Key? key,
    required this.child,
    this.padding,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration ?? AppDecorations.getCardDecoration(context),
      padding: padding ?? AppPadding.card,
      child: child,
    );
  }
} 