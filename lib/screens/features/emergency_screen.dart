import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Emergency Help',
        backgroundColor: AppColors.emergency,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Emergency Call Card
          CustomCard(
            gradient: LinearGradient(
              colors: [
                AppColors.emergency,
                AppColors.emergency.withOpacity(0.8),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emergency,
                  size: AppConstants.iconXXL,
                  color: AppColors.textWhite,
                ),
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'Emergency Hotline',
                  style: TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                const Text(
                  '911',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling 911...')),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textWhite,
                    foregroundColor: AppColors.emergency,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          _buildEmergencyContact('Ambulance', '117', Icons.local_hospital),
          _buildEmergencyContact('Fire Department', '160', Icons.local_fire_department),
          _buildEmergencyContact('Police', '166', Icons.local_police),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(String name, String number, IconData icon) {
    return Builder(
      builder: (context) => CustomCard(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
        child: ListTile(
          leading: Icon(icon, color: AppColors.emergency, size: AppConstants.iconL),
          title: Text(name),
          subtitle: Text(number),
          trailing: IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $name...')),
              );
            },
          ),
        ),
      ),
    );
  }
}
