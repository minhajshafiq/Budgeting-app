import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../widgets/arrow_painters.dart';
import '../../../core/constants/constants.dart';

class HomeController extends ChangeNotifier {
  final TransactionProvider _transactionProvider;
  final NotificationService _notificationService;
  
  // Animations
  late AnimationController mainController;
  late AnimationController pulseController;
  late Animation<double> fadeAnimation;
  late Animation<double> pulseAnimation;
  
  // Cache pour éviter les recalculs
  bool _isInitialized = false;
  
  HomeController(this._transactionProvider, this._notificationService);
  
  bool get isInitialized => _isInitialized;
  
  void initialize(TickerProvider vsync) {
    if (_isInitialized) return;
    
    // Initialiser les controllers d'animation
    mainController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );
    
    pulseController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Configurer les animations
    fadeAnimation = CurvedAnimation(
      parent: mainController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
    );
    
    pulseAnimation = CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    );
    
    _isInitialized = true;
    _startAnimations();
  }
  
  void _startAnimations() async {
    // Animation de pulsation continue pour les notifications
    pulseController.repeat(reverse: true);
    
    // Démarrer les animations principales
    mainController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  void dispose() {
    mainController.dispose();
    pulseController.dispose();
    super.dispose();
  }
  
  // Méthodes de calcul des données
  
  double getLastDayChange(TransactionProvider provider) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final today = DateTime.now();
    
    final recentTransactions = provider.transactions.where((transaction) {
      final t = transaction as Transaction;
      return t.date.isAfter(yesterday) && t.date.isBefore(today.add(const Duration(days: 1)));
    }).toList();
    
    double change = 0.0;
    for (final transaction in recentTransactions) {
      final t = transaction as Transaction;
      if (t.isIncome) {
        change += t.amount;
      } else {
        change -= t.amount;
      }
    }
    
    return change;
  }
  
  double getLastDayChangeAmount(TransactionProvider provider) {
    return getLastDayChange(provider).abs();
  }
  
  Color getLastDayChangeColor(TransactionProvider provider, BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.color!;
  }
  
  Widget buildTrendArrow(TransactionProvider provider) {
    final change = getLastDayChange(provider);
    
    if (change > 0) {
      return CustomPaint(
        size: const Size(16, 11),
        painter: ArrowUpPainter(color: AppColors.green),
      );
    } else if (change < 0) {
      return CustomPaint(
        size: const Size(16, 11),
        painter: ArrowDownPainter(color: AppColors.red),
      );
    } else {
      return Container(
        width: 16,
        height: 2,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(1),
        ),
      );
    }
  }
  
  double getWeeklyExpenses(TransactionProvider provider) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final weeklyTransactions = provider.transactions.where((transaction) {
      final t = transaction as Transaction;
      return t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
             t.date.isBefore(endOfWeek.add(const Duration(days: 1))) &&
             t.isExpense;
    }).toList();
    
    return weeklyTransactions.fold(0.0, (sum, transaction) => sum + (transaction as Transaction).amount);
  }
  
  // Méthodes de navigation avec feedback haptique
  
  void navigateToTransactionHistory(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/transactions_history');
  }
  
  void navigateToNotifications(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/notifications');
  }
  
  void navigateToStatistics(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/statistics');
  }
  
  // Méthodes pour les données du graphique
  List<Map<String, dynamic>> getWeeklyDataFromTransactions(List<dynamic> transactions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final weekData = List.generate(7, (index) {
      final dayStart = startOfWeek.add(Duration(days: index));
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayTransactions = transactions.where((transaction) {
        final t = transaction as Transaction;
        return t.date.isAfter(dayStart.subtract(const Duration(days: 1))) && 
               t.date.isBefore(dayEnd) &&
               t.isExpense;
      }).toList();
      
      final total = dayTransactions.fold(0.0, (sum, transaction) => sum + (transaction as Transaction).amount);
      
      return {
        'day': weekDays[index],
        'amount': total,
      };
    });
    
    return weekData;
  }
} 