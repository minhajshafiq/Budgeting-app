import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../core/constants/constants.dart';
import '../../core/services/image_picker_service.dart';
import 'transaction_date_page.dart';
import '../../widgets/modern_animations.dart';
import '../../core/widgets/card_container.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/shared/logo_search_modal.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/widgets/smart_back_button.dart';

class TransactionDetailsPage extends StatefulWidget {
  final bool isIncome;
  final String transactionType;
  final double amount;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialImageUrl;
  final String? initialImagePath;
  
  const TransactionDetailsPage({
    Key? key, 
    required this.isIncome,
    required this.transactionType,
    required this.amount,
    this.initialTitle,
    this.initialCategory,
    this.initialImageUrl,
    this.initialImagePath,
  }) : super(key: key);

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;
  
  // Variables pour la sélection d'image
  File? _selectedImage;
  String? _selectedLogoUrl;
  
  // Liste des catégories pour revenus et dépenses avec HugeIcons
  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salaire', 'icon': HugeIcons.strokeRoundedMoney01},
    {'name': 'Freelance', 'icon': HugeIcons.strokeRoundedLaptop},
    {'name': 'Remboursement', 'icon': HugeIcons.strokeRoundedArrowTurnBackward},
    {'name': 'Cadeau', 'icon': HugeIcons.strokeRoundedGift},
    {'name': 'Allocation', 'icon': HugeIcons.strokeRoundedBank},
    {'name': 'Dividendes', 'icon': HugeIcons.strokeRoundedAnalytics01},
    {'name': 'Vente', 'icon': HugeIcons.strokeRoundedShoppingBag01},
    {'name': 'Autre', 'icon': HugeIcons.strokeRoundedMenu01},
  ];
  
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Alimentation', 'icon': HugeIcons.strokeRoundedRestaurant01},
    {'name': 'Transport', 'icon': HugeIcons.strokeRoundedCar01},
    {'name': 'Logement', 'icon': HugeIcons.strokeRoundedHome01},
    {'name': 'Loisirs', 'icon': HugeIcons.strokeRoundedGameController01},
    {'name': 'Santé', 'icon': HugeIcons.strokeRoundedMedicalMask},
    {'name': 'Abonnements', 'icon': HugeIcons.strokeRoundedCalendar03},
    {'name': 'Shopping', 'icon': HugeIcons.strokeRoundedShoppingBag01},
    {'name': 'Factures', 'icon': HugeIcons.strokeRoundedInvoice01},
    {'name': 'Voyage', 'icon': HugeIcons.strokeRoundedAirplane01},
    {'name': 'Éducation', 'icon': HugeIcons.strokeRoundedSchool01},
    {'name': 'Autre', 'icon': HugeIcons.strokeRoundedMenu01},
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Préremplir les données si elles existent
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
    if (widget.initialImagePath != null) {
      _selectedImage = File(widget.initialImagePath!);
    }
    if (widget.initialImageUrl != null) {
      _selectedLogoUrl = widget.initialImageUrl;
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
  }
  
  void _startAnimations() async {
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // Méthodes pour la sélection d'image
  void _showImageSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSelectionModal(
        onGallerySelected: _pickImageFromGallery,
        onLogoDevSelected: _showLogoSearchModal,
      ),
    );
  }
  
  Future<void> _pickImageFromGallery() async {
    try {
      final File? image = await ImagePickerService.pickImageFromGallery();
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _selectedLogoUrl = null; // Reset logo URL when gallery image is selected
        });
        
        if (mounted) {
          AppNotification.success(
            context,
            title: 'Image sélectionnée',
            subtitle: 'L\'image a été ajoutée à votre transaction',
          );
          ImagePickerService.triggerHapticFeedback();
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          title: 'Erreur',
          subtitle: 'Impossible de sélectionner l\'image',
        );
      }
    }
  }
  
  void _showLogoSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogoSearchModal(
        onLogoSelected: (logoUrl) {
          setState(() {
            _selectedLogoUrl = logoUrl;
            _selectedImage = null; // Reset gallery image when logo is selected
          });
          
          AppNotification.success(
            context,
            title: 'Logo sélectionné',
            subtitle: 'Le logo a été ajouté à votre transaction',
          );
          HapticFeedback.lightImpact();
        },
      ),
    );
  }
  
  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _selectedLogoUrl = null;
    });
    
    HapticFeedback.lightImpact();
    AppNotification.success(
      context,
      title: 'Image supprimée',
      subtitle: 'L\'image a été retirée de votre transaction',
    );
  }
  
  void _handleContinue() {
    if (_titleController.text.trim().isEmpty) {
      AppNotification.error(
        context,
        title: 'Titre manquant',
        subtitle: 'Veuillez entrer un titre pour votre transaction',
      );
      return;
    }
    
    if (_selectedCategory == null) {
      AppNotification.error(
        context,
        title: 'Catégorie manquante',
        subtitle: 'Veuillez sélectionner une catégorie',
      );
      return;
    }
    
    // Navigate to date selection page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDatePage(
          isIncome: widget.isIncome,
          transactionType: widget.transactionType,
          amount: widget.amount,
          title: _titleController.text.trim(),
          category: _selectedCategory!,
          imageUrl: _selectedLogoUrl,
          imagePath: _selectedImage?.path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final categories = widget.isIncome ? _incomeCategories : _expenseCategories;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
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
            
            // Formulaire - Espace flexible
            Expanded(
              child: SlideInAnimation(
                beginOffset: const Offset(0, 0.4),
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 700),
                child: _isInitialized
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFormWithButton(categories, isDark),
                      )
                    : _buildFormWithButton(categories, isDark),
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
                    'Étape 2/3',
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
                        '2',
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
                    'Détails de la transaction',
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
                  '67%',
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
              widthFactor: 0.67,
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
            'Étape 2 sur 3 • Presque terminé',
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
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isIncome ? 'Nouveau revenu' : 'Nouvelle dépense',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.text,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ajout de détails',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isIncome ? AppColors.green : AppColors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isIncome ? AppColors.green : AppColors.red).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${widget.isIncome ? '+' : '-'}${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}€',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormWithButton(List<Map<String, dynamic>> categories, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Résumé qui scrolle avec la page
          _buildTransactionSummary(),

          // Card: Titre de la transaction
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: CardContainer(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.05), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Titre de la transaction",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textDark : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.isIncome
                                ? "Donnez un titre à votre revenu"
                                : "Donnez un titre à votre dépense",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildModernTitleInput(),
                ],
              ),
            ),
          ),

          // Card: Sélection d'image (optionnel)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: CardContainer(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.05), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: _buildImageSelector(),
            ),
          ),

          // Card: Catégorie
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: CardContainer(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.05), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedMenu01,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Choisir une catégorie",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textDark : AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Sélectionnez la catégorie qui correspond",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildCategoryGrid(categories),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildBottomButtonLikeSavings(isDark),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildImageSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    final Color surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedImage01,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Image (optionnel)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ajoutez une image personnalisée',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_selectedImage != null || _selectedLogoUrl != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image preview
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : _selectedLogoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_selectedLogoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Image info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedImage != null ? 'Image depuis galerie' : 'Logo depuis Logo.dev',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Image sélectionnée',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Remove button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _removeSelectedImage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          color: AppColors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _showImageSelectionModal,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedImage01,
                          color: AppColors.primary,
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
                            'Ajouter une image',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Galerie ou Logo.dev',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCategoryGrid(List<Map<String, dynamic>> categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = _selectedCategory == cat['name'];
        final Color iconColor = isSelected
            ? Colors.white
            : (isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B));
        final Color bgColor = isSelected
            ? AppColors.primary
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02));
        final Color borderColor = isSelected
            ? AppColors.primary
            : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08));
            
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _selectedCategory = cat['name'];
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    cat['icon'],
                    color: iconColor,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtonLikeSavings(bool isDark) {
    final bool canContinue = _titleController.text.trim().isNotEmpty && _selectedCategory != null;
    final Color disabledBg = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04);
    final Color disabledText = isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF94A3B8);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: canContinue ? _handleContinue : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 58,
          decoration: BoxDecoration(
            color: canContinue ? AppColors.primary : disabledBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: canContinue
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  opacity: canContinue ? 1.0 : 0.6,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: canContinue ? Colors.white : disabledText,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(
                    canContinue ? 0 : -4,
                    0,
                    0,
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedArrowRight01,
                    color: canContinue ? Colors.white : disabledText,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTitleInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    final Color backgroundColor = isDark ? AppColors.surfaceDark : Colors.white;
    final Color borderColor = isDark ? AppColors.borderDark : Colors.black.withOpacity(0.08);
    final Color focusBorderColor = AppColors.primary;
    final Color hintColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          // Animation state management
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _titleController.text.isNotEmpty ? focusBorderColor.withOpacity(0.3) : borderColor,
            width: _titleController.text.isNotEmpty ? 1.5 : 1,
          ),
          boxShadow: _titleController.text.isNotEmpty ? [
            BoxShadow(
              color: focusBorderColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextField(
          controller: _titleController,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 1.4,
          ),
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: widget.isIncome ? 'Ex: Salaire, Prime, Freelance...' : 'Ex: Courses, Netflix, Essence...',
            hintStyle: TextStyle(
              color: hintColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            suffixIcon: _titleController.text.isNotEmpty
                ? AnimatedOpacity(
                    opacity: _titleController.text.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _titleController.clear();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              HugeIcons.strokeRoundedCancel01,
                              color: hintColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

// Modal pour la sélection d'image
class _ImageSelectionModal extends StatelessWidget {
  final VoidCallback onGallerySelected;
  final VoidCallback onLogoDevSelected;

  const _ImageSelectionModal({
    required this.onGallerySelected,
    required this.onLogoDevSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Sélectionner une image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                const Spacer(),
                ModernRippleEffect(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: isDark ? AppColors.textDark : AppColors.text,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Options
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Galerie option
                ModernRippleEffect(
                  onTap: () {
                    Navigator.pop(context);
                    onGallerySelected();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedImage01,
                              color: AppColors.green,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Galerie',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textDark : AppColors.text,
                                ),
                              ),
                              Text(
                                'Choisir depuis vos photos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          color: AppColors.green,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Logo.dev option
                ModernRippleEffect(
                  onTap: () {
                    Navigator.pop(context);
                    onLogoDevSelected();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedGlobalEditing,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logo.dev',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textDark : AppColors.text,
                                ),
                              ),
                              Text(
                                'Rechercher un logo d\'entreprise',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

 
 
