import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../screens/home_page.dart';
import '../screens/statistics_page.dart';
import '../screens/transaction_history_page.dart';
import 'curved_navbar_painter.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Function()? onAddPressed;
  final bool showAddButton;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.onAddPressed,
    this.showAddButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Navbar container avec courbe au centre
        Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              height: 65, // Hauteur fixe pour la navbar
              child: CustomPaint(
                painter: CurvedNavBarPainter(
                  color: isDark 
                    ? AppColors.surfaceDark.withOpacity(0.8) 
                    : Colors.white.withOpacity(0.8),
                  borderColor: isDark 
                    ? AppColors.borderDark 
                    : const Color(0xFFD1D5DB),
                  borderWidth: 1.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_outlined, 'Home'),
                      _buildNavItem(1, Icons.pie_chart_outline, 'Analytics'),
                      // Espace pour le bouton central
                      const SizedBox(width: 60),
                      _buildNavItem(2, Icons.account_balance_wallet_outlined, 'Wallet'),
                      _buildNavItem(3, Icons.person_outline, 'Account'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Bouton d'ajout détaché
        if (showAddButton)
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              
              return Positioned(
                top: -30, // Position plus haute pour détacher davantage le bouton
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark 
                      ? AppColors.surfaceDark 
                      : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark 
                        ? AppColors.borderDark 
                        : const Color(0xFFD1D5DB), 
                      width: 1
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withOpacity(0.3) 
                          : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: GestureDetector(
                    onTap: onAddPressed,
                    child: Container(
                      width: 56, // Légèrement plus grand
                      height: 56, // Légèrement plus grand
                      decoration: const BoxDecoration(
                        color: Color(0xFF2842ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = index == currentIndex;
    
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return GestureDetector(
          onTap: () => onTap(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                  ? AppColors.primary 
                  : isDark ? AppColors.textDark : Colors.black,
                size: 26,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                    ? AppColors.primary 
                    : isDark ? AppColors.textDark : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddTransactionBottomSheet extends StatelessWidget {
  const AddTransactionBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.green),
            ),
            title: const Text('Ajouter un revenu'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implémenter l'ajout de revenu
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.remove, color: Colors.red),
            ),
            title: const Text('Ajouter une dépense'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implémenter l'ajout de dépense
            },
          ),
        ],
      ),
    );
  }
}
