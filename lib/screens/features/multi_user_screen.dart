import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class MultiUserScreen extends StatelessWidget {
  const MultiUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Users'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          CustomCard(
            gradient: AppColors.secondaryGradient,
            child: const Column(
              children: [
                Icon(Icons.family_restroom, size: AppConstants.iconXXL, color: AppColors.textWhite),
                SizedBox(height: AppConstants.paddingM),
                Text(
                  'Family Care Management',
                  style: TextStyle(fontSize: AppConstants.fontXL, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppConstants.paddingS),
                Text(
                  'Manage medications for your family members',
                  style: TextStyle(fontSize: AppConstants.fontM, color: AppColors.textWhite),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          _buildUserCard('Maria Santos', 'Mother', 'Primary Account', Icons.person, AppColors.primary, true),
          _buildUserCard('Baby Juan', 'Child', '6 months old', Icons.child_care, AppColors.info, false),
          _buildUserCard('Lola Rosa', 'Elderly', '65 years old', Icons.elderly, AppColors.secondary, false),
          
          const SizedBox(height: AppConstants.paddingM),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add family member feature coming soon')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Family Member'),
          ),
        ],
      ),
    );
  }

  static Widget _buildUserCard(String name, String role, String info, IconData icon, Color color, bool isPrimary) {
    return Builder(
      builder: (context) => CustomCard(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name profile coming soon')),
          );
        },
        child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: AppConstants.iconL),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontSize: AppConstants.fontL, fontWeight: FontWeight.w600)),
                    if (isPrimary) ...[
                      const SizedBox(width: AppConstants.paddingS),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingS, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: const Text('Primary', style: TextStyle(fontSize: AppConstants.fontXS, color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(role, style: const TextStyle(fontSize: AppConstants.fontM, color: AppColors.textSecondary)),
                Text(info, style: const TextStyle(fontSize: AppConstants.fontS, color: AppColors.textLight)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
        ],
      ),
    ));
  }
}
