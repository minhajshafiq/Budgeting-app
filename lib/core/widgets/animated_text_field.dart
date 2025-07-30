import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/constants.dart';
import '../../widgets/modern_animations.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? errorText;
  final Function(String)? onChanged;
  final bool enabled;
  final Widget? suffixIcon;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.onChanged,
    this.enabled = true,
    this.suffixIcon,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _errorController;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _labelColorAnimation;
  late Animation<double> _labelScaleAnimation;
  late Animation<Offset> _labelPositionAnimation;
  late Animation<double> _errorAnimation;

  bool _isFocused = false;
  bool _hasText = false;
  late FocusNode _focusNode;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    // Initialiser _hasText en vérifiant si le contrôleur a déjà du texte
    _hasText = widget.controller.text.isNotEmpty;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _labelAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _labelScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.75,
    ).animate(_labelAnimation);

    _labelPositionAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.8),
    ).animate(_labelAnimation);

    _errorAnimation = CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeOutBack,
    );

    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    
    // Si le contrôleur a déjà du texte, animer le label vers le haut
    if (_hasText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _updateLabelColorAnimation();
      _isInitialized = true;
    }
  }

  void _updateLabelColorAnimation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null;
    
    _labelColorAnimation = ColorTween(
      begin: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      end: hasError 
          ? Colors.red 
          : (_isFocused ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
    ).animate(_labelAnimation);
  }

  @override
  void didUpdateWidget(AnimatedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorText != widget.errorText) {
      if (widget.errorText != null) {
        _errorController.forward();
      } else {
        _errorController.reverse();
      }
      _updateLabelColorAnimation();
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    _updateLabelColorAnimation();
    _updateAnimation();
  }

  void _onTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      _updateAnimation();
    }
    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  void _updateAnimation() {
    if (_isFocused || _hasText) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _errorController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Champ de texte principal
              TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textCapitalization: widget.textCapitalization,
                enabled: widget.enabled,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: widget.icon != null
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: HugeIcon(
                            icon: widget.icon!,
                            color: hasError 
                                ? Colors.red 
                                : (_isFocused ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                            size: 22,
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: hasError 
                          ? Colors.red.withValues(alpha: 0.5)
                          : (isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.3)),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  contentPadding: EdgeInsets.only(
                    left: widget.icon != null ? 56 : 20,
                    right: 20,
                    top: 24,
                    bottom: 16,
                  ),
                ),
              ),
              
              // Label animé
              if (_isInitialized)
                Positioned(
                  left: widget.icon != null ? 56 : 20,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _labelAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _labelPositionAnimation.value * 16,
                          child: Transform.scale(
                            scale: _labelScaleAnimation.value,
                            alignment: Alignment.centerLeft,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedBuilder(
                                animation: _labelColorAnimation,
                                builder: (context, child) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _labelAnimation.value > 0.5 ? 4 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _labelAnimation.value > 0.5 
                                          ? (isDark ? AppColors.surfaceDark : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      widget.label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: _labelColorAnimation.value,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Message d'erreur animé
        if (hasError) ...[
          const SizedBox(height: 8),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(_errorAnimation),
            child: FadeTransition(
              opacity: _errorAnimation,
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedAlert01,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
} 