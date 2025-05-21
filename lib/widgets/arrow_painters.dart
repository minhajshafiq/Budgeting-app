import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Un painter personnalisé qui dessine une flèche vers le bas
class ArrowDownPainter extends CustomPainter {
  final Color color;
  
  ArrowDownPainter({this.color = AppColors.red});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.35); // Point de départ en haut à gauche
    path.lineTo(size.width * 0.5, size.height * 0.75);  // Milieu bas
    path.lineTo(size.width * 0.75, size.height * 0.35); // Point final en haut à droite
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Un painter personnalisé qui dessine une flèche vers le haut (rouge)
class ArrowUpRedPainter extends CustomPainter {
  final Color color;
  
  ArrowUpRedPainter({this.color = AppColors.red});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.65); // Point de départ en bas à gauche
    path.lineTo(size.width * 0.5, size.height * 0.25);  // Milieu haut
    path.lineTo(size.width * 0.75, size.height * 0.65); // Point final en bas à droite
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Un painter personnalisé qui dessine une flèche vers le bas (rouge)
class ArrowDownRedPainter extends CustomPainter {
  final Color color;
  
  ArrowDownRedPainter({this.color = AppColors.red});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final path = Path();
    // Ligne principale
    path.moveTo(size.width * 0.75, size.height * 0.35); // Point de départ en haut à droite
    path.lineTo(size.width * 0.25, size.height * 0.75); // Point d'arrivée en bas à gauche
    
    // Tête de flèche
    path.moveTo(size.width * 0.25, size.height * 0.75); // Point d'arrivée
    path.lineTo(size.width * 0.25, size.height * 0.5); // Première extrémité de la tête
    
    path.moveTo(size.width * 0.25, size.height * 0.75); // Point d'arrivée
    path.lineTo(size.width * 0.5, size.height * 0.75); // Deuxième extrémité de la tête
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Un painter personnalisé qui dessine une flèche diagonale vers le haut-droite (pour les dépenses)
class ArrowUpRightPainter extends CustomPainter {
  final Color color;
  
  ArrowUpRightPainter({this.color = AppColors.red});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path();
    
    // Ligne principale de la flèche (diagonale vers le haut-droite)
    path.moveTo(size.width * 0.3, size.height * 0.7); // Point de départ en bas à gauche
    path.lineTo(size.width * 0.7, size.height * 0.3); // Point d'arrivée en haut à droite
    
    // Dessiner les deux extrémités de la tête de la flèche
    path.moveTo(size.width * 0.7, size.height * 0.3); // Point d'arrivée
    path.lineTo(size.width * 0.7, size.height * 0.5); // Première extrémité de la tête
    
    path.moveTo(size.width * 0.7, size.height * 0.3); // Point d'arrivée
    path.lineTo(size.width * 0.5, size.height * 0.3); // Deuxième extrémité de la tête
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Un painter personnalisé qui dessine une flèche diagonale vers le bas-gauche (pour les revenus)
class ArrowDownLeftPainter extends CustomPainter {
  final Color color;
  
  ArrowDownLeftPainter({this.color = AppColors.green});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final path = Path();
    // Ligne principale
    path.moveTo(size.width * 0.7, size.height * 0.3); // Point de départ en haut à droite
    path.lineTo(size.width * 0.3, size.height * 0.7); // Point d'arrivée en bas à gauche
    
    // Tête de flèche
    path.moveTo(size.width * 0.3, size.height * 0.7); // Point d'arrivée
    path.lineTo(size.width * 0.3, size.height * 0.5); // Première extrémité de la tête
    
    path.moveTo(size.width * 0.3, size.height * 0.7); // Point d'arrivée
    path.lineTo(size.width * 0.5, size.height * 0.7); // Deuxième extrémité de la tête
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Un painter personnalisé qui dessine une flèche vers le haut
class ArrowUpPainter extends CustomPainter {
  final Color color;
  
  ArrowUpPainter({this.color = AppColors.red});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.65); // Point de départ en bas à gauche
    path.lineTo(size.width * 0.5, size.height * 0.25);  // Milieu haut
    path.lineTo(size.width * 0.75, size.height * 0.65); // Point final en bas à droite
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 