import 'package:flutter/material.dart';

class CurvedNavBarPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  
  CurvedNavBarPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 1.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final curveHeight = 35.0; // Hauteur de la courbe augmentée
    final curveWidth = 80.0; // Largeur de la courbe augmentée
    final cornerRadius = 25.0; // Rayon des coins arrondis
    
    // Créer le chemin pour la forme de la navbar
    final path = Path();
    
    // Coin supérieur gauche arrondi
    path.moveTo(cornerRadius, 0);
    
    // Bord supérieur jusqu'au début de la courbe
    path.lineTo((width - curveWidth) / 2, 0);
    
    // Courbe supérieure (convexe vers le haut)
    path.quadraticBezierTo(
      width / 2, curveHeight, // Point de contrôle positif pour courbe convexe
      (width + curveWidth) / 2, 0,
    );
    
    // Bord supérieur après la courbe
    path.lineTo(width - cornerRadius, 0);
    
    // Coin supérieur droit arrondi
    path.arcToPoint(
      Offset(width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Bord droit
    path.lineTo(width, height - cornerRadius);
    
    // Coin inférieur droit arrondi
    path.arcToPoint(
      Offset(width - cornerRadius, height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Bord inférieur
    path.lineTo(cornerRadius, height);
    
    // Coin inférieur gauche arrondi
    path.arcToPoint(
      Offset(0, height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Bord gauche
    path.lineTo(0, cornerRadius);
    
    // Coin supérieur gauche arrondi
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Fermer le chemin
    path.close();
    
    // Dessiner la bordure
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    // Dessiner le fond
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
