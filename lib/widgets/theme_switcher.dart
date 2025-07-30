import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    HapticFeedback.selectionClick();
    themeProvider.toggleTheme();
    
    // Animation for visual feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return GestureDetector(
          onTap: _toggleTheme,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - (_animationController.value * 0.05),
                child: Container(
                  width: 64,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDarkMode 
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade300,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: isDarkMode ? 12 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                                                 child: AnimatedSwitcher(
                           duration: const Duration(milliseconds: 200),
                           child: isDarkMode
                               ? const HugeIcon(
                                   key: ValueKey('crescent'),
                                   icon: HugeIcons.strokeRoundedMoon02,
                                   color: Color(0xFF6366F1),
                                   size: 16,
                                 )
                               : const HugeIcon(
                                   key: ValueKey('sun'),
                                   icon: HugeIcons.strokeRoundedSun03,
                                   color: Colors.orange,
                                   size: 16,
                                 ),
                         ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 