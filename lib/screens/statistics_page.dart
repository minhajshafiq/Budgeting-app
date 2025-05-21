import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/constants.dart';
import '../widgets/arrow_painters.dart';
import '../widgets/bar_chart.dart';
import '../widgets/transaction_item.dart';
import '../widgets/card_container.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  bool _showPeriodSelector = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _selectedPeriod = 'Weekly';
  String _selectedTimeFilter = '1 s';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.defaultDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppPadding.screen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildExpensesCard(),
                    const SizedBox(height: 24),
                    _buildTimeFilters(),
                    const SizedBox(height: 24),
                    _buildTransactionsHeader(),
                    const SizedBox(height: 16),
                    _buildTransactionsList(),
                    // Espace en bas pour la barre de navigation
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          if (_showPeriodSelector) _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: AppDecorations.circleButtonDecoration,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        const Text(
          'Vos Statistiques',
          style: AppTextStyles.title,
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.bar_chart,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.text,
                size: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpensesCard() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dépensé',
                style: AppTextStyles.header,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showPeriodSelector = !_showPeriodSelector;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedPeriod,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          const Text(
            '520,76 €',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              CustomPaint(
                size: const Size(16, 11),
                painter: ArrowUpPainter(color: AppColors.red),
              ),
              const SizedBox(width: 4),
              const Text(
                '50 € en plus que la semaine dernière',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BarChart(
            animation: _animation,
            data: getWeeklyData(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem('Revenu', '+300 €', AppColors.green, isRevenu: true),
              _buildSummaryItem('Dépense', '-300 €', AppColors.red, isRevenu: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color color, {required bool isRevenu}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isRevenu ? const Color(0xFFE6F8EA) : const Color(0xFFFDE8E8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(22, 22),
                painter: isRevenu 
                    ? ArrowDownLeftPainter(color: const Color(0xFF28A745))
                    : ArrowUpRightPainter(color: const Color(0xFFDC3545)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters() {
    final List<String> filters = ['1 s', '1 m', '6 m', '1 a'];
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = _selectedTimeFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeFilter = filter;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    return const Text(
      'Transactions récentes',
      style: AppTextStyles.subtitle,
    );
  }

  Widget _buildTransactionsList() {
    return CardContainer(
      child: Column(
        children: List.generate(5, (index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TransactionItem(
                  title: 'Spotify',
                  date: '1 Mai 2025',
                  amount: '-10,99€',
                ),
              ),
              if (index < 4)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final List<String> periods = ['Weekly', 'Monthly', 'Yearly'];
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showPeriodSelector = false;
          });
        },
        child: Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0 * value,
                  sigmaY: 5.0 * value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3 * value),
                  child: Transform.translate(
                    offset: Offset(0, 100 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Barre de drag
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Titre avec animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        tween: Tween<double>(begin: 0.8, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Sélectionner une période',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Options de période avec animation
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Column(
                          children: List.generate(periods.length, (index) {
                            final period = periods[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              curve: Curves.easeOutQuart,
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(30 * (1 - value), 0),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPeriod = period;
                                    _showPeriodSelector = false;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: period == _selectedPeriod ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: period == _selectedPeriod ? AppColors.primary : Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: period == _selectedPeriod ? AppColors.primary : Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: period == _selectedPeriod ? AppColors.primary : Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        child: period == _selectedPeriod
                                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        period,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: period == _selectedPeriod ? FontWeight.bold : FontWeight.normal,
                                          color: period == _selectedPeriod ? AppColors.primary : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 