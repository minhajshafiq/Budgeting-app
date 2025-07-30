import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/smart_back_button.dart';
import '../../../widgets/modern_animations.dart';
import '../../../presentation/providers/transaction_provider_clean.dart';
import '../controllers/transaction_history_controller.dart';
import '../widgets/interactive_calendar.dart';
import '../widgets/date_filter_buttons.dart';
import '../widgets/transactions_list.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> 
    with TickerProviderStateMixin {
  
  late TransactionHistoryController _controller;
  late bool isDark;
  
  // Controllers d'animation
  late AnimationController _headerController;
  late AnimationController _calendarController;
  late AnimationController _transactionsController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser le controller
    _controller = TransactionHistoryController(
      Provider.of<TransactionProviderClean>(context, listen: false),
    );
    
    // Initialisation des controllers d'animation
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _transactionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Configurer le controller avec les animations
    _controller.setAnimationControllers(
      header: _headerController,
      calendar: _calendarController,
      transactions: _transactionsController,
    );
    
    // Initialiser le provider de transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize();
    });
  }
  
  @override
  void dispose() {
    _headerController.dispose();
    _calendarController.dispose();
    _transactionsController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDark = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<TransactionProviderClean>(
          builder: (context, transactionProvider, child) {
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec animation d'entrée
                  SlideInAnimation(
                    beginOffset: const Offset(0, -0.3),
                    duration: const Duration(milliseconds: 600),
                    child: _controller.isInitialized 
                      ? FadeTransition(
                          opacity: _controller.headerAnimation,
                          child: _buildHeader(),
                        )
                      : _buildHeader(),
                  ),
                  const SizedBox(height: 8),
                  
                  // Calendrier avec animation
                  SlideInAnimation(
                    beginOffset: const Offset(0, 0.3),
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 800),
                    child: _controller.isInitialized 
                      ? FadeTransition(
                          opacity: _controller.calendarAnimation,
                          child: InteractiveCalendar(
                            controller: _controller,
                            isDark: isDark,
                          ),
                        )
                      : InteractiveCalendar(
                          controller: _controller,
                          isDark: isDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Titre des transactions avec animation
                  SlideInAnimation(
                    beginOffset: const Offset(-0.3, 0),
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        'Transactions',
                        style: AppTextStyles.subtitle(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Boutons de filtrage avec animation
                  SlideInAnimation(
                    beginOffset: const Offset(0.3, 0),
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 600),
                    child: DateFilterButtons(controller: _controller),
                  ),
                  const SizedBox(height: 4),
                  
                  // Titre de la date sélectionnée avec animation
                  if (_controller.selectedDay != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, child) {
                          return Text(
                            _controller.getDynamicTitle(),
                            style: AppTextStyles.header(context),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Liste des transactions avec animation
                  _controller.isInitialized 
                    ? FadeTransition(
                        opacity: _controller.transactionsAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: TransactionsList(
                            controller: _controller,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        child: TransactionsList(
                          controller: _controller,
                        ),
                      ),
                  // Espace en bas pour la barre de navigation
                  SizedBox(height: Platform.isAndroid ? 100 : 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SmartBackButton(),
          Text(
            'Vos Transactions',
            style: AppTextStyles.title(context),
          ),
          // Élément invisible pour équilibrer le titre au centre
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
} 