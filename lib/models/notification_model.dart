import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final IconData iconData;
  final Color color;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.iconData,
    required this.color,
    required this.timestamp,
    required this.isRead,
    this.data,
  });

  factory NotificationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      iconData: _getIconData(data['type']),
      color: _getNotificationColor(data['type']),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      data: data['data'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'data': data,
    };
  }

  static IconData _getIconData(String type) {
    switch (type) {
      case 'medication_reminder':
        return Icons.medication;
      case 'medication_taken':
        return Icons.check_circle;
      case 'medication_missed':
        return Icons.cancel;
      case 'streak_achievement':
        return Icons.local_fire_department;
      case 'reward_earned':
        return Icons.stars;
      case 'appointment_reminder':
        return Icons.video_call;
      case 'appointment_confirmed':
        return Icons.event_available;
      case 'achievement_unlocked':
        return Icons.emoji_events;
      case 'health_tip':
        return Icons.lightbulb;
      case 'refill_reminder':
        return Icons.receipt;
      case 'system_update':
        return Icons.new_releases;
      case 'welcome':
        return Icons.waving_hand;
      default:
        return Icons.notifications;
    }
  }

  static Color _getNotificationColor(String type) {
    switch (type) {
      case 'medication_reminder':
        return AppColors.primary;
      case 'medication_taken':
        return AppColors.success;
      case 'medication_missed':
        return AppColors.error;
      case 'streak_achievement':
        return AppColors.reward;
      case 'reward_earned':
        return AppColors.secondary;
      case 'appointment_reminder':
        return AppColors.consultation;
      case 'appointment_confirmed':
        return AppColors.success;
      case 'achievement_unlocked':
        return AppColors.reward;
      case 'health_tip':
        return AppColors.info;
      case 'refill_reminder':
        return AppColors.warning;
      case 'system_update':
        return AppColors.accent;
      case 'welcome':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);
    final difference = now.difference(notificationDate);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class NotificationTypes {
  static const String medicationReminder = 'medication_reminder';
  static const String medicationTaken = 'medication_taken';
  static const String medicationMissed = 'medication_missed';
  static const String streakAchievement = 'streak_achievement';
  static const String rewardEarned = 'reward_earned';
  static const String appointmentReminder = 'appointment_reminder';
  static const String appointmentConfirmed = 'appointment_confirmed';
  static const String achievementUnlocked = 'achievement_unlocked';
  static const String healthTip = 'health_tip';
  static const String refillReminder = 'refill_reminder';
  static const String systemUpdate = 'system_update';
  static const String welcome = 'welcome';
}
