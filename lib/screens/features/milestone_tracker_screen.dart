import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class MilestoneTrackerScreen extends StatelessWidget {
  const MilestoneTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Health Milestones'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          CustomCard(
            gradient: LinearGradient(
              colors: [AppColors.success.withOpacity(0.2), AppColors.success.withOpacity(0.05)],
            ),
            child: const Column(
              children: [
                Icon(Icons.child_care, size: AppConstants.iconXXL, color: AppColors.success),
                SizedBox(height: AppConstants.paddingM),
                Text('Track Your Journey', style: TextStyle(fontSize: AppConstants.fontXL, fontWeight: FontWeight.bold)),
                SizedBox(height: AppConstants.paddingS),
                Text('Monitor maternal recovery and baby growth', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          const Text('Maternal Milestones', style: TextStyle(fontSize: AppConstants.fontXL, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConstants.paddingM),
          _buildMilestoneCard('Postpartum Recovery', '6 weeks', 75, AppColors.primary, true),
          _buildMilestoneCard('Breastfeeding Goal', '6 months', 40, AppColors.secondary, false),
          
          const SizedBox(height: AppConstants.paddingL),
          const Text('Baby Milestones', style: TextStyle(fontSize: AppConstants.fontXL, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConstants.paddingM),
          _buildMilestoneCard('Weight Gain', 'Target: 5kg', 60, AppColors.success, false),
          _buildMilestoneCard('Vaccinations', '5/8 completed', 62, AppColors.info, false),
        ],
      ),
    );
  }

  static Widget _buildMilestoneCard(String title, String subtitle, int progress, Color color, bool isCompleted) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: AppConstants.fontL, fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(subtitle, style: const TextStyle(fontSize: AppConstants.fontS, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: AppColors.success, size: AppConstants.iconL),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          LinearProgressIndicator(value: progress / 100, backgroundColor: color.withOpacity(0.2), valueColor: AlwaysStoppedAnimation<Color>(color)),
          const SizedBox(height: AppConstants.paddingS),
          Text('$progress% Complete', style: TextStyle(fontSize: AppConstants.fontS, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
