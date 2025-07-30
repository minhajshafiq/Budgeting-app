import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/constants.dart';

class BarChart extends StatelessWidget {
  final Animation<double> animation;
  final List<Map<String, dynamic>> data;
  final Set<String> daysWithLabel;
  final bool showAllLabels;
  final Function(String day)? onBarTap;
  final String? selectedDay;
  final bool compact; // Nouvelle option pour la version compacte

  const BarChart({
    Key? key,
    required this.animation,
    required this.data,
    this.daysWithLabel = const {'Thu', 'Sun', 'Tue', 'Sat'},
    this.showAllLabels = false,
    this.onBarTap,
    this.selectedDay,
    this.compact = false, // Par défaut, version normale
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = 145.0; // Hauteur identique à la page statistiques
    
    // Vérifier que les données sont valides
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((item) {
            return Expanded(
              child: _buildBar(context, item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, Map<String, dynamic> item) {
    final isSelected = selectedDay == item['day'];
    final amount = item['amount'] as double? ?? 0.0; // valeur normalisée pour la hauteur
    final expense = item['expense'] as double? ?? 0.0; // valeur réelle pour l'affichage
    final hasValue = expense > 0;
    final hasSelection = selectedDay != null;
    final shouldDimUnselected = hasSelection && !isSelected;
    
    // Gérer la couleur de manière sûre
    Color getBarColor() {
      if (isSelected) {
        return AppColors.primary;
      }
      
      final itemColor = item['color'];
      if (itemColor is Color) {
        return itemColor;
      }
      
      // Couleur par défaut avec dégradé basé sur l'index
      final dayIndex = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].indexOf(item['day'] as String? ?? '');
      if (dayIndex >= 0) {
        final colors = [
          AppColors.barMon,
          AppColors.barTue,
          AppColors.barWed,
          AppColors.barThu,
          AppColors.barFri,
          AppColors.barSat,
          AppColors.barSun,
        ];
        return colors[dayIndex];
      }
      
      return AppColors.primary.withValues(alpha: 0.7);
    }
    
    return GestureDetector(
      onTap: hasValue ? () {
        if (onBarTap != null) {
          HapticFeedback.lightImpact();
          onBarTap!(item['day'] as String);
        }
      } : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: shouldDimUnselected ? 0.3 : 1.0,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Afficher le label seulement si la valeur > 0 et si autorisé
              if (hasValue && (showAllLabels || daysWithLabel.contains(item['day'])))
                Container(
                  height: 14,
                  child: Text(
                  item['value'] as String? ?? '${expense.toStringAsFixed(0)}€',
                  style: AppTextStyles.barValue(context).copyWith(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                SizedBox(height: 14), // Espacement identique à la page statistiques
              SizedBox(height: 6), // Espacement identique à la page statistiques
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  const minHeight = 8.0;
                  final calculatedHeight = amount * animation.value;
                  final finalHeight = calculatedHeight < minHeight ? minHeight : calculatedHeight;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30, // Largeur identique à la page statistiques
                    height: finalHeight,
                    decoration: BoxDecoration(
                      color: getBarColor(),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: isSelected 
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
              SizedBox(height: 6), // Espacement identique à la page statistiques
              Container(
                height: 18,
                child: Text(
                  item['day'] as String? ?? 'N/A',
                style: GoogleFonts.inter(
                    fontSize: 12, // Taille identique à la page statistiques
                  color: isSelected 
                      ? AppColors.primary 
                      : (Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
