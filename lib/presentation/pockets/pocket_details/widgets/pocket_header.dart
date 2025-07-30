import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/smart_back_button.dart';
import '../controllers/pocket_detail_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class PocketHeader extends StatelessWidget {
  final PocketDetailController controller;
  final bool isDark;

  const PocketHeader({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmartBackButton(
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  controller.isEditing ? 'Modifier le pocket' : controller.currentPocket.name,
                  key: ValueKey(controller.isEditing),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Bouton moderne avec micro-animation
          AnimatedScale(
            scale: controller.isSaving ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: GestureDetector(
              onTap: controller.isSaving ? null : () {
                HapticFeedback.lightImpact();
                try {
                  controller.toggleEditMode();
                  
                  // Afficher un message de succès si on sort du mode édition
                  if (!controller.isEditing) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Pocket mis à jour avec succès'),
                        backgroundColor: const Color(0xFF78D078),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Afficher une erreur si l'édition échoue
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de l\'édition: ${e.toString()}'),
                      backgroundColor: const Color(0xFFF48A99),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: controller.isSaving 
                    ? null
                    : LinearGradient(
                        colors: controller.isEditing 
                          ? [const Color(0xFF78D078).withValues(alpha: 0.8), const Color(0xFF78D078)]
                          : [controller.getPocketColor().withValues(alpha: 0.8), controller.getPocketColor()],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                  color: controller.isSaving 
                    ? (isDark ? AppColors.borderDark : AppColors.border)
                    : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: controller.isSaving ? null : [
                    BoxShadow(
                      color: (controller.isEditing ? const Color(0xFF78D078) : controller.getPocketColor()).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: controller.isSaving 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.textDark : AppColors.text
                        ),
                      ),
                    )
                  : Icon(
                      controller.isEditing ? HugeIcons.strokeRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedEdit02,
                      size: 20,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 