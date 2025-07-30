import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../core/constants/constants.dart';
import '../presentation/providers/transaction_provider_clean.dart';
import '../providers/transaction_provider.dart';
import '../data/models/transaction.dart';
import '../data/models/category.dart';
import '../domain/entities/transaction_entity.dart';
import '../core/services/image_picker_service.dart';
import 'app_notification.dart';
import 'modern_animations.dart';
import 'shared/logo_search_modal.dart';
import 'package:hugeicons/hugeicons.dart';

class TransactionEditModal extends StatefulWidget {
  final Transaction transaction;

  const TransactionEditModal({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionEditModal> createState() => _TransactionEditModalState();
}

class _TransactionEditModalState extends State<TransactionEditModal> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  late DateTime selectedDate;
  late TransactionType transactionType;
  late String selectedCategoryId;
  late RecurrenceType selectedRecurrence;
  
  bool isLoading = false;
  
  // Variables pour la sélection d'image
  File? _selectedImage;
  String? _selectedLogoUrl;

  final List<String> expenseCategories = [
    'expense_food',
    'expense_transport',
    'expense_shopping',
    'expense_subscription',
    'expense_entertainment',
    'expense_health',
    'expense_bills',
    'expense_other',
  ];

  final List<String> incomeCategories = [
    'income_salary',
    'income_freelance',
    'income_investment',
    'income_gift',
    'income_other',
  ];

  final Map<String, String> categoryNames = {
    'expense_food': 'Alimentation',
    'expense_transport': 'Transport',
    'expense_shopping': 'Shopping',
    'expense_subscription': 'Abonnements',
    'expense_entertainment': 'Loisirs',
    'expense_health': 'Santé',
    'expense_bills': 'Factures',
    'expense_other': 'Autres dépenses',
    'income_salary': 'Salaire',
    'income_freelance': 'Freelance',
    'income_investment': 'Investissement',
    'income_gift': 'Cadeau',
    'income_other': 'Autres revenus',
  };

  final Map<String, IconData> categoryIcons = {
    'expense_food': HugeIcons.strokeRoundedRestaurant01,
    'expense_transport': HugeIcons.strokeRoundedCar01,
    'expense_shopping': HugeIcons.strokeRoundedShoppingBag01,
    'expense_subscription': HugeIcons.strokeRoundedCreditCard,
    'expense_entertainment': HugeIcons.strokeRoundedGameController01,
    'expense_health': HugeIcons.strokeRoundedHeartCheck,
    'expense_bills': HugeIcons.strokeRoundedInvoice01,
    'expense_other': HugeIcons.strokeRoundedMoreHorizontal,
    'income_salary': HugeIcons.strokeRoundedMoney01,
    'income_freelance': HugeIcons.strokeRoundedComputerProgramming01,
    'income_investment': HugeIcons.strokeRoundedTradeMark,
    'income_gift': HugeIcons.strokeRoundedGift,
    'income_other': HugeIcons.strokeRoundedWallet01,
  };

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.transaction.title);
    amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
    descriptionController = TextEditingController(text: widget.transaction.description ?? '');
    selectedDate = widget.transaction.date;
    transactionType = widget.transaction.type;
    selectedCategoryId = widget.transaction.categoryId;
    selectedRecurrence = widget.transaction.recurrence;
    
    // Charger l'image existante si elle existe
    if (widget.transaction.imageUrl != null && widget.transaction.imageUrl!.isNotEmpty) {
      if (widget.transaction.imageUrl!.startsWith('http')) {
        _selectedLogoUrl = widget.transaction.imageUrl;
      } else {
        _selectedImage = File(widget.transaction.imageUrl!);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? AppColors.surfaceDark : Colors.white,
            isDark ? AppColors.backgroundDark : const Color(0xFFFAFBFC),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de drag moderne
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          // Header moderne
          _buildModernHeader(isDark),
          
          // Contenu avec scrolling
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et montant
                  _buildTitleAmountRow(isDark),
                  const SizedBox(height: 24),
                  
                  // Date et catégorie
                  _buildDateCategoryRow(isDark),
                  const SizedBox(height: 24),
                  
                  // Icône de la transaction (modernisée)
                  _buildModernIconCard(isDark),
                  const SizedBox(height: 24),
                  
                  // Récurrence (modernisée)
                  _buildModernRecurrenceCard(isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Actions en bas (modernisées)
          _buildModernActions(isDark),
        ],
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    final isIncome = transactionType == TransactionType.income;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedEdit02,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modification d\'une',
                  style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'transaction',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDark : AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Type selector modernisé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                  isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => transactionType = TransactionType.income),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: isIncome ? const LinearGradient(
                          colors: [
                            Color(0xFF78D078),
                            Color(0xFF66C566),
                          ],
                        ) : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isIncome ? [
                          BoxShadow(
                            color: const Color(0xFF78D078).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowUp01,
                            color: isIncome ? Colors.white : const Color(0xFF78D078),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Revenu',
                            style: TextStyle(
                              color: isIncome ? Colors.white : const Color(0xFF78D078),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => transactionType = TransactionType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: !isIncome ? const LinearGradient(
                          colors: [
                            Color(0xFFF48A99),
                            Color(0xFFE67E9A),
                          ],
                        ) : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: !isIncome ? [
                          BoxShadow(
                            color: const Color(0xFFF48A99).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowDown01,
                            color: !isIncome ? Colors.white : const Color(0xFFF48A99),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dépense',
                            style: TextStyle(
                              color: !isIncome ? Colors.white : const Color(0xFFF48A99),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildModernIconCard(bool isDark) {
    return GestureDetector(
      onTap: () => _showImageSelectionModal(isDark),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? AppColors.surfaceDark : const Color(0xFFFDFDFD),
              isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : _selectedLogoUrl != null
                      ? Image.network(
                          _selectedLogoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                widget.transaction.title.isNotEmpty 
                                  ? widget.transaction.title[0].toUpperCase() 
                                  : 'S',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            widget.transaction.title.isNotEmpty 
                              ? widget.transaction.title[0].toUpperCase() 
                              : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Icône de la transaction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDark : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedImage != null 
                        ? 'Image depuis galerie'
                        : _selectedLogoUrl != null
                          ? 'Logo depuis Logo.dev'
                          : 'Toucher pour changer l\'icône',
                      style: TextStyle(
                              fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 16,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildModernRecurrenceCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showRecurrenceSelector(isDark);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? AppColors.surfaceDark : const Color(0xFFFDFDFD),
              isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: selectedRecurrence != RecurrenceType.none 
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.1),
                          (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.05),
                        ],
                      ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedRecurrence != RecurrenceType.none ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedRepeat,
                  color: selectedRecurrence != RecurrenceType.none 
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction récurrente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDark : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRecurrenceLabel(selectedRecurrence),
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedRecurrence != RecurrenceType.none 
                          ? AppColors.primary
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernActions(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: Platform.isAndroid ? 24 : 40,
        top: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? AppColors.surfaceDark : Colors.white,
            isDark ? AppColors.backgroundDark : const Color(0xFFFAFBFC),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bouton de suppression modernisé
          Expanded(
            child: SizedBox(
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFF48A99),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF48A99).withValues(alpha: 0.05),
                      const Color(0xFFF48A99).withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmationModal(),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: Color(0xFFF48A99),
                    size: 20,
                  ),
                  label: const Text(
                    'Supprimer',
                    style: TextStyle(
                      color: Color(0xFFF48A99),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Bouton de sauvegarde modernisé
          Expanded(
            child: SizedBox(
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAmountRow(bool isDark) {
    final isIncome = transactionType == TransactionType.income;
    
    return Row(
      children: [
        // Titre
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Titre',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: TextStyle(
                  color: isDark ? AppColors.textDark : AppColors.text,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: widget.transaction.title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : const Color(0xFFFAFBFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Montant avec indicateur de type
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Montant',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isIncome ? AppColors.green.withValues(alpha: 0.3) : AppColors.red.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (isIncome ? const Color(0xFF78D078) : const Color(0xFFF48A99)).withValues(alpha: 0.15),
                            (isIncome ? const Color(0xFF78D078) : const Color(0xFFF48A99)).withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        isIncome ? '+' : '-',
                        style: TextStyle(
                          color: isIncome ? const Color(0xFF78D078) : const Color(0xFFF48A99),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          color: isDark ? AppColors.textDark : AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          suffixText: '€',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          suffixStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
             ],
     );
   }

  Widget _buildDateCategoryRow(bool isDark) {
    return Row(
      children: [
        // Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(selectedDate),
                        style: TextStyle(
                          color: isDark ? AppColors.textDark : AppColors.text,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Catégorie
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catégorie',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showCategorySelector,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: categoryIcons[selectedCategoryId] ?? HugeIcons.strokeRoundedMoreHorizontal,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categoryNames[selectedCategoryId] ?? 'Autre',
                          style: TextStyle(
                            color: isDark ? AppColors.textDark : AppColors.text,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowDown01,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernIconSection(bool isDark) {
    return GestureDetector(
      onTap: () => _showImageSelectionModal(isDark),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.surfaceDark : Colors.grey[50]),
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
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                    )
                  : _selectedLogoUrl != null
                    ? Image.network(
                        _selectedLogoUrl!,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              widget.transaction.title.isNotEmpty ? widget.transaction.title[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          widget.transaction.title.isNotEmpty ? widget.transaction.title[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Icône de la transaction',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                  Text(
                    _selectedImage != null 
                      ? 'Image depuis galerie'
                      : _selectedLogoUrl != null
                        ? 'Logo depuis Logo.dev'
                        : 'Toucher pour changer l\'icône',
                    style: TextStyle(
                      fontSize: 12,
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
    );
  }

  Widget _buildModernRecurrenceSwitch(bool isDark) {
    return GestureDetector(
      onTap: () {
        _showRecurrenceSelector(isDark);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.surfaceDark : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedRecurrence != RecurrenceType.none 
                  ? AppColors.primary.withValues(alpha: 0.1) 
                  : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedRepeat,
                color: selectedRecurrence != RecurrenceType.none 
                  ? AppColors.primary 
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction récurrente',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                  Text(
                    _getRecurrenceLabel(selectedRecurrence),
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedRecurrence != RecurrenceType.none 
                        ? AppColors.primary 
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
    );
  }

  String _getRecurrenceLabel(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.daily:
        return 'Quotidien';
      case RecurrenceType.weekly:
        return 'Hebdomadaire';
      case RecurrenceType.monthly:
        return 'Mensuel';
      case RecurrenceType.quarterly:
        return 'Trimestriel';
      case RecurrenceType.yearly:
        return 'Annuel';
      case RecurrenceType.none:
      default:
        return 'Aucune';
    }
  }

  String _getRecurrenceDescription(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.daily:
        return 'Répète tous les jours';
      case RecurrenceType.weekly:
        return 'Répète chaque semaine';
      case RecurrenceType.monthly:
        return 'Répète chaque mois';
      case RecurrenceType.quarterly:
        return 'Répète tous les 3 mois';
      case RecurrenceType.yearly:
        return 'Répète chaque année';
      case RecurrenceType.none:
      default:
        return 'Transaction unique';
    }
  }

  Widget _buildModernBottomActions(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: Platform.isAndroid ? 24 : 40,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton de suppression
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmationModal(),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: AppColors.red,
                size: 18,
              ),
              label: const Text(
                'Supprimer la transaction',
                style: TextStyle(color: AppColors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton de sauvegarde
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _saveChanges() async {
    if (titleController.text.trim().isEmpty) {
      AppNotification.error(
        context,
        title: 'Erreur de validation',
        subtitle: 'Le titre ne peut pas être vide',
      );
      return;
    }

    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      AppNotification.error(
        context,
        title: 'Erreur de validation',
        subtitle: 'Le montant ne peut pas être vide',
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      AppNotification.error(
        context,
        title: 'Erreur de validation',
        subtitle: 'Le montant doit être un nombre positif',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Déterminer l'imageUrl à sauvegarder
      String? imageUrlToSave;
      if (_selectedImage != null) {
        // Si une image de galerie est sélectionnée, on utilise le chemin local
        imageUrlToSave = _selectedImage!.path;
      } else if (_selectedLogoUrl != null) {
        // Si un logo Logo.dev est sélectionné, on utilise l'URL
        imageUrlToSave = _selectedLogoUrl;
      } else {
        // Sinon, on garde l'ancienne imageUrl (peut être null)
        imageUrlToSave = widget.transaction.imageUrl;
      }

      final updatedTransaction = widget.transaction.copyWith(
        title: titleController.text.trim(),
        amount: amount,
        date: selectedDate,
        categoryId: selectedCategoryId,
        type: transactionType,
        description: descriptionController.text.trim().isEmpty 
          ? null 
          : descriptionController.text.trim(),
        recurrence: selectedRecurrence,
        imageUrl: imageUrlToSave,
      );



      // Toujours utiliser le TransactionProvider principal qui gère la synchronisation Supabase
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.updateTransaction(updatedTransaction);
      
      // Si on est sur la page d'historique, synchroniser aussi le provider clean
      try {
        final providerClean = Provider.of<TransactionProviderClean>(context, listen: false);
        await providerClean.loadAllTransactionsWithRecurrences();
      } catch (e) {
        // Le provider clean pourrait ne pas être disponible, ce n'est pas critique
      }

      if (!mounted) return;

      AppNotification.success(
        context,
        title: 'Transaction modifiée',
        subtitle: 'Les modifications ont été enregistrées',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      AppNotification.error(
        context,
        title: 'Erreur de sauvegarde',
        subtitle: 'Impossible de modifier la transaction',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark ? AppColors.surfaceDark : Colors.white,
                  isDark ? AppColors.backgroundDark : const Color(0xFFFAFBFC),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF48A99),
                        Color(0xFFE67E9A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedDelete02,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Supprimer la transaction',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Êtes-vous sûr de vouloir supprimer cette transaction ? Cette action est irréversible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Annuler',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDark : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _deleteTransaction();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF48A99),
                                Color(0xFFE67E9A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Supprimer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteTransaction() async {
    setState(() {
      isLoading = true;
    });

    try {


      // Toujours utiliser le TransactionProvider principal qui gère la synchronisation Supabase
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.deleteTransaction(widget.transaction.id);
      
      // Si on est sur la page d'historique, synchroniser aussi le provider clean
      try {
        final providerClean = Provider.of<TransactionProviderClean>(context, listen: false);
        await providerClean.loadAllTransactionsWithRecurrences();
      } catch (e) {
        // Le provider clean pourrait ne pas être disponible, ce n'est pas critique
      }

      if (!mounted) return;

      AppNotification.success(
        context,
        title: 'Transaction supprimée',
        subtitle: 'La transaction a été supprimée avec succès',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      AppNotification.error(
        context,
        title: 'Erreur de suppression',
        subtitle: 'Impossible de supprimer la transaction',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showCategorySelector() {
    final availableCategories = transactionType == TransactionType.income
        ? incomeCategories
        : expenseCategories;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? AppColors.surfaceDark : Colors.white,
                isDark ? AppColors.backgroundDark : const Color(0xFFFAFBFC),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Barre de drag moderne
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Header moderne compact
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  children: [
                    // Icône centrée plus petite
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedGrid,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Titre centré
                    Text(
                      'Choisir une catégorie',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDark : AppColors.text,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    // Sous-titre
                    Text(
                      transactionType == TransactionType.income 
                        ? 'Sélectionnez une catégorie de revenu'
                        : 'Sélectionnez une catégorie de dépense',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
                            // Liste des catégories compacte (sans scroll)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ...availableCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final categoryId = entry.value;
                        final isSelected = selectedCategoryId == categoryId;
                        
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 80)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 15 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategoryId = categoryId;
                                        });
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  AppColors.primary.withValues(alpha: 0.15),
                                                  AppColors.primary.withValues(alpha: 0.08),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.8),
                                                  (isDark ? AppColors.backgroundDark : const Color(0xFFFAFBFC)).withValues(alpha: 0.6),
                                                ],
                                              ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected 
                                              ? AppColors.primary.withValues(alpha: 0.4)
                                              : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected 
                                                ? AppColors.primary.withValues(alpha: 0.15)
                                                : Colors.black.withValues(alpha: 0.04),
                                              blurRadius: isSelected ? 8 : 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Icône compacte
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isSelected
                                                    ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)]
                                                    : [AppColors.primary.withValues(alpha: 0.2), AppColors.primary.withValues(alpha: 0.1)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: isSelected ? [
                                                  BoxShadow(
                                                    color: AppColors.primary.withValues(alpha: 0.25),
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ] : null,
                                              ),
                                              child: HugeIcon(
                                                icon: categoryIcons[categoryId] ?? HugeIcons.strokeRoundedMoreHorizontal,
                                                color: isSelected ? Colors.white : AppColors.primary,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            
                                            // Nom de la catégorie
                                            Expanded(
                                              child: Text(
                                                categoryNames[categoryId] ?? 'Autre',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                  color: isSelected 
                                                    ? AppColors.primary
                                                    : (isDark ? AppColors.textDark : AppColors.text),
                                                  letterSpacing: -0.1,
                                                ),
                                              ),
                                            ),
                                            
                                            // Indicateur de sélection compact
                                            if (isSelected)
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary.withValues(alpha: 0.3),
                                                      blurRadius: 3,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRecurrenceSelector(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? AppColors.surfaceDark : Colors.white,
                isDark ? AppColors.backgroundDark : const Color(0xFFFAFBFC),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Barre de drag moderne
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Header moderne
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Column(
                  children: [
                    // Icône centrée
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedRepeat,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Titre centré
                    Text(
                      'Choisir une récurrence',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDark : AppColors.text,
                        letterSpacing: -0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Sous-titre centré
                    Text(
                      'Définissez la fréquence de cette transaction',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Liste des récurrences
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: RecurrenceType.values.length,
                  itemBuilder: (context, index) {
                    final recurrence = RecurrenceType.values[index];
                    final isSelected = selectedRecurrence == recurrence;
                    
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          selectedRecurrence = recurrence;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected 
                              ? [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  AppColors.primary.withValues(alpha: 0.08),
                                ]
                              : [
                                  isDark ? AppColors.surfaceDark : Colors.white,
                                  isDark ? AppColors.backgroundDark : const Color(0xFFFAFBFC),
                                ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.04),
                              blurRadius: isSelected ? 12 : 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected 
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ] : null,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedRepeat,
                                color: isSelected 
                                  ? Colors.white 
                                  : AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getRecurrenceLabel(recurrence),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected 
                                        ? AppColors.primary
                                        : (isDark ? AppColors.textDark : AppColors.text),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getRecurrenceDescription(recurrence),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSelectionModal(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedGrid,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Choisir une image',
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
                        _pickImageFromGallery();
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedImage01,
                                  color: AppColors.green,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                      fontSize: 12,
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
                    
                    const SizedBox(height: 12),
                    
                    // Logo.dev option
                    ModernRippleEffect(
                      onTap: () {
                        Navigator.pop(context);
                        _pickLogoUrl();
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedSearch01,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                      fontSize: 12,
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
      },
    );
  }

  void _pickImageFromGallery() async {
    final pickedFile = await ImagePickerService.pickImageFromGallery();
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
      ImagePickerService.triggerHapticFeedback();
    }
  }

  void _pickLogoUrl() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LogoSearchModal(
        onLogoSelected: (logoUrl) {
          setState(() {
            _selectedLogoUrl = logoUrl;
            _selectedImage = null; // Reset image galerie
          });
          
          AppNotification.success(
            context,
            title: 'Logo sélectionné',
            subtitle: 'Le logo a été appliqué',
          );
        },
      ),
    );
  }
}

 