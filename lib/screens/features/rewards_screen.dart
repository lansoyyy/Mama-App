import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rewards & Achievements',
        backgroundColor: AppColors.reward,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Points Card
          CustomCard(
            gradient: LinearGradient(
              colors: [
                AppColors.reward,
                AppColors.reward.withOpacity(0.7),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.stars,
                  size: AppConstants.iconXXL,
                  color: AppColors.textWhite,
                ),
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'Your Points',
                  style: TextStyle(
                    fontSize: AppConstants.fontL,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                const Text(
                  '850',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                LinearProgressIndicator(
                  value: 0.85,
                  backgroundColor: AppColors.textWhite.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                const Text(
                  '150 points to next reward',
                  style: TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          // Current Streak
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: AppConstants.iconXL,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      const Text(
                        '12 Days',
                        style: TextStyle(
                          fontSize: AppConstants.fontXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Current Streak',
                        style: TextStyle(
                          fontSize: AppConstants.fontS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: AppConstants.iconXL,
                        color: AppColors.reward,
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      const Text(
                        '8',
                        style: TextStyle(
                          fontSize: AppConstants.fontXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Badges Earned',
                        style: TextStyle(
                          fontSize: AppConstants.fontS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          // Achievements
          const Text(
            'Your Achievements',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          _buildBadgeCard(
            'Perfect Week',
            'Complete all medications for 7 days',
            Icons.calendar_today,
            AppColors.success,
            true,
          ),
          _buildBadgeCard(
            'Early Bird',
            'Take morning medications on time for 5 days',
            Icons.wb_sunny,
            AppColors.warning,
            true,
          ),
          _buildBadgeCard(
            'Consistent Care',
            'Maintain 90% adherence for a month',
            Icons.favorite,
            AppColors.primary,
            true,
          ),
          _buildBadgeCard(
            'Health Champion',
            'Complete 100 doses',
            Icons.emoji_events,
            AppColors.reward,
            false,
          ),
          _buildBadgeCard(
            'Wellness Warrior',
            'Use the app for 30 consecutive days',
            Icons.shield,
            AppColors.secondary,
            false,
          ),
          
          const SizedBox(height: AppConstants.paddingL),
          
          // Redeemable Rewards
          const Text(
            'Redeemable Rewards',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          _buildRewardCard(
            'Health Kit',
            '1000 points',
            'Basic health monitoring kit',
            Icons.medical_services,
            false,
          ),
          _buildRewardCard(
            'Free Consultation',
            '500 points',
            'One free video consultation',
            Icons.video_call,
            true,
          ),
          _buildRewardCard(
            'Wellness Guide',
            '300 points',
            'Digital wellness and nutrition guide',
            Icons.book,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isEarned,
  ) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(isEarned ? 0.2 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppConstants.iconL,
              color: isEarned ? color : AppColors.textLight,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                        color: isEarned
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isEarned) ...[
                      const SizedBox(width: AppConstants.paddingS),
                      const Icon(
                        Icons.check_circle,
                        size: AppConstants.iconS,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(
    String title,
    String points,
    String description,
    IconData icon,
    bool canRedeem,
  ) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.reward.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  icon,
                  size: AppConstants.iconL,
                  color: AppColors.reward,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.stars,
                    size: AppConstants.iconS,
                    color: AppColors.reward,
                  ),
                  const SizedBox(width: AppConstants.paddingXS),
                  Text(
                    points,
                    style: const TextStyle(
                      fontSize: AppConstants.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.reward,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: canRedeem ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.reward,
                ),
                child: Text(canRedeem ? 'Redeem' : 'Locked'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
