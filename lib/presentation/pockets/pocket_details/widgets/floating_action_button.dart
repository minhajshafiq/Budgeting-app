import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/constants.dart';
import '../controllers/pocket_detail_controller.dart';
import 'package:hugeicons/hugeicons.dart';

class PocketFloatingActionButton extends StatelessWidget {
  final PocketDetailController controller;
  final bool isDark;

  const PocketFloatingActionButton({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        controller.showAddTransactionModal(context);
      },
      backgroundColor: controller.getPocketColor(),
      foregroundColor: Colors.white,
      elevation: 8,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.add,
        size: 28,
      ),
    );
  }


} 