import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../core/constants/constants.dart';
import 'transaction_details_page.dart';
import '../../widgets/modern_animations.dart';
import '../../core/widgets/card_container.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/widgets/smart_back_button.dart';

class TransactionAmountPage extends StatefulWidget {
  final bool isIncome;
  final String transactionType;
  final double? initialAmount;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialImageUrl;
  final String? initialImagePath;
  
  const TransactionAmountPage({
    Key? key, 
    required this.isIncome,
    required this.transactionType,
    this.initialAmount,
    this.initialTitle,
    this.initialCategory,
    this.initialImageUrl,
    this.initialImagePath,
  }) : super(key: key);

  @override
  State<TransactionAmountPage> createState() => _TransactionAmountPageState();
}

class _TransactionAmountPageState extends State<TransactionAmountPage> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  String _amount = '0';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    // Préremplir les données si elles existent
    if (widget.initialAmount != null) {
      _amount = widget.initialAmount!.toStringAsFixed(2).replaceAll('.', ',');
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _startAnimations();
    _isInitialized = true;
    // Focus automatique sur le champ montant après un court délai
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        FocusScope.of(context).requestFocus(_amountFocusNode);
      }
    });
  }
  
  void _startAnimations() async {
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleContinue() {
    if (_amount.isEmpty || _amount == '0') {
      BubbleNotification.show(
        context,
        message: 'Veuillez entrer un montant valide',
        icon: Icons.warning_amber_outlined,
        color: AppColors.red,
      );
      return;
    }
    
    final double amount = double.parse(_amount.replaceAll(',', '.'));
    if (amount <= 0) {
      BubbleNotification.show(
        context,
        message: 'Le montant doit être supérieur à 0',
        icon: Icons.warning_amber_outlined,
        color: AppColors.red,
      );
      return;
    }
    
    // Navigate to next step with the amount
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailsPage(
          isIncome: widget.isIncome,
          transactionType: widget.transactionType,
          amount: amount,
          initialTitle: widget.initialTitle,
          initialCategory: widget.initialCategory,
          initialImageUrl: widget.initialImageUrl,
          initialImagePath: widget.initialImagePath,
        ),
      ),
    );
  }
  
  void _updateAmount(String digit) {
    setState(() {
      if (digit == ',' || digit == '.') {
        // Handle decimal point
        if (!_amount.contains(',')) {
          _amount = _amount == '0' ? '0,' : '$_amount,';
        }
      } else if (digit == '⌫') {
        // Handle backspace
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
        }
      } else {
        // Handle digit
        if (_amount == '0') {
          _amount = digit;
        } else {
          _amount = '$_amount$digit';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? AppColors.backgroundDark : AppColors.background;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header - Espace fixe réduit
            SlideInAnimation(
              beginOffset: const Offset(0, -0.3),
              duration: const Duration(milliseconds: 600),
              child: _isInitialized 
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeader(),
                  )
                : _buildHeader(),
            ),
            
            // Progress indicator - Espace fixe réduit
            SlideInAnimation(
              beginOffset: const Offset(-0.3, 0),
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 700),
                child: _isInitialized 
                  ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildProgressIndicator(),
                    )
                  : _buildProgressIndicator(),
            ),
            
            // Amount display avec bouton continuer intégré
            Expanded(
              child: SlideInAnimation(
                beginOffset: const Offset(0, 0.3),
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 700),
                child: _isInitialized 
                  ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAmountDisplayWithButton(),
                    )
                  : _buildAmountDisplayWithButton(),
              ),
            ),
            
            // Espace en bas qui s'adapte au clavier
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    final Color backgroundColor = isDark ? AppColors.backgroundDark : AppColors.background;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        children: [
          // Bouton retour simple
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 20,
                  color: textColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.isIncome ? 'Ajouter un revenu' : 'Ajouter une dépense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Étape 1/3',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bouton de fermeture minimaliste
          GestureDetector(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Montant de la transaction',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '33%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.33,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Étape 1 sur 3 • Commencez par le montant',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmountDisplayWithButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    final bool canContinue = _amount != '0' && _amount.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône et titre - Plus compact
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isIncome 
                  ? [AppColors.green, AppColors.green.withValues(alpha: 0.8)]
                  : [AppColors.red, AppColors.red.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isIncome ? AppColors.green : AppColors.red).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: HugeIcon(
                icon: widget.isIncome 
                  ? HugeIcons.strokeRoundedMoney01 
                  : HugeIcons.strokeRoundedShoppingBag01,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.isIncome ? 'Montant reçu' : 'Montant dépensé',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Affichage UI/UX du montant (comme avant) mais cliquable pour focus
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_amountFocusNode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.isIncome ? '+' : '-',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: widget.isIncome ? AppColors.green : AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _amount,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '€',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // TextField natif invisible pour déclencher le clavier et gérer la saisie
          Opacity(
            opacity: 0.0,
            child: Container(
              height: 1,
              width: 60,
              alignment: Alignment.center,
              child: TextField(
                focusNode: _amountFocusNode,
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _amount = value.replaceAll(',', '.');
                    if (_amount.isEmpty) _amount = '0';
                  });
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]{0,2}')),
                ],
                textInputAction: TextInputAction.done,
                autofocus: true,
                enableInteractiveSelection: false,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Bouton continuer intégré
          ModernRippleEffect(
            onTap: canContinue ? _handleContinue : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: canContinue
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                    )
                  : null,
                color: canContinue ? null : (isDark ? AppColors.borderDark : AppColors.border),
                borderRadius: BorderRadius.circular(26),
                boxShadow: canContinue ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canContinue 
                        ? Colors.white 
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: canContinue 
                      ? Colors.white 
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}