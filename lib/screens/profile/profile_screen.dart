import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            // Profile Header
            CustomCard(
              gradient: AppColors.primaryGradient,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.textWhite,
                    child:
                        Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  const Text('Maria Santos',
                      style: TextStyle(
                          fontSize: AppConstants.fontXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite)),
                  const Text('maria.santos@email.com',
                      style: TextStyle(
                          fontSize: AppConstants.fontM,
                          color: AppColors.textWhite)),
                  const SizedBox(height: AppConstants.paddingM),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textWhite,
                        foregroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),

            _buildSettingItem(context, Icons.language, 'Language', () {
              _showLanguageDialog(context);
            }),

            _buildSettingItem(context, Icons.info, 'About', () {
              _showAboutDialog(context);
            }),
            _buildSettingItem(context, Icons.logout, 'Logout', () {
              _showLogoutDialog(context);
            }, color: AppColors.error),
          ],
        ),
      ),
    );
  }

  static void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Filipino'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Cebuano'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  static void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MAMA App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Adherence Maternal Application',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppConstants.paddingM),
            Text('Version 1.0.0'),
            SizedBox(height: AppConstants.paddingS),
            Text(
                'A comprehensive maternal health and medication adherence platform.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child:
                const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  static Widget _buildSettingItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color ?? AppColors.primary),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: AppConstants.fontL,
                      color: color ?? AppColors.textPrimary))),
          const Icon(Icons.arrow_forward_ios,
              size: AppConstants.iconS, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
