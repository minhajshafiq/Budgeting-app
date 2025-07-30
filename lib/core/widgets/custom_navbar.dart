import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:hugeicons/hugeicons.dart';
import '../constants/constants.dart';
import '../../screens/add_transaction/transaction_amount_page.dart';
import '../../widgets/modern_animations.dart' as animations;
import '../../screens/add_transaction/index.dart';

class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Function()? onAddPressed;
  final bool showAddButton;
  final bool enableHapticFeedback;
  final IconData? customAddIcon;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.onAddPressed,
    this.showAddButton = true,
    this.enableHapticFeedback = true,
    this.customAddIcon,
  }) : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> 
    with TickerProviderStateMixin {
  late AnimationController _addButtonController;
  late AnimationController _selectionController;
  late AnimationController _glowController;
  late Animation<double> _addButtonScale;
  late Animation<double> _addButtonRotation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _glowAnimation;
  
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _addButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _selectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _addButtonScale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _addButtonController,
      curve: Curves.easeInOut,
    ));
    
    _addButtonRotation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrés en radians / 8
    ).animate(CurvedAnimation(
      parent: _addButtonController,
      curve: Curves.easeInOut,
    ));
    
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOutBack,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _previousIndex = widget.currentIndex;
    _glowController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _selectionController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _addButtonController.dispose();
    _selectionController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // Méthode utilitaire pour obtenir le nom de la page
  String _getPageName(int index) {
    switch (index) {
      case 0:
        return 'Accueil';
      case 1:
        return 'Analytics';
      case 2:
        return 'Pockets';
      case 3:
        return 'Compte';
      default:
        return 'Page';
    }
  }

  void _showAddTransactionModal() {
    if (widget.onAddPressed != null) {
      widget.onAddPressed!();
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: Platform.isAndroid ? MediaQuery.of(context).padding.bottom : 0,
          ),
          child: const ModernAddTransactionBottomSheet(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAndroid = Platform.isAndroid;
            
            return Container(
      margin: EdgeInsets.fromLTRB(
        16, 
        0, 
        16, 
        isAndroid ? 16 : 20,
      ),
      height: 58,
      decoration: BoxDecoration(
        // Clean background without glassmorphism
        color: isDark 
          ? const Color(0xFF1E1E1E)  // Solid dark color
          : Colors.white,
        borderRadius: BorderRadius.circular(28),
        
        // Clean borders
        border: Border.all(
          color: isDark 
            ? const Color(0xFF2C2C2C)
            : const Color(0xFFE5E7EB),
          width: 1,
        ),
        
        // Clean, minimal shadows
        boxShadow: [
          if (!isDark) // Only shadows for light mode
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          // Very subtle shadow for dark mode
          if (isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
        ],
      ),
                      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildAnimatedNavItem(0, 'Home'),
                          _buildAnimatedNavItem(1, 'Analytics'),
          // Enhanced center add button
          widget.showAddButton ? _buildCenterAddButton() : const SizedBox(width: 50),
                          _buildAnimatedNavItem(2, 'Wallet'),
                          _buildAnimatedNavItem(3, 'Account'),
                        ],
                      ),
    );
  }

  Widget _buildCenterAddButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTapDown: (_) {
                _addButtonController.forward();
                if (widget.enableHapticFeedback) {
                  HapticFeedback.mediumImpact();
                }
              },
              onTapUp: (_) {
                _addButtonController.reverse();
                _showAddTransactionModal();
              },
              onTapCancel: () {
                _addButtonController.reverse();
              },
              child: AnimatedBuilder(
              animation: Listenable.merge([_addButtonController, _glowController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _addButtonScale.value,
                    child: Transform.rotate(
                      angle: _addButtonRotation.value * 2 * 3.14159,
                      child: Container(
                      width: 38,
                      height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        
                        // Enhanced gradient for dark mode
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          colors: isDark ? [
                            const Color(0xFF6366F1),
                            const Color(0xFF4338CA),
                            const Color(0xFF3730A3),
                          ] : [
                            const Color(0xFF4C6EF5),
                            const Color(0xFF2842ED),
                            ],
                          ),
                        
                                                 // Clean shadows
                          boxShadow: [
                           // Main shadow - much cleaner
                            BoxShadow(
                             color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF2842ED))
                                 .withValues(alpha: isDark ? 0.3 * _glowAnimation.value : 0.4),
                             blurRadius: isDark ? 8 : 8,
                              spreadRadius: 0,
                            offset: const Offset(0, 3),
                           ),
                           // Very subtle secondary shadow for dark mode
                           if (isDark)
                             BoxShadow(
                               color: Colors.black.withValues(alpha: 0.1),
                               blurRadius: 4,
                               spreadRadius: 0,
                               offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: widget.customAddIcon ?? HugeIcons.strokeRoundedAdd01,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
          ),
    );
  }

  Widget _buildAnimatedNavItem(int index, String label) {
    final bool isSelected = index == widget.currentIndex;
    
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return GestureDetector(
          onTap: () {
            if (widget.enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            widget.onTap(index);
          },
          child: Container(
            width: 50,
            height: 58,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 40 : 38,
                  height: isSelected ? 40 : 38,
                  decoration: isSelected ? BoxDecoration(
                    // Clean selection background
                    color: isDark 
                      ? const Color(0xFF5B67FD).withValues(alpha: 0.12)
                      : const Color(0xFF5B67FD).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ) : null,
                  child: Center(
                    child: _buildNavIcon(index, isSelected, isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(int index, bool isSelected, bool isDark) {
    // Enhanced color scheme for dark mode
    Color color;
    if (isSelected) {
      color = const Color(0xFF5B67FD);
    } else if (isDark) {
      color = const Color(0xFFAAAAAA); // Softer gray for dark mode
    } else {
      color = const Color(0xFF6B7280); // Better contrast for light mode
    }
    
    switch (index) {
      case 0:
        return HugeIcon(
          icon: HugeIcons.strokeRoundedHome01,
          size: isSelected ? 24 : 22,
          color: color,
        );
      case 1:
        return HugeIcon(
          icon: HugeIcons.strokeRoundedPieChart,
          size: isSelected ? 24 : 22,
          color: color,
        );
      case 2:
        return HugeIcon(
          icon: HugeIcons.strokeRoundedWallet01,
          size: isSelected ? 24 : 22,
          color: color,
        );
      case 3:
        return HugeIcon(
          icon: HugeIcons.strokeRoundedUser,
          size: isSelected ? 24 : 22,
          color: color,
        );
      default:
        return HugeIcon(
          icon: HugeIcons.strokeRoundedHome01,
          size: isSelected ? 24 : 22,
          color: color,
        );
    }
  }
}

class ModernAddTransactionBottomSheet extends StatefulWidget {
  const ModernAddTransactionBottomSheet({Key? key}) : super(key: key);

  @override
  State<ModernAddTransactionBottomSheet> createState() => _ModernAddTransactionBottomSheetState();
}

class _ModernAddTransactionBottomSheetState extends State<ModernAddTransactionBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _slideController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 100),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Icône friendly
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedWallet01,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    Text(
                      'Ajouter une transaction',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDark : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Que souhaitez-vous enregistrer ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  animations.SlideInAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: _buildTransactionOption(
                      context,
                      icon: HugeIcons.strokeRoundedMoney01,
                      title: '💰 J\'ai reçu de l\'argent',
                      subtitle: 'Salaire, cadeau, remboursement...',
                      color: AppColors.green, // Vert discret pour les positifs
                      gradient: [
                        AppColors.green,  // Vert discret pour les positifs
                        AppColors.green.withValues(alpha: 0.7),
                      ],
                      onTap: () {
                        Navigator.pop(context);
                        // Start the multi-step flow for income
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionAmountPage(
                              isIncome: true,
                              transactionType: 'income',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  animations.SlideInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: _buildTransactionOption(
                      context,
                      icon: HugeIcons.strokeRoundedShoppingBag01,
                      title: '🛍️ J\'ai dépensé de l\'argent',
                      subtitle: 'Courses, sorties, factures...',
                      color: AppColors.red, // Rouge soft pour les warnings/dépenses
                      gradient: [
                        AppColors.red,  // Rouge soft pour les warnings/dépenses
                        AppColors.red.withValues(alpha: 0.7),
                      ],
                      onTap: () {
                        Navigator.pop(context);
                        // Start the multi-step flow for expense
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionAmountPage(
                              isIncome: false,
                              transactionType: 'expense',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return animations.ModernRippleEffect(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: HugeIcon(
                icon: icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
