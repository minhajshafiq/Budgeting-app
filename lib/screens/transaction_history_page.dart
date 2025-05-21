import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/transaction_item.dart';
import '../widgets/card_container.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final List<String> _tabs = ['Passé', 'En cours', 'Planifié'];
  int _selectedTabIndex = 1; // "En cours" selected by default
  DateTime _selectedMonth = DateTime(2025, 5); // Mai 2025
  int? _selectedDay = 20; // Jour actuel (20 Mai 2025)
  
  // Jours avec des transactions
  final Set<int> _highlightedDays = {4, 11, 15, 18, 20, 23, 28, 31};
  
  // Transactions par jour
  final Map<String, List<Map<String, dynamic>>> _transactionsByDay = {
    '2025-05-04': [
      {
        'title': 'Netflix',
        'date': '4 Mai 2025',
        'amount': '-17,99€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Netflix_2015_logo.svg/2560px-Netflix_2015_logo.svg.png',
        'category': 'Abonnements',
      },
    ],
    '2025-05-11': [
      {
        'title': 'Spotify',
        'date': '11 Mai 2025',
        'amount': '-10,99€',
        'imageUrl': 'https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_Green.png',
        'category': 'Abonnements',
      },
    ],
    '2025-05-15': [
      {
        'title': 'Amazon',
        'date': '15 Mai 2025',
        'amount': '-34,99€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Amazon_logo.svg/2560px-Amazon_logo.svg.png',
        'category': 'Shopping',
      },
    ],
    '2025-05-18': [
      {
        'title': 'Carrefour',
        'date': '18 Mai 2025',
        'amount': '-87,45€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Carrefour_logo.svg/2560px-Carrefour_logo.svg.png',
        'category': 'Alimentation',
      },
    ],
    '2025-05-20': [
      {
        'title': 'YouTube Premium',
        'date': '20 Mai 2025',
        'amount': '-11,99€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/YouTube_full-color_icon_%282017%29.svg/1024px-YouTube_full-color_icon_%282017%29.svg.png',
        'category': 'Divertissement',
      },
    ],
    '2025-05-23': [
      {
        'title': 'SNCF',
        'date': '23 Mai 2025',
        'amount': '-49,90€',
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/SNCF_logo.svg/2560px-SNCF_logo.svg.png',
        'category': 'Transport',
      },
    ],
    '2025-05-28': [
      {
        'title': 'Salaire',
        'date': '28 Mai 2025',
        'amount': '+2 450,00€',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2830/2830284.png',
        'category': 'Revenus',
      },
    ],
    '2025-05-31': [
      {
        'title': 'Loyer',
        'date': '31 Mai 2025',
        'amount': '-850,00€',
        'imageUrl': 'https://cdn-icons-png.flaticon.com/512/2544/2544087.png',
        'category': 'Logement',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: AppDecorations.circleButtonDecoration,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'Vos Transactions',
                      style: AppTextStyles.title,
                    ),
                    // Élément invisible pour équilibrer le titre au centre
                    SizedBox(width: 40, height: 40),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildCalendar(),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: const Text(
                  'Transactions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
              const SizedBox(height: 8),
              _buildTabs(),
              const SizedBox(height: 4),
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Transactions du ${_selectedDay} ${_getMonthYearText()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: _buildTransactionsList(),
              ),
              // Espace en bas pour la barre de navigation
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMonthYearText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month - 1,
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Days of week header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                SizedBox(width: 36, child: Center(child: Text('L', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
                SizedBox(width: 36, child: Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
                SizedBox(width: 36, child: Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
                SizedBox(width: 36, child: Center(child: Text('J', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
                SizedBox(width: 36, child: Center(child: Text('V', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
                SizedBox(width: 36, child: Center(child: Text('S', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
                SizedBox(width: 36, child: Center(child: Text('D', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildCalendarDays() {
    // Calculate first day of month and days in month
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    
    // Calculate which day of the week the first day falls on (0 = Monday in our UI)
    int firstDayOfWeek = firstDay.weekday - 1;

    // Get current date to highlight today
    final now = DateTime.now();
    final isCurrentMonth = now.year == _selectedMonth.year && now.month == _selectedMonth.month;
    final today = now.day;

    // Build calendar grid
    List<Widget> calendarDays = [];
    
    // Add empty cells for days before the 1st of the month
    for (int i = 0; i < firstDayOfWeek; i++) {
      calendarDays.add(Container(width: 36, height: 36));
    }
    
    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final isHighlighted = _highlightedDays.contains(day);
      final isToday = isCurrentMonth && day == today;
      final isSelected = _selectedDay == day && _selectedMonth.year == now.year && _selectedMonth.month == now.month;
      
      // Déterminer si le jour est après aujourd'hui
      final isAfterToday = isCurrentMonth && day > today || 
                          (_selectedMonth.year > now.year || 
                          (_selectedMonth.year == now.year && _selectedMonth.month > now.month));
      
      // Couleur pour les jours avec des transactions
      final transactionColor = isAfterToday && isHighlighted 
          ? const Color(0xFFA7C4FF) 
          : AppColors.primary;
      
      calendarDays.add(
        GestureDetector(
          onTap: isHighlighted ? () => _onDaySelected(day, isAfterToday) : null,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday 
                  ? Colors.white 
                  : (isHighlighted ? transactionColor : Colors.transparent),
              border: isToday 
                  ? Border.all(color: const Color(0xFFA7C4FF), width: 2) 
                  : (isSelected && isHighlighted 
                      ? Border.all(color: Colors.white, width: 2) 
                      : null),
              boxShadow: isSelected && isHighlighted && !isToday 
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 0,
                      )
                    ] 
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: isToday 
                    ? const Color(0xFF2E3A59) 
                    : Colors.white,
                fontWeight: (isHighlighted || isToday) ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    // Calculate rows needed (ceiling division)
    final int rowCount = ((firstDayOfWeek + daysInMonth) / 7).ceil();
    
    // Organiser les jours en grille de 7 colonnes
    List<Widget> rows = [];
    for (int i = 0; i < rowCount; i++) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < 7; j++) {
        final index = i * 7 + j;
        if (index < calendarDays.length) {
          rowChildren.add(calendarDays[index]);
        } else {
          rowChildren.add(Container(width: 36, height: 36));
        }
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: rowChildren,
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: rows,
      ),
    );
  }

  // Méthode pour obtenir le nom du mois et l'année
  String _getMonthYearText() {
    final List<String> monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    final String monthName = monthNames[_selectedMonth.month - 1];
    final int year = _selectedMonth.year;
    
    return '$monthName $year';
  }
  
  // Méthode appelée lorsqu'un jour est sélectionné dans le calendrier
  void _onDaySelected(int day, bool isAfterToday) {
    setState(() {
      _selectedDay = day;
      
      // Changer l'onglet en fonction de la date (passé ou futur)
      if (isAfterToday) {
        _selectedTabIndex = 2; // Planifié
      } else {
        _selectedTabIndex = 0; // Passé
      }
    });
  }
  
  // Méthode pour obtenir les transactions du jour sélectionné
  List<Map<String, dynamic>> _getSelectedDayTransactions() {
    if (_selectedDay == null) return [];
    
    final String dateKey = '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}';
    return _transactionsByDay[dateKey] ?? [];
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isSelected = index == _selectedTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Obtenir les transactions du jour sélectionné
    final transactions = _getSelectedDayTransactions();
    
    // Si aucune transaction n'est sélectionnée, afficher un message
    if (transactions.isEmpty) {
      return CardContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedDay != null 
                    ? 'Aucune transaction le ${_selectedDay} ${_getMonthYearText()}' 
                    : 'Sélectionnez une date pour voir les transactions',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Afficher les transactions du jour sélectionné
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(transactions.length, (index) {
            final transaction = transactions[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: TransactionItem(
                    title: transaction['title'],
                    date: transaction['date'],
                    amount: transaction['amount'],
                    imageUrl: transaction['imageUrl'],
                    category: transaction['category'],
                  ),
                ),
                if (index < transactions.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}