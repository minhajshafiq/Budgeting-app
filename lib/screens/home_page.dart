import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/arrow_painters.dart';
import '../widgets/bar_chart.dart';
import '../widgets/transaction_item.dart';
import '../widgets/card_container.dart';
import '../widgets/animated_counter.dart';
import 'statistics_page.dart';
import 'transaction_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _transactionAnimations;
  
  // Liste des transactions
  late List<Map<String, dynamic>> _transactions;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.defaultDuration,
    );
    
    // Initialiser toutes les animations immédiatement
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    
    // Initialisation sécurisée des animations de transaction
    _transactionAnimations = List.generate(4, (index) {
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4 + (index * 0.1), 1.0, curve: Curves.easeOut),
      );
    });
    
    // Initialiser les transactions
    _transactions = [
      {
        'title': 'Spotify',
        'date': '1 Mai 2023',
        'amount': '-10,99€',
        'imageUrl': 'https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_Green.png',
        'category': 'Abonnements',
      },
      {
        'title': 'Amazon',
        'date': '30 Avril 2023',
        'amount': '-24,99€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Amazon_logo.svg/2560px-Amazon_logo.svg.png',
        'category': 'Shopping',
      },
      {
        'title': 'Netflix',
        'date': '29 Avril 2023',
        'amount': '-17,99€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Netflix_2015_logo.svg/2560px-Netflix_2015_logo.svg.png',
        'category': 'Abonnements',
      },
      {
        'title': 'YouTube Premium',
        'date': '28 Avril 2023',
        'amount': '-11,99€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/YouTube_full-color_icon_%282017%29.svg/1024px-YouTube_full-color_icon_%282017%29.svg.png',
        'category': 'Divertissement',
      },
    ];
    
    // Démarrer l'animation après que tout soit initialisé
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Méthode pour mettre à jour une transaction
  void _updateTransaction(int index, Map<String, dynamic> updatedData) {
    setState(() {
      _transactions[index] = updatedData;
    });
    
    // Relancer une animation pour montrer le changement
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPadding.screen,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildBalanceCard(),
                  const SizedBox(height: 16),
                  _buildWeeklySpendingCard(),
                  const SizedBox(height: 16),
                  _buildBottomNavigation(),
                  const SizedBox(height: 16),
                  _buildRecentTransactions(),
                  // Espace en bas pour la barre de navigation
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Joe Don',
              style: AppTextStyles.title,
            ),
          ],
        ),
        Container(
          decoration: AppDecorations.circleButtonDecoration,
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.text),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solde actuel',
            style: AppTextStyles.header,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedCounter(
                value: 4520.76,
                style: AppTextStyles.amountSmall,
                suffix: ' €',
                decimalPlaces: 2,
                decimalSeparator: ',',
                thousandSeparator: ' ',
              ),
              Container(
                decoration: AppDecorations.circleButtonDecoration,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.text),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Text(
                'Dernière 24h',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                children: [
                  CustomPaint(
                    size: const Size(16, 11),
                    painter: ArrowDownPainter(),
                  ),
                  const SizedBox(width: 4),
                  AnimatedCounter(
                    value: 10.99,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      fontWeight: FontWeight.normal,
                    ),
                    suffix: '€',
                    decimalPlaces: 2,
                    decimalSeparator: ',',
                    duration: const Duration(milliseconds: 1200),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySpendingCard() {
    return CardContainer(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dépensé cette semaine',
            style: AppTextStyles.header,
          ),
          Transform.translate(
            offset: const Offset(0, -2),
            child: AnimatedCounter(
              value: 520.76,
              style: AppTextStyles.amountSmall,
              prefix: '-',
              suffix: ' €',
              decimalPlaces: 2,
              decimalSeparator: ',',
              thousandSeparator: ' ',
              duration: const Duration(milliseconds: 1800),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -5),
            child: BarChart(
              animation: _animation,
              data: getWeeklyData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem(Icons.list_alt, 'Transactions'),
        _buildNavItem(Icons.account_balance_wallet, 'Pockets'),
        _buildNavItem(Icons.pie_chart, 'Analytics'),
        _buildNavItem(Icons.more_horiz, 'Plus'),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.9 + (_fadeAnimation.value * 0.1),
              child: GestureDetector(
                onTap: () {
                  if (label == 'Analytics') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatisticsPage()),
                    );
                  } else if (label == 'Transactions') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
                    );
                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: AppDecorations.circleButtonDecoration,
                  child: Icon(icon, color: AppColors.text),
                ),
              ),
            );
          }
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.navLabel,
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(_transactions.length, (index) {
            return AnimatedBuilder(
              animation: _transactionAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _transactionAnimations[index].value)),
                  child: Opacity(
                    opacity: _transactionAnimations[index].value,
                    child: Column(
                      children: [
                        TransactionItem(
                          title: _transactions[index]['title'],
                          date: _transactions[index]['date'],
                          amount: _transactions[index]['amount'],
                          imageUrl: _transactions[index]['imageUrl'],
                          category: _transactions[index]['category'],
                          onUpdate: (updatedData) => _updateTransaction(index, updatedData),
                        ),
                        if (index < _transactions.length - 1)
                          const Divider(
                            height: 20,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
} 