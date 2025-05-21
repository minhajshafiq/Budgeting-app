import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BarChart extends StatelessWidget {
  final Animation<double> animation;
  final List<Map<String, dynamic>> data;
  final Set<String> daysWithLabel;

  const BarChart({
    Key? key,
    required this.animation,
    required this.data,
    this.daysWithLabel = const {'Thu', 'Sun', 'Tue', 'Sat'},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((item) {
            return _buildBar(item);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBar(Map<String, dynamic> item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (daysWithLabel.contains(item['day']))
          Text(
            item['value'],
            style: AppTextStyles.barValue,
          )
        else
          const SizedBox(height: 12),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: 30,
              height: (item['amount'] as num).toDouble() * animation.value,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          item['day'] as String,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
} 