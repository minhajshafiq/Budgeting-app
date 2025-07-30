import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../controllers/transaction_history_controller.dart';

class InteractiveCalendar extends StatelessWidget {
  final TransactionHistoryController controller;
  final bool isDark;

  const InteractiveCalendar({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2746) : const Color(0xFF2E3A59),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              _buildMonthSelector(),
              const SizedBox(height: 4),
              _buildDaysOfWeekHeader(),
              const SizedBox(height: 4),
              _buildCalendarDays(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.getMonthYearText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left, 
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () => controller.changeMonth(-1),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right, 
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () => controller.changeMonth(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 36, child: Center(child: Text('L', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
          SizedBox(width: 36, child: Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
          SizedBox(width: 36, child: Center(child: Text('M', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
          SizedBox(width: 36, child: Center(child: Text('J', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
          SizedBox(width: 36, child: Center(child: Text('V', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
          SizedBox(width: 36, child: Center(child: Text('S', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
          SizedBox(width: 36, child: Center(child: Text('D', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildCalendarDays() {
    // Calculate first day of month and days in month
    final firstDay = DateTime(controller.selectedMonth.year, controller.selectedMonth.month, 1);
    final daysInMonth = DateTime(controller.selectedMonth.year, controller.selectedMonth.month + 1, 0).day;
    
    // Calculate which day of the week the first day falls on (0 = Monday in our UI)
    int firstDayOfWeek = firstDay.weekday - 1;

    // Get current date to highlight today
    final now = DateTime.now();
    final isCurrentMonth = now.year == controller.selectedMonth.year && now.month == controller.selectedMonth.month;
    final today = now.day;

    // Build calendar grid
    List<Widget> calendarDays = [];
    
    // Add empty cells for days before the 1st of the month
    for (int i = 0; i < firstDayOfWeek; i++) {
      calendarDays.add(Container(width: 36, height: 36));
    }
    
    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final isHighlighted = controller.highlightedDays.contains(day);
      final isToday = isCurrentMonth && day == today;
      final isSelected = controller.isSelected(day);
      final isAfterToday = controller.isAfterToday(day);
      
      calendarDays.add(
        GestureDetector(
          onTap: isHighlighted ? () {
            controller.selectDay(day, isAfterToday);
          } : null,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday 
                  ? Colors.white 
                  : (isHighlighted ? controller.getTransactionColor(day) : Colors.transparent),
              border: isToday 
                  ? Border.all(color: const Color(0xFFA7C4FF), width: 2) 
                  : (isSelected && isHighlighted && controller.isDayMode 
                      ? Border.all(color: Colors.white, width: 2) 
                      : null),
              boxShadow: isSelected && isHighlighted && !isToday && controller.isDayMode
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
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
} 