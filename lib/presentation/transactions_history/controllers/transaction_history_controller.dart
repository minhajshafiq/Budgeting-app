import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/transaction_period.dart';
import '../../../presentation/providers/transaction_provider_clean.dart';

class TransactionHistoryController extends ChangeNotifier {
  final TransactionProviderClean _transactionProvider;
  
  // État du calendrier
  DateTime _selectedMonth = DateTime.now();
  int? _selectedDay = DateTime.now().day;
  
  // Données du calendrier (toujours toutes les transactions)
  final Set<int> _highlightedDays = {};
  final Map<String, List<TransactionEntity>> _transactionsByDay = {};
  
  // Données filtrées pour la liste (selon la période sélectionnée)
  List<TransactionEntity> _filteredTransactions = [];
  TransactionPeriod _selectedPeriod = TransactionPeriod.today;
  
  // Mode d'affichage : true = jour sélectionné, false = période filtrée
  bool _isDayMode = false;
  
  // Controllers d'animation
  late AnimationController headerController;
  late AnimationController calendarController;
  late AnimationController transactionsController;
  
  late Animation<double> headerAnimation;
  late Animation<double> calendarAnimation;
  late Animation<double> transactionsAnimation;
  
  bool _isInitialized = false;
  
  // Getters
  DateTime get selectedMonth => _selectedMonth;
  int? get selectedDay => _selectedDay;
  Set<int> get highlightedDays => _highlightedDays;
  Map<String, List<TransactionEntity>> get transactionsByDay => _transactionsByDay;
  List<TransactionEntity> get filteredTransactions => _filteredTransactions;
  TransactionPeriod get selectedPeriod => _selectedPeriod;
  bool get isInitialized => _isInitialized;
  bool get isDayMode => _isDayMode;
  TransactionProviderClean get transactionProvider => _transactionProvider;
  
  TransactionHistoryController(this._transactionProvider) {
    _initializeAnimations();
    // Écouter les changements du provider
    _transactionProvider.addListener(_onProviderChanged);
  }
  
  void _initializeAnimations() {
    // Les animations seront initialisées dans le widget avec TickerProvider
  }
  
  void _onProviderChanged() {
    // Mettre à jour le calendrier avec toutes les transactions
    updateCalendarData(_transactionProvider.transactions);
    // Mettre à jour la liste filtrée selon la période sélectionnée
    updateFilteredTransactions();
  }
  
  void setAnimationControllers({
    required AnimationController header,
    required AnimationController calendar,
    required AnimationController transactions,
  }) {
    headerController = header;
    calendarController = calendar;
    transactionsController = transactions;
    
    // Configurer les animations
    headerAnimation = CurvedAnimation(
      parent: headerController,
      curve: Curves.easeOutCubic,
    );
    
    calendarAnimation = CurvedAnimation(
      parent: calendarController,
      curve: Curves.easeOutBack,
    );
    
    transactionsAnimation = CurvedAnimation(
      parent: transactionsController,
      curve: Curves.easeOutCubic,
    );
    
    _isInitialized = true;
    notifyListeners();
  }
  
  void initialize() {
    _transactionProvider.initialize();
    // Charger toutes les transactions avec récurrences au démarrage
    _transactionProvider.loadAllTransactionsWithRecurrences();
    // Initialiser la liste filtrée
    updateFilteredTransactions();
    _startAnimations();
  }
  
  void _startAnimations() async {
    if (!_isInitialized) return;
    
    headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    
    calendarController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    
    transactionsController.forward();
  }
  
  void updateCalendarData(List<TransactionEntity> allTransactions) {
    _highlightedDays.clear();
    _transactionsByDay.clear();
    
    // Filtrer les transactions du mois sélectionné (toutes les périodes)
    final monthTransactions = allTransactions.where((transaction) {
      return transaction.date.year == _selectedMonth.year && 
             transaction.date.month == _selectedMonth.month;
    }).toList();
    
    // Organiser les transactions par jour
    for (final transaction in monthTransactions) {
      final day = transaction.date.day;
      final dayKey = day.toString();
      
      _highlightedDays.add(day);
      
      if (!_transactionsByDay.containsKey(dayKey)) {
        _transactionsByDay[dayKey] = [];
      }
      _transactionsByDay[dayKey]!.add(transaction);
    }

    // Sélectionner automatiquement le premier jour avec transaction si besoin
    if (_highlightedDays.isNotEmpty && (_selectedDay == null || !_highlightedDays.contains(_selectedDay))) {
      _selectedDay = _highlightedDays.first;
    }
    
    // Trier les transactions par date dans chaque jour
    for (final dayKey in _transactionsByDay.keys) {
      _transactionsByDay[dayKey]!.sort((a, b) => b.date.compareTo(a.date));
    }
    
    notifyListeners();
  }
  
  void changeMonth(int direction) {
    HapticFeedback.lightImpact();
    _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + direction,
    );
    // Mettre à jour les données du calendrier pour le nouveau mois
    updateCalendarData(_transactionProvider.transactions);
    notifyListeners();
  }
  
  void selectDay(int day, bool isAfterToday) {
    HapticFeedback.lightImpact();
    _selectedDay = day;
    _isDayMode = true; // Passer en mode jour sélectionné
    // Toujours mettre à jour les transactions du calendrier pour le jour sélectionné
    updateCalendarData(_transactionProvider.transactions);
    notifyListeners();
  }
  
  void changePeriod(TransactionPeriod period) {
    HapticFeedback.lightImpact();
    // Changer la période sélectionnée et mettre à jour la liste filtrée
    _selectedPeriod = period;
    _isDayMode = false; // Revenir au mode période filtrée
    updateFilteredTransactions();
  }
  
  void updateFilteredTransactions() {
    final allTransactions = _transactionProvider.transactions;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case TransactionPeriod.past:
        _filteredTransactions = allTransactions
            .where((t) => t.date.isBefore(todayStart))
            .toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // Du plus récent au plus ancien
        break;

      case TransactionPeriod.today:
        _filteredTransactions = allTransactions
            .where((t) => 
                t.date.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
                t.date.isBefore(todayEnd.add(const Duration(seconds: 1))))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        break;

      case TransactionPeriod.future:
        _filteredTransactions = allTransactions
            .where((t) => t.date.isAfter(todayEnd))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        break;
    }
    
    notifyListeners();
  }
  
  List<TransactionEntity> getSelectedDayTransactions() {
    if (_isDayMode && _selectedDay != null) {
      // Mode jour : retourner les transactions du jour sélectionné
      return _transactionsByDay[_selectedDay.toString()] ?? [];
    } else {
      // Mode période : retourner les transactions filtrées par période
      return _filteredTransactions;
    }
  }
  
  String getMonthYearText() {
    final List<String> monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    final String monthName = monthNames[_selectedMonth.month - 1];
    final int year = _selectedMonth.year;
    
    return '$monthName $year';
  }
  
  String getDynamicTitle() {
    if (_isDayMode && _selectedDay != null) {
      // Mode jour : titre avec la date spécifique
      return 'Transactions du ${_selectedDay} ${getMonthYearText()}';
    } else {
      // Mode période : titre selon la période sélectionnée
      final today = DateTime.now();
      final todayFormatted = '${today.day} ${getMonthYearText()}';
      
      switch (_selectedPeriod) {
        case TransactionPeriod.past:
          return 'Transactions passées avant le $todayFormatted';
        case TransactionPeriod.today:
          return 'Transactions du $todayFormatted';
        case TransactionPeriod.future:
          return 'Transactions futures à partir du $todayFormatted';
      }
    }
  }
  
  String getEmptyStateMessage() {
    if (_isDayMode && _selectedDay != null) {
      // Mode jour : message pour le jour sélectionné
      final bool isToday = _selectedDay == DateTime.now().day && 
                          _selectedMonth.month == DateTime.now().month && 
                          _selectedMonth.year == DateTime.now().year;
      
      if (isToday) {
        return 'Aucune transaction aujourd\'hui';
      }
      
      return 'Aucune transaction le ${_selectedDay} ${getMonthYearText()}';
    } else {
      // Mode période : message pour la période sélectionnée
      switch (_selectedPeriod) {
        case TransactionPeriod.past:
          return 'Aucune transaction passée';
        case TransactionPeriod.today:
          return 'Aucune transaction aujourd\'hui';
        case TransactionPeriod.future:
          return 'Aucune transaction planifiée';
      }
    }
  }
  
  bool isToday(int day) {
    final now = DateTime.now();
    return day == now.day && 
           _selectedMonth.month == now.month && 
           _selectedMonth.year == now.year;
  }
  
  bool isAfterToday(int day) {
    final now = DateTime.now();
    final isCurrentMonth = now.year == _selectedMonth.year && now.month == _selectedMonth.month;
    
    return isCurrentMonth && day > now.day || 
           (_selectedMonth.year > now.year || 
           (_selectedMonth.year == now.year && _selectedMonth.month > now.month));
  }
  
  bool isSelected(int day) {
    return _selectedDay == day;
  }
  
  Color getTransactionColor(int day) {
    final isAfterToday = this.isAfterToday(day);
    final isHighlighted = _highlightedDays.contains(day);
    
    if (isAfterToday && isHighlighted) {
      return const Color(0xFFA7C4FF); // Couleur pour les transactions futures
    }
    return const Color(0xFF4A84FF); // Couleur pour les transactions passées
  }
  
  void dispose() {
    // Retirer l'écouteur du provider
    _transactionProvider.removeListener(_onProviderChanged);
    
    if (_isInitialized) {
      headerController.dispose();
      calendarController.dispose();
      transactionsController.dispose();
    }
    super.dispose();
  }
} 