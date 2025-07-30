import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../utils/user_provider.dart';
import '../../../widgets/user_avatar.dart';
import '../controllers/accounts_controller.dart';

class ProfileCard extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onEditPressed;

  const ProfileCard({
    super.key,
    required this.isDarkMode,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gradient
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return UserAvatar(
                initials: userProvider.initials,
                size: 60,
                fontSize: 20,
                gradientColors: const [
                  Color(0xFF8B5CF6),
                  Color(0xFF6366F1),
                ],
              );
            },
          ),
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProvider.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProvider.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Compte actif',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Edit button
          GestureDetector(
            onTap: onEditPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                HugeIcons.strokeRoundedEdit01,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 