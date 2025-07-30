import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/transaction.dart';

class StatisticsController extends ChangeNotifier {
  // État des animations
  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _animation;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _chartAnimation;
  
  // État de la page
  String _selectedPeriod = 'Weekly';
  String? _selectedDay;
  bool _isInitialized = false;
  bool _isLineChart = false;
  
  // Offsets pour naviguer dans le temps
  int _weekOffset = 0;
  int _monthOffset = 0;
  int _yearOffset = 0;
  
  // Getters
  String get selectedPeriod => _selectedPeriod;
  String? get selectedDay => _selectedDay;
  bool get isInitialized => _isInitialized;
  bool get isLineChart => _isLineChart;
  int get weekOffset => _weekOffset;
  int get monthOffset => _monthOffset;
  int get yearOffset => _yearOffset;
  
  Animation<double> get animation => _animation;
  Animation<double> get headerAnimation => _headerAnimation;
  Animation<double> get cardAnimation => _cardAnimation;
  Animation<double> get chartAnimation => _chartAnimation;
  
  // Initialisation
  void initialize(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: AppAnimations.defaultDuration,
    );
    
    _staggerController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    );
    
    _chartAnimation = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
    _staggerController.forward();
    _isInitialized = true;
    notifyListeners();
  }
  
  // Nettoyage
  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }
  
  // Basculer entre graphique en barres et en ligne
  void toggleChartType() {
    HapticFeedback.lightImpact();
    _isLineChart = !_isLineChart;
    notifyListeners();
  }
  
  // Sélectionner une période
  void selectPeriod(String period) {
    _selectedPeriod = period;
    _selectedDay = null;
    notifyListeners();
  }
  
  // Sélectionner un jour
  void selectDay(String? day) {
    _selectedDay = _selectedDay == day ? null : day;
    notifyListeners();
  }
  
  // Navigation temporelle
  void navigateToPrevious() {
    _selectedDay = null;
    switch (_selectedPeriod) {
      case 'Weekly':
        _weekOffset--;
        break;
      case 'Monthly':
        _monthOffset--;
        break;
      case 'Yearly':
        _yearOffset--;
        break;
    }
    notifyListeners();
  }
  
  void navigateToNext() {
    _selectedDay = null;
    switch (_selectedPeriod) {
      case 'Weekly':
        _weekOffset++;
        break;
      case 'Monthly':
        _monthOffset++;
        break;
      case 'Yearly':
        _yearOffset++;
        break;
    }
    notifyListeners();
  }
  
  // Obtenir les données du graphique selon la période sélectionnée
  List<Map<String, dynamic>> getChartData(List<dynamic>? transactions) {
    switch (_selectedPeriod) {
      case 'Weekly':
        return _getWeeklyDataWithOffset(transactions ?? [], _weekOffset);
      case 'Monthly':
        return _getMonthlyDataWithOffset(_monthOffset);
      case 'Yearly':
        return getYearlyData();
      default:
        return _getWeeklyDataWithOffset(transactions ?? [], _weekOffset);
    }
  }
  
  // Obtenir les données hebdomadaires avec offset
  List<Map<String, dynamic>> _getWeeklyDataWithOffset(List<dynamic> transactions, int weekOffset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekday = today.weekday;
    final startOfCurrentWeek = today.subtract(Duration(days: currentWeekday - 1));
    final startOfTargetWeek = startOfCurrentWeek.add(Duration(days: weekOffset * 7));
    final endOfTargetWeek = startOfTargetWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final Map<String, double> dailyExpenses = {
      'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0,
      'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
    };
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (final transaction in transactions) {
      if (transaction.isExpense) {
        final transactionDate = transaction.date;
        if (!transactionDate.isBefore(startOfTargetWeek) && !transactionDate.isAfter(endOfTargetWeek)) {
          final dayOfWeek = transactionDate.weekday - 1;
          final dayName = dayNames[dayOfWeek];
          dailyExpenses[dayName] = dailyExpenses[dayName]! + transaction.amount;
        }
      }
    }

    final rawData = [
      {'period': 'Mon', 'expenses': dailyExpenses['Mon']!, 'color': AppColors.barMon},
      {'period': 'Tue', 'expenses': dailyExpenses['Tue']!, 'color': AppColors.barTue},
      {'period': 'Wed', 'expenses': dailyExpenses['Wed']!, 'color': AppColors.barWed},
      {'period': 'Thu', 'expenses': dailyExpenses['Thu']!, 'color': AppColors.barThu},
      {'period': 'Fri', 'expenses': dailyExpenses['Fri']!, 'color': AppColors.barFri},
      {'period': 'Sat', 'expenses': dailyExpenses['Sat']!, 'color': AppColors.barSat},
      {'period': 'Sun', 'expenses': dailyExpenses['Sun']!, 'color': AppColors.barSun},
    ];
    return _normalizeData(rawData);
  }
  
  // Obtenir les données mensuelles avec offset
  List<Map<String, dynamic>> _getMonthlyDataWithOffset(int monthOffset) {
    final now = DateTime.now();
    final baseYear = monthOffset >= 0 ? now.year : now.year - 1;
    final startMonth = monthOffset == 0 ? 1 : 7;
    
    final rawData = <Map<String, dynamic>>[];
    final colors = [AppColors.barMon, AppColors.barTue, AppColors.barWed, AppColors.barThu, AppColors.barFri, AppColors.barSat];
    
    for (int i = 0; i < 6; i++) {
      final monthNumber = startMonth + i;
      final month = DateTime(baseYear, monthNumber, 1);
      final monthName = _getMonthName(monthNumber);
      final expense = _getExpenseForMonth(month);
      
      rawData.add({
        'period': monthName,
        'expenses': expense,
        'color': colors[i],
      });
    }
    
    return _normalizeData(rawData);
  }
  
  // Obtenir les données annuelles
  List<Map<String, dynamic>> getYearlyData() {
    final rawData = [
      {'period': 'Jan', 'expenses': 1420.30, 'color': AppColors.barMon},
      {'period': 'Fév', 'expenses': 1180.25, 'color': AppColors.barTue},
      {'period': 'Mar', 'expenses': 1650.80, 'color': AppColors.barWed},
      {'period': 'Avr', 'expenses': 1320.45, 'color': AppColors.barThu},
      {'period': 'Mai', 'expenses': 1977.94, 'color': AppColors.barFri},
      {'period': 'Jun', 'expenses': 1240.50, 'color': AppColors.barSat},
      {'period': 'Jul', 'expenses': 1890.75, 'color': AppColors.barSun},
      {'period': 'Aoû', 'expenses': 1420.30, 'color': AppColors.barMon},
      {'period': 'Sep', 'expenses': 1180.25, 'color': AppColors.barTue},
      {'period': 'Oct', 'expenses': 1650.80, 'color': AppColors.barWed},
      {'period': 'Nov', 'expenses': 1320.45, 'color': AppColors.barThu},
      {'period': 'Déc', 'expenses': 1977.94, 'color': AppColors.barFri},
    ];
    return _normalizeData(rawData);
  }
  
  // Obtenir le nom du mois
  String _getMonthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 
                   'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }
  
  // Obtenir les dépenses pour un mois donné
  double _getExpenseForMonth(DateTime month) {
    final expenses = {
      1: 1420.30, 2: 1180.25, 3: 1650.80, 4: 1320.45, 
      5: 1977.94, 6: 1240.50, 7: 1890.75, 8: 1420.30,
      9: 1180.25, 10: 1650.80, 11: 1320.45, 12: 1977.94
    };
    return expenses[month.month] ?? 1500.0;
  }
  
  // Normaliser les données
  List<Map<String, dynamic>> _normalizeData(List<Map<String, dynamic>> rawData) {
    const maxBarHeight = 100.0;
    const maxExpense = 1000.0;
    return rawData.map((item) {
      final expense = item['expenses'] as double;
      final normalizedHeight = expense > maxExpense ? maxBarHeight : (expense / maxExpense) * maxBarHeight;
      return {
        'day': item['period'],
        'period': item['period'],
        'amount': normalizedHeight,
        'expense': expense,
        'value': '${expense.toStringAsFixed(expense >= 1000 ? 0 : 2)}€',
        'color': item['color'],
      };
    }).toList();
  }
  
  // Calculer le total des dépenses
  double getTotalExpenses([List<dynamic>? transactions]) {
    final data = getChartData(transactions);
    return data.fold(0.0, (sum, item) => sum + (item['expense'] as double));
  }
  
  // Obtenir la dépense pour une période spécifique
  double getExpenseForPeriod(String period, [List<dynamic>? transactions]) {
    final data = getChartData(transactions);
    final item = data.firstWhere((item) => item['period'] == period, orElse: () => {'expense': 0.0});
    return item['expense'] as double;
  }
  
  // Obtenir le label français pour la période
  String getPeriodLabel(String period) {
    switch (period) {
      case 'Weekly':
        return 'Semaine';
      case 'Monthly':
        return 'Mois';
      case 'Yearly':
        return 'Année';
      default:
        return 'Semaine';
    }
  }
  
  // Calculer le total des revenus
  double getTotalRevenue(List<dynamic> transactions) {
    switch (_selectedPeriod) {
      case 'Weekly':
        return _getWeeklyRevenueWithOffset(transactions, _weekOffset);
      case 'Monthly':
        return _getMonthlyRevenueWithOffset(transactions, _monthOffset);
      case 'Yearly':
        return transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
      default:
        return _getWeeklyRevenueWithOffset(transactions, _weekOffset);
    }
  }
  
  // Obtenir les revenus hebdomadaires avec offset
  double _getWeeklyRevenueWithOffset(List<dynamic> transactions, int weekOffset) {
    final now = DateTime.now();
    final startOfTargetWeek = now.subtract(Duration(days: now.weekday - 1 + (weekOffset * 7)));
    
    double totalRevenue = 0.0;
    
    for (final transaction in transactions) {
      if (transaction.isIncome) {
        final transactionDate = transaction.date;
        
        if (transactionDate.isAfter(startOfTargetWeek.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(startOfTargetWeek.add(const Duration(days: 7)))) {
          totalRevenue += transaction.amount;
        }
      }
    }
    
    return totalRevenue;
  }
  
  // Obtenir les revenus mensuels avec offset
  double _getMonthlyRevenueWithOffset(List<dynamic> transactions, int monthOffset) {
    final now = DateTime.now();
    final baseYear = monthOffset >= 0 ? now.year : now.year - 1;
    final startMonth = monthOffset == 0 ? 1 : 7;
    
    double totalRevenue = 0.0;
    
    for (final transaction in transactions) {
      if (transaction.isIncome) {
        final transactionDate = transaction.date;
        final transactionMonth = transactionDate.month;
        final transactionYear = transactionDate.year;
        
        if (transactionYear == baseYear && 
            transactionMonth >= startMonth && 
            transactionMonth < startMonth + 6) {
          totalRevenue += transaction.amount;
        }
      }
    }
    
    return totalRevenue;
  }
  
  // MÉTHODES PUBLIQUES ESSENTIELLES
  
  // Obtenir le texte de comparaison - MÉTHODE PUBLIQUE
  String getComparisonText(double totalIncome, double totalExpenses) {
    final netAmount = totalIncome - totalExpenses;
    final isPositive = netAmount >= 0;
    final absoluteAmount = netAmount.abs();
    
    String periodText = '';
    switch (_selectedPeriod) {
      case 'Weekly':
        periodText = 'cette semaine';
        break;
      case 'Monthly':
        periodText = 'ce mois';
        break;
      case 'Yearly':
        periodText = 'cette année';
        break;
    }
    
    if (isPositive) {
      return '+${absoluteAmount.toStringAsFixed(0)} € d\'économies $periodText';
    } else {
      return '${absoluteAmount.toStringAsFixed(0)} € de déficit $periodText';
    }
  }
  
  // Obtenir les transactions filtrées - MÉTHODE PUBLIQUE
  List<dynamic> getFilteredTransactions(List<dynamic> allTransactions) {
    if (_selectedDay != null && _selectedPeriod == 'Weekly') {
      // Filtrer par jour de la semaine
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentWeekday = today.weekday;
      final startOfCurrentWeek = today.subtract(Duration(days: currentWeekday - 1));
      final startOfTargetWeek = startOfCurrentWeek.add(Duration(days: _weekOffset * 7));
      final endOfTargetWeek = startOfTargetWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final dayMap = {
        'Mon': 0, 'Tue': 1, 'Wed': 2, 'Thu': 3, 
        'Fri': 4, 'Sat': 5, 'Sun': 6
      };
      final selectedDayIndex = dayMap[_selectedDay] ?? 0;

      return allTransactions
          .where((transaction) {
            final t = transaction as Transaction;
            if (!t.isExpense) return false;
            final transactionDate = t.date;
            final dayOfWeek = transactionDate.weekday - 1;
            final isInTargetWeek = !transactionDate.isBefore(startOfTargetWeek) && !transactionDate.isAfter(endOfTargetWeek);
            return isInTargetWeek && dayOfWeek == selectedDayIndex;
          })
          .toList();
    } else {
      // Logique normale selon la période
      switch (_selectedPeriod) {
        case 'Weekly':
          return allTransactions.take(5).toList();
        case 'Monthly':
          return allTransactions.take(8).toList();
        case 'Yearly':
          return allTransactions.take(10).toList();
        default:
          return allTransactions.take(5).toList();
      }
    }
  }
  
  // Obtenir le titre des transactions - MÉTHODE PUBLIQUE
  String getTransactionsTitle() {
    String title = 'Transactions récentes';
    if (_selectedDay != null) {
      if (_selectedPeriod == 'Weekly') {
        final dayNames = {
          'Mon': 'Lundi',
          'Tue': 'Mardi', 
          'Wed': 'Mercredi',
          'Thu': 'Jeudi',
          'Fri': 'Vendredi',
          'Sat': 'Samedi',
          'Sun': 'Dimanche',
        };
        title = 'Transactions du ${dayNames[_selectedDay]}';
      } else if (_selectedPeriod == 'Monthly') {
        title = 'Transactions de $_selectedDay';
      } else if (_selectedPeriod == 'Yearly') {
        title = 'Transactions de $_selectedDay';
      }
    }
    return title;
  }
  
  // Obtenir le texte de la période actuelle
  String getCurrentPeriodText() {
    switch (_selectedPeriod) {
      case 'Weekly':
        if (_weekOffset == 0) return 'Cette semaine';
        if (_weekOffset == -1) return 'Semaine précédente';
        if (_weekOffset == 1) return 'Semaine suivante';
        return _weekOffset < 0 ? 'Il y a ${-_weekOffset} semaines' : 'Dans $_weekOffset semaines';
      case 'Monthly':
        if (_monthOffset == 0) return 'Ce mois';
        if (_monthOffset == -1) return 'Mois précédent';
        if (_monthOffset == 1) return 'Mois suivant';
        return _monthOffset < 0 ? 'Il y a ${-_monthOffset} mois' : 'Dans $_monthOffset mois';
      case 'Yearly':
        if (_yearOffset == 0) return 'Cette année';
        if (_yearOffset == -1) return 'Année précédente';
        if (_yearOffset == 1) return 'Année suivante';
        return _yearOffset < 0 ? 'Il y a ${-_yearOffset} ans' : 'Dans $_yearOffset ans';
      default:
        return 'Cette semaine';
    }
  }
} 