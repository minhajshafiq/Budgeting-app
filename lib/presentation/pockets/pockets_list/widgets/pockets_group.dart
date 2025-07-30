import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../data/models/pocket.dart';
import '../controllers/pockets_list_controller.dart';
import 'pocket_card.dart';
import 'package:hugeicons/hugeicons.dart';

class PocketsGroup extends StatelessWidget {
  final PocketType type;
  final List<Pocket> pockets;
  final PocketsListController controller;
  final bool isDark;
  final AnimationController cardAnimationController;

  const PocketsGroup({
    super.key,
    required this.type,
    required this.pockets,
    required this.controller,
    required this.isDark,
    required this.cardAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    if (pockets.isEmpty) return const SizedBox.shrink();
    
    String typeLabel;
    IconData typeIcon;
    Color typeColor;
    
    switch (type) {
      case PocketType.needs:
        typeLabel = 'Besoins Essentiels';
        typeIcon = HugeIcons.strokeRoundedHome01;
        typeColor = const Color(0xFFF48A99);
        break;
      case PocketType.wants:
        typeLabel = 'Envies & Loisirs';
        typeIcon = HugeIcons.strokeRoundedGameController01;
        typeColor = const Color(0xFF78D078);
        break;
      case PocketType.savings:
        typeLabel = 'Épargne & Objectifs';
        typeIcon = HugeIcons.strokeRoundedPiggyBank;
        typeColor = const Color(0xFF6BC6EA);
        break;
      default:
        typeLabel = 'Autres';
        typeIcon = HugeIcons.strokeRoundedWallet01;
        typeColor = const Color(0xFF6B7280);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${pockets.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark 
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        
        // Liste des pockets
        ...pockets.asMap().entries.map((entry) {
          final index = entry.key;
          final pocket = entry.value;
          
          return AnimatedBuilder(
            animation: cardAnimationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final normalizedValue = ((cardAnimationController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
              final animationValue = Curves.easeOutBack.transform(normalizedValue).clamp(0.0, 1.0);
              
              return Transform.translate(
                offset: Offset(0, (1 - animationValue) * 30),
                child: Opacity(
                  opacity: animationValue.clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key(pocket.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        // Afficher une boîte de dialogue de confirmation
                        return await _showDeleteConfirmation(context, pocket);
                      },
                      onDismissed: (direction) {
                        // La suppression sera gérée dans confirmDismiss
                      },
                      background: _buildDeleteBackground(),
                      child: PocketCard(
                        pocket: pocket,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
        
        const SizedBox(height: 24),
      ],
    );
  }

  // Afficher la boîte de dialogue de confirmation de suppression
  Future<bool> _showDeleteConfirmation(BuildContext context, Pocket pocket) async {
    // Vérifier si c'est une pocket importante (par défaut)
    final defaultPocketNames = [
      'Logement', 'Alimentation', 'Transport', 'Factures & Assurances',
      'Sorties & Restaurants', 'Shopping & Vêtements', 'Abonnements & Divertissement',
      'Fonds d\'urgence', 'Vacances d\'été', 'Achat immobilier', 'Retraite'
    ];
    
    final isImportantPocket = defaultPocketNames.contains(pocket.name);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: const Color(0xFFDC2626),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Supprimer la pocket',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isImportantPocket) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: const Color(0xFFDC2626), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cette pocket fait partie des pockets par défaut.',
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Flexible(
                  child: Text(
                    'Êtes-vous sûr de vouloir supprimer la pocket "${pocket.name}" ?\n\nCette action est irréversible et supprimera définitivement la pocket.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Flexible(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Flexible(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    // Si l'utilisateur confirme, supprimer la pocket
    if (result) {
      await controller.deletePocket(context, pocket);
    }

    return result;
  }

  // Construire l'arrière-plan de suppression
  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 