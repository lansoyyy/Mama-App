import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: () {
              _showMarkAllReadDialog();
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          const Text(
            'Today',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          _buildNotificationItem(
            'Medication Reminder',
            'Time to take your Prenatal Vitamins (1 tablet)',
            '10 minutes ago',
            Icons.medication,
            AppColors.primary,
            true,
          ),
          _buildNotificationItem(
            'Streak Achievement! 🔥',
            'Congratulations! You\'ve maintained a 12-day streak!',
            '2 hours ago',
            Icons.local_fire_department,
            AppColors.reward,
            true,
          ),
          _buildNotificationItem(
            'Upcoming Consultation',
            'Your appointment with Dr. Maria Santos is tomorrow at 2:00 PM',
            '3 hours ago',
            Icons.video_call,
            AppColors.consultation,
            false,
          ),
          const SizedBox(height: AppConstants.paddingL),
          const Text(
            'Yesterday',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          _buildNotificationItem(
            'Medication Taken',
            'You successfully took Iron Supplement at 8:00 AM',
            'Yesterday, 8:05 AM',
            Icons.check_circle,
            AppColors.success,
            false,
          ),
          _buildNotificationItem(
            'Reward Earned',
            'You earned 50 points for maintaining your adherence!',
            'Yesterday, 6:30 PM',
            Icons.stars,
            AppColors.secondary,
            false,
          ),
          _buildNotificationItem(
            'Health Tip',
            'Remember to stay hydrated! Drink at least 8 glasses of water daily.',
            'Yesterday, 9:00 AM',
            Icons.lightbulb,
            AppColors.info,
            false,
          ),
          const SizedBox(height: AppConstants.paddingL),
          const Text(
            'Earlier',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          _buildNotificationItem(
            'New Feature Available',
            'Check out the new Health Journal feature to track your daily wellness!',
            '2 days ago',
            Icons.new_releases,
            AppColors.accent,
            false,
          ),
          _buildNotificationItem(
            'Prescription Reminder',
            'Your prescription for Folic Acid needs refill in 5 days',
            '3 days ago',
            Icons.receipt,
            AppColors.warning,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
    bool isUnread,
  ) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      color: isUnread ? AppColors.primaryLight.withOpacity(0.1) : null,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              message,
              style: const TextStyle(
                fontSize: AppConstants.fontM,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              time,
              style: const TextStyle(
                fontSize: AppConstants.fontS,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        onTap: () {
          _showNotificationDetail(title, message, time);
        },
      ),
    );
  }

  void _showNotificationDetail(String title, String message, String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              time,
              style: const TextStyle(
                fontSize: AppConstants.fontS,
                color: AppColors.textLight,
              ),
            ),
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

  void _showMarkAllReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
    );
  }
}
