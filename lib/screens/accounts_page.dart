import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 24),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // User profile section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Profile avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'johndoe@gmail.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dropdown icon
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
            
            // General section
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
              child: Text(
                'GENERAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            
            _buildSettingsCard([
              _buildSettingItem(Icons.person_outline, 'Profile', onTap: () {}),
              _buildSettingItem(Icons.notifications_none, 'Notifications', onTap: () {}),
              _buildSettingItem(Icons.nightlight_round, 'Dark mode', onTap: () {}),
            ]),
            
            // Subscriptions section
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
              child: Text(
                'SUBSCRIPTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            
            _buildSettingsCard([
              _buildSettingItem(Icons.credit_card, 'Manage your payment', onTap: () {}),
            ]),
            
            // Feedback section
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
              child: Text(
                'FEEDBACK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            
            _buildSettingsCard([
              _buildSettingItem(Icons.warning_amber_outlined, 'Report a bug', onTap: () {}),
              _buildSettingItem(Icons.send, 'Send feedback', onTap: () {}),
              _buildSettingItem(Icons.help_outline, 'Help', onTap: () {}),
              _buildSettingItem(Icons.info_outline, 'About', onTap: () {}),
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }
  
  Widget _buildSettingItem(IconData icon, String title, {required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
