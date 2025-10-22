import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class RewardModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int pointsRequired;
  final String imageUrl;
  final bool isActive;
  final String? translationFilipino;
  final String? translationCebuano;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pointsRequired,
    required this.imageUrl,
    required this.isActive,
    this.translationFilipino,
    this.translationCebuano,
  });

  factory RewardModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RewardModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      pointsRequired: data['pointsRequired'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      translationFilipino: data['translationFilipino'],
      translationCebuano: data['translationCebuano'],
    );
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final int requiredValue;
  final int pointsAwarded;
  final IconData iconData;
  final Color color;
  final bool isActive;
  final String? translationFilipino;
  final String? translationCebuano;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requiredValue,
    required this.pointsAwarded,
    required this.iconData,
    required this.color,
    required this.isActive,
    this.translationFilipino,
    this.translationCebuano,
  });

  factory AchievementModel.fromFirestore(Map<String, dynamic> data, String id) {
    IconData iconData = _getIconData(data['icon'] ?? 'star');
    Color color = _getColor(data['color'] ?? 'primary');

    return AchievementModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      requiredValue: data['requiredValue'] ?? 0,
      pointsAwarded: data['pointsAwarded'] ?? 0,
      iconData: iconData,
      color: color,
      isActive: data['isActive'] ?? true,
      translationFilipino: data['translationFilipino'],
      translationCebuano: data['translationCebuano'],
    );
  }

  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'calendar_today':
        return Icons.calendar_today;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'favorite':
        return Icons.favorite;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'shield':
        return Icons.shield;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'stars':
        return Icons.stars;
      case 'medical_services':
        return Icons.medical_services;
      case 'book':
        return Icons.book;
      default:
        return Icons.star;
    }
  }

  static Color _getColor(String colorName) {
    switch (colorName) {
      case 'primary':
        return AppColors.primary;
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'info':
        return AppColors.info;
      case 'reward':
        return AppColors.reward;
      case 'secondary':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }
}

class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime earnedAt;
  final int pointsAwarded;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.earnedAt,
    required this.pointsAwarded,
  });

  factory UserAchievementModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return UserAchievementModel(
      id: id,
      userId: data['userId'] ?? '',
      achievementId: data['achievementId'] ?? '',
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
      pointsAwarded: data['pointsAwarded'] ?? 0,
    );
  }
}

class UserRewardModel {
  final String id;
  final String userId;
  final String rewardId;
  final int pointsUsed;
  final DateTime redeemedAt;
  final String status;

  UserRewardModel({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.pointsUsed,
    required this.redeemedAt,
    required this.status,
  });

  factory UserRewardModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserRewardModel(
      id: id,
      userId: data['userId'] ?? '',
      rewardId: data['rewardId'] ?? '',
      pointsUsed: data['pointsUsed'] ?? 0,
      redeemedAt: (data['redeemedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'redeemed',
    );
  }
}
