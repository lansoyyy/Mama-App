import 'package:flutter/material.dart';
import '../../services/launch_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
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
                const SizedBox(height: AppConstants.paddingS),
                const Text(
                  'National Emergency - Davao City',
                  style: TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                ElevatedButton.icon(
                  onPressed: () => _makeEmergencyCall('911'),
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

          const SizedBox(height: AppConstants.paddingM),
          const Text(
            'Davao City Emergency Services',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingM),

          _buildEmergencyContact('Davao City 911', '911', Icons.emergency,
              'Primary emergency hotline'),
          _buildEmergencyContact('Davao City Police', '(082) 227-8449',
              Icons.local_police, 'DCPO Headquarters'),
          _buildEmergencyContact('Davao City Fire', '(082) 222-4161',
              Icons.local_fire_department, 'Bureau of Fire Protection'),
          _buildEmergencyContact('Davao Medical Center', '(082) 227-9112',
              Icons.local_hospital, 'Emergency Room'),
          _buildEmergencyContact('Southern Philippines Medical Center',
              '(082) 227-2345', Icons.local_hospital, 'SPMC Emergency'),
          _buildEmergencyContact('Red Cross Davao', '(082) 227-6131',
              Icons.health_and_safety, 'Philippine Red Cross'),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(
      String name, String number, IconData icon, String description) {
    return Builder(
      builder: (context) => CustomCard(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppConstants.paddingM),
          leading: Container(
            padding: const EdgeInsets.all(AppConstants.paddingS),
            decoration: BoxDecoration(
              color: AppColors.emergency.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(icon,
                color: AppColors.emergency, size: AppConstants.iconL),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.paddingXS),
              Text(
                description,
                style: const TextStyle(
                  fontSize: AppConstants.fontS,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXS),
              Text(
                number,
                style: const TextStyle(
                  fontSize: AppConstants.fontM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.emergency,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.phone, color: AppColors.emergency),
            onPressed: () => _makeEmergencyCall(number),
          ),
        ),
      ),
    );
  }

  Future<void> _makeEmergencyCall(String phoneNumber) async {
    try {
      await LaunchService.makePhoneCall(phoneNumber);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not make phone call: $e')),
        );
      }
    }
  }
}
