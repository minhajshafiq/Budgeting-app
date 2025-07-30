import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/constants.dart';

class LineChart extends StatelessWidget {
  final Animation<double> animation;
  final List<Map<String, dynamic>> data;
  final bool showAllLabels;
  final String? selectedDay;
  final Function(String)? onBarTap;

  const LineChart({
    super.key,
    required this.animation,
    required this.data,
    this.showAllLabels = false,
    this.selectedDay,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SizedBox(
          height: 200,
          child: GestureDetector(
            onTapDown: (details) => _handleTapDown(details.localPosition),
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: LineChartPainter(
                data: data,
                animationProgress: animation.value,
                showAllLabels: showAllLabels,
                selectedDay: selectedDay,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown(Offset position) {
    if (onBarTap == null) return;
    
    // Calculer les dimensions (répliquer la logique du painter)
    final chartWidth = 400.0 - 40.0; // Approximation de la largeur
    final pointWidth = chartWidth / data.length;
    
    for (int i = 0; i < data.length; i++) {
      final x = 20.0 + (i * chartWidth / (data.length - 1));
      final tapArea = Rect.fromCenter(
        center: Offset(x, 100), // Position approximative
        width: pointWidth,
        height: 200,
      );
      
      if (tapArea.contains(position)) {
        HapticFeedback.lightImpact();
        onBarTap!(data[i]['period'] as String);
        return;
      }
    }
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double animationProgress;
  final bool showAllLabels;
  final String? selectedDay;
  final bool isDark;

  LineChartPainter({
    required this.data,
    required this.animationProgress,
    required this.showAllLabels,
    required this.selectedDay,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill;

    final selectedPointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primary;

    final selectedPointBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white;

    // Calculer les dimensions
    final chartWidth = size.width - 40.0; // Marges latérales
    final chartHeight = 140.0; // Hauteur du graphique
    final chartTop = 40.0; // Espace pour les prix
    final chartBottom = chartTop + chartHeight;

    // Trouver la valeur maximale pour normaliser
    final maxValue = data.fold<double>(0, (max, item) => 
      (item['expense'] as double) > max ? (item['expense'] as double) : max);

    if (maxValue == 0) return;

    // Créer le chemin de la ligne
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = 20 + (i * chartWidth / (data.length - 1));
      final normalizedValue = (data[i]['expense'] as double) / maxValue;
      final y = chartBottom - (normalizedValue * chartHeight * animationProgress);
      
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Déterminer l'opacity de base
    final hasSelection = selectedDay != null;
    final baseOpacity = hasSelection ? 0.5 : 1.0;
    
    // Dessiner le dégradé sous la ligne
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.3 * baseOpacity),
          AppColors.primary.withValues(alpha: 0.05 * baseOpacity),
        ],
      ).createShader(Rect.fromLTWH(0, chartTop, size.width, chartHeight));

    final gradientPath = Path.from(path);
    gradientPath.lineTo(points.last.dx, chartBottom);
    gradientPath.lineTo(points.first.dx, chartBottom);
    gradientPath.close();

    canvas.drawPath(gradientPath, gradientPaint);

    // Dessiner la ligne principale
    paint.color = AppColors.primary.withValues(alpha: baseOpacity);
    canvas.drawPath(path, paint);

    // Dessiner les points et labels
    for (int i = 0; i < data.length && i < points.length; i++) {
      final point = points[i];
      final dayData = data[i];
      final period = dayData['period'] as String;
      final expense = dayData['expense'] as double;
      final isSelected = selectedDay == period;
      final shouldDimUnselected = hasSelection && !isSelected;
      final opacity = shouldDimUnselected ? 0.3 : 1.0;

      // Dessiner le point
      if (isSelected) {
        // Point sélectionné avec bordure blanche
        canvas.drawCircle(point, 8.0, selectedPointBorderPaint);
        canvas.drawCircle(point, 6.0, selectedPointPaint);
      } else {
        // Point normal avec opacity
        pointPaint.color = AppColors.primary.withValues(alpha: opacity);
        canvas.drawCircle(point, 4.0, pointPaint);
      }

      // Dessiner les labels de jours
      final dayTextPainter = TextPainter(
        text: TextSpan(
          text: period,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected 
              ? AppColors.primary 
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: opacity),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      dayTextPainter.layout();
      
      final dayTextOffset = Offset(
        point.dx - dayTextPainter.width / 2,
        chartBottom + 10,
      );
      dayTextPainter.paint(canvas, dayTextOffset);

      // Dessiner les prix (si activé ou sélectionné)
      if (showAllLabels || isSelected) {
        final priceText = '${expense.toStringAsFixed(2)}€';
        final priceTextPainter = TextPainter(
          text: TextSpan(
            text: priceText,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected 
                ? AppColors.primary 
                : (isDark ? AppColors.textDark : AppColors.text).withValues(alpha: opacity),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        priceTextPainter.layout();
        
        final priceTextOffset = Offset(
          point.dx - priceTextPainter.width / 2,
          point.dy - 20,
        );
        priceTextPainter.paint(canvas, priceTextOffset);
      }
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
           oldDelegate.selectedDay != selectedDay ||
           oldDelegate.showAllLabels != showAllLabels;
  }
} 