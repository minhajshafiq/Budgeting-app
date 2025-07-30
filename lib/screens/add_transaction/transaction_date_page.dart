import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../core/constants/constants.dart';
import '../../widgets/modern_animations.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../core/widgets/card_container.dart';
import 'transaction_summary_page.dart';

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  quarterly,
  annual
}

class TransactionDatePage extends StatefulWidget {
  final bool isIncome;
  final String transactionType;
  final double amount;
  final String title;
  final String category;
  final String? imageUrl;
  final String? imagePath;
  
  const TransactionDatePage({
    Key? key, 
    required this.isIncome,
    required this.transactionType,
    required this.amount,
    required this.title,
    required this.category,
    this.imageUrl,
    this.imagePath,
  }) : super(key: key);

  @override
  State<TransactionDatePage> createState() => _TransactionDatePageState();
}

class _TransactionDatePageState extends State<TransactionDatePage> with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    
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
  }
  
  void _startAnimations() async {
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleContinue() {
    // Create the transaction data
    final Map<String, dynamic> transactionData = {
      'title': widget.title,
      'amount': widget.isIncome 
          ? '+${widget.amount.toStringAsFixed(2)}€' 
          : '-${widget.amount.toStringAsFixed(2)}€',
      'date': '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
      'category': widget.category,
      'isIncome': widget.isIncome,
      'recurrence': _selectedRecurrence.toString().split('.').last,
      'imageUrl': widget.imageUrl,
      'imagePath': widget.imagePath,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    // Navigate to summary page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionSummaryPage(
          transactionData: transactionData,
        ),
      ),
    );
  }
  
  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textDark
                  : AppColors.text,
            ),
            dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.backgroundDark
                : Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final Color cardColor = backgroundColor;
    
    return Scaffold(
      backgroundColor: backgroundColor,
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
            
            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Résumé de transaction - Espace fixe
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.3),
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 700),
                      child: _isInitialized 
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildTransactionSummary(),
                          )
                        : _buildTransactionSummary(),
                    ),
                    
                    // Sélection de date - Card moderne
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.4),
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 700),
                      child: _isInitialized 
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildDateSelectionCard(),
                          )
                        : _buildDateSelectionCard(),
                    ),
                    
                    // Sélection de récurrence - Card moderne
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.5),
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 700),
                      child: _isInitialized 
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildRecurrenceSelectionCard(),
                          )
                        : _buildRecurrenceSelectionCard(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton continuer - Maintenant dans le scroll
                    SlideInAnimation(
                      beginOffset: const Offset(0, 0.5),
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 700),
                      child: _isInitialized 
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildContinueButton(),
                          )
                        : _buildContinueButton(),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
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
                    'Étape 3/3',
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
                        '3',
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
                    'Date et récurrence',
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
                  '100%',
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
              widthFactor: 1.0,
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
            'Étape 3 sur 3 • Finalisez votre transaction',
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
  
  Widget _buildTransactionSummary() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isIncome 
              ? [
                  AppColors.green.withOpacity(0.1),
                  AppColors.green.withOpacity(0.05),
                ]
              : [
                  AppColors.red.withOpacity(0.1),
                  AppColors.red.withOpacity(0.05),
                ],
          ),
          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
            color: widget.isIncome 
              ? AppColors.green.withOpacity(0.2)
              : AppColors.red.withOpacity(0.2),
                            width: 1,
                          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isIncome ? AppColors.green : AppColors.red).withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
                        ),
        child: Row(
                              children: [
                                Container(
              width: 52,
              height: 52,
                                  decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isIncome 
                    ? [AppColors.green, AppColors.green.withOpacity(0.8)]
                    : [AppColors.red, AppColors.red.withOpacity(0.8)],
                ),
                                    shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isIncome ? AppColors.green : AppColors.red).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                                  ),
              child: Center(
                child: HugeIcon(
                  icon: widget.isIncome 
                    ? HugeIcons.strokeRoundedArrowDown01 
                    : HugeIcons.strokeRoundedArrowUp01,
                  color: Colors.white,
                  size: 24,
                ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.text,
                                        ),
                                      ),
                  const SizedBox(height: 4),
                                      Text(
                                        widget.category,
                                        style: TextStyle(
                      fontSize: 14,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                                Text(
              '${widget.isIncome ? '+' : '-'}${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}€',
                                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                                    color: widget.isIncome ? AppColors.green : AppColors.red,
                                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Montant',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
                                ),
                              ],
                            ),
                        ),
    );
  }
  
  Widget _buildDateSelectionCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar01,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date de la transaction",
                        style: TextStyle(
              fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
          const SizedBox(height: 4),
                      Text(
                        "Quand cette transaction a-t-elle eu lieu ?",
                        style: TextStyle(
              fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Date sélectionnée avec design moderne
            GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [
                          AppColors.backgroundDark,
                          AppColors.backgroundDark.withOpacity(0.8),
                        ]
                      : [
                          AppColors.background.withOpacity(0.8),
                          AppColors.background.withOpacity(0.6),
                        ],
                  ),
                    borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                            ),
                    boxShadow: [
                      BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                        spreadRadius: 0,
                      offset: const Offset(0, 2),
                      ),
                    ],
                          ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                              "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                                style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getDayOfWeek(_selectedDate),
                              style: TextStyle(
                                fontSize: 14,
                          fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedEdit02,
                                  color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Boutons rapides pour dates avec design moderne
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickDateButton("Aujourd'hui", DateTime.now()),
                SizedBox(width: 8),
                _buildQuickDateButton("Hier", DateTime.now().subtract(const Duration(days: 1))),
                SizedBox(width: 8),
                _buildQuickDateButton("Avant-hier", DateTime.now().subtract(const Duration(days: 2))),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickDateButton(String label, DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = _selectedDate.year == date.year && 
                            _selectedDate.month == date.month && 
                            _selectedDate.day == date.day;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                )
              : null,
          color: isSelected 
              ? null
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected 
                ? Colors.white 
                : (isDark ? AppColors.textDark : AppColors.text),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecurrenceSelectionCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                              Text(
                        "Récurrence",
                                style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                                  color: textColor,
                          letterSpacing: -0.3,
                                ),
                              ),
                      const SizedBox(height: 4),
                                  Text(
                        "À quelle fréquence cette transaction se répète-t-elle ?",
                                    style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Dropdown menu
            DropdownButtonFormField<RecurrenceType>(
              value: _selectedRecurrence,
              decoration: InputDecoration(
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                hintText: 'Sélectionner la récurrence',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                color: AppColors.primary,
                size: 22,
              ),
              dropdownColor: cardColor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              isExpanded: true,
              itemHeight: 60,
              borderRadius: BorderRadius.circular(20),
              items: [
                RecurrenceType.none,
                RecurrenceType.daily,
                RecurrenceType.weekly,
                RecurrenceType.monthly,
                RecurrenceType.quarterly,
                RecurrenceType.annual,
              ].map((type) {
                final bool isSelected = _selectedRecurrence == type;
                return DropdownMenuItem<RecurrenceType>(
                  value: type,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: _getRecurrenceIcon(type),
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _getRecurrenceTitle(type),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : textColor,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return [
                  RecurrenceType.none,
                  RecurrenceType.daily,
                  RecurrenceType.weekly,
                  RecurrenceType.monthly,
                  RecurrenceType.quarterly,
                  RecurrenceType.annual,
                ].map((type) {
                  return Container(
                    height: 56,
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: _getRecurrenceIcon(type),
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getRecurrenceTitle(type),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              onChanged: (RecurrenceType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRecurrence = newValue;
                  });
                  HapticFeedback.lightImpact();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContinueButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _handleContinue,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                  ),
            borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                    spreadRadius: 0,
                      offset: const Offset(0, 4),
                  ),
                ],
              ),
                child: Center(
                  child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                  'Continuer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                          color: Colors.white,
                    letterSpacing: -0.3,
                        ),
                      ),
                const SizedBox(width: 8),
                const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: Colors.white,
                  size: 20,
                      ),
                    ],
                  ),
                  ),
                ),
              ),
    );
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return monthNames[month - 1];
  }
  
  String _getDayOfWeek(DateTime date) {
    const List<String> dayNames = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return dayNames[date.weekday - 1];
  }
  
  String _getRecurrenceTitle(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'Pas de récurrence';
      case RecurrenceType.daily:
        return 'Quotidienne';
      case RecurrenceType.weekly:
        return 'Hebdomadaire';
      case RecurrenceType.monthly:
        return 'Mensuelle';
      case RecurrenceType.quarterly:
        return 'Trimestrielle';
      case RecurrenceType.annual:
        return 'Annuelle';
    }
  }
  
  String _getRecurrenceDescription(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'Transaction unique';
      case RecurrenceType.daily:
        return 'Se répète chaque jour';
      case RecurrenceType.weekly:
        return 'Se répète chaque semaine';
      case RecurrenceType.monthly:
        return 'Se répète chaque mois';
      case RecurrenceType.quarterly:
        return 'Se répète tous les trois mois';
      case RecurrenceType.annual:
        return 'Se répète chaque année';
    }
  }
  
  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return HugeIcons.strokeRoundedCancel01;
      case RecurrenceType.daily:
        return HugeIcons.strokeRoundedCalendar01;
      case RecurrenceType.weekly:
        return HugeIcons.strokeRoundedCalendar02;
      case RecurrenceType.monthly:
        return HugeIcons.strokeRoundedCalendar03;
      case RecurrenceType.quarterly:
        return HugeIcons.strokeRoundedCalendar04;
      case RecurrenceType.annual:
        return HugeIcons.strokeRoundedCalendar04;
    }
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
} 