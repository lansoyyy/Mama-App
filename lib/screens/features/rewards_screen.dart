import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/reward_model.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewardsData();
  }

  Future<void> _loadRewardsData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        // Load user stats
        final stats = await _firestoreService.getAchievementProgress(userId);

        // Check and award any new achievements
        await _firestoreService.checkAndAwardAchievements(userId);

        setState(() {
          _userStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading rewards data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _redeemReward(String rewardId, int pointsRequired) async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        await _firestoreService.redeemReward(
          userId: userId,
          rewardId: rewardId,
          pointsRequired: pointsRequired,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reward redeemed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        // Refresh data
        await _loadRewardsData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error redeeming reward: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  int _calculateNextRewardPoints(List<RewardModel> availableRewards) {
    if (availableRewards.isEmpty) return 0;

    int currentPoints = _userStats?['totalPoints'] ?? 0;

    // Find the next reward the user can afford
    List<RewardModel> affordableRewards = availableRewards
        .where((reward) => reward.pointsRequired > currentPoints)
        .toList();

    if (affordableRewards.isEmpty) return 0;

    affordableRewards
        .sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));
    return affordableRewards.first.pointsRequired - currentPoints;
  }

  double _calculateProgressToNextReward(List<RewardModel> availableRewards) {
    if (availableRewards.isEmpty) return 1.0;

    int currentPoints = _userStats?['totalPoints'] ?? 0;
    int nextRewardPoints = _calculateNextRewardPoints(availableRewards);

    if (nextRewardPoints == 0) return 1.0;

    // Find previous reward milestone
    List<RewardModel> previousRewards = availableRewards
        .where((reward) => reward.pointsRequired <= currentPoints)
        .toList();

    if (previousRewards.isEmpty) {
      // User hasn't reached any reward yet
      if (availableRewards.isNotEmpty) {
        int firstRewardPoints = availableRewards
            .reduce((a, b) => a.pointsRequired < b.pointsRequired ? a : b)
            .pointsRequired;
        return currentPoints / firstRewardPoints;
      }
      return 0.0;
    }

    previousRewards
        .sort((a, b) => b.pointsRequired.compareTo(a.pointsRequired));
    int lastRewardPoints = previousRewards.first.pointsRequired;

    // Find next reward
    List<RewardModel> nextRewards = availableRewards
        .where((reward) => reward.pointsRequired > currentPoints)
        .toList();

    if (nextRewards.isEmpty) return 1.0;

    nextRewards.sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));
    int nextRewardMilestone = nextRewards.first.pointsRequired;

    double progress = (currentPoints - lastRewardPoints) /
        (nextRewardMilestone - lastRewardPoints);
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUserId;

    if (userId == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Rewards & Achievements',
          backgroundColor: AppColors.reward,
        ),
        body: const Center(
          child: Text(
            'Please log in to view your rewards',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rewards & Achievements',
        backgroundColor: AppColors.reward,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRewardsData,
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                children: [
                  // Points Card
                  _buildPointsCard(),
                  const SizedBox(height: AppConstants.paddingL),

                  // Stats Cards
                  _buildStatsCards(),
                  const SizedBox(height: AppConstants.paddingL),

                  // Achievements Section
                  _buildAchievementsSection(),
                  const SizedBox(height: AppConstants.paddingL),

                  // Rewards Section
                  _buildRewardsSection(),
                ],
              ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAvailableRewards(),
      builder: (context, snapshot) {
        List<RewardModel> availableRewards = [];
        if (snapshot.hasData) {
          availableRewards = snapshot.data!.docs.map((doc) {
            return RewardModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        }

        int currentPoints = _userStats?['totalPoints'] ?? 0;
        int nextRewardPoints = _calculateNextRewardPoints(availableRewards);
        double progress = _calculateProgressToNextReward(availableRewards);

        return CustomCard(
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
              Text(
                '$currentPoints',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.textWhite.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.textWhite,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                nextRewardPoints > 0
                    ? '$nextRewardPoints points to next reward'
                    : 'All rewards unlocked!',
                style: const TextStyle(
                  fontSize: AppConstants.fontS,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    int streakDays = _userStats?['streakDays'] ?? 0;
    int earnedAchievements = _userStats?['earnedAchievements'] ?? 0;

    return Row(
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
                Text(
                  '$streakDays Days',
                  style: const TextStyle(
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
                Text(
                  '$earnedAchievements',
                  style: const TextStyle(
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
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Achievements',
          style: TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getAvailableAchievements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading achievements: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No achievements available',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final achievements = snapshot.data!.docs.map((doc) {
              return AchievementModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            return StreamBuilder<QuerySnapshot>(
              stream: _firestoreService
                  .getUserAchievements(_authService.currentUserId!),
              builder: (context, userAchievementsSnapshot) {
                if (!userAchievementsSnapshot.hasData) {
                  return const Center(child: LoadingIndicator());
                }

                final earnedAchievementIds = userAchievementsSnapshot.data!.docs
                    .map((doc) => doc.get('achievementId').toString())
                    .toSet();

                return Column(
                  children: achievements.map((achievement) {
                    final isEarned =
                        earnedAchievementIds.contains(achievement.id);
                    return _buildAchievementCard(achievement, isEarned);
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement, bool isEarned) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.color.withOpacity(isEarned ? 0.2 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.iconData,
              size: AppConstants.iconL,
              color: isEarned ? achievement.color : AppColors.textLight,
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
                      achievement.title,
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
                  achievement.description,
                  style: const TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (!isEarned) ...[
                  const SizedBox(height: AppConstants.paddingXS),
                  Text(
                    '+${achievement.pointsAwarded} points',
                    style: TextStyle(
                      fontSize: AppConstants.fontS,
                      color: AppColors.reward,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Redeemable Rewards',
          style: TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getAvailableRewards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading rewards: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No rewards available',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final rewards = snapshot.data!.docs.map((doc) {
              return RewardModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            return StreamBuilder<QuerySnapshot>(
              stream:
                  _firestoreService.getUserRewards(_authService.currentUserId!),
              builder: (context, userRewardsSnapshot) {
                final redeemedRewardIds = userRewardsSnapshot.data?.docs
                        .map((doc) => doc.get('rewardId').toString())
                        .toSet() ??
                    <String>{};

                final availableRewards = rewards
                    .where((reward) => !redeemedRewardIds.contains(reward.id))
                    .toList();

                if (availableRewards.isEmpty) {
                  return const Center(
                    child: Text(
                      'All rewards have been redeemed!',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return Column(
                  children: availableRewards.map((reward) {
                    int currentPoints = _userStats?['totalPoints'] ?? 0;
                    bool canRedeem = currentPoints >= reward.pointsRequired;

                    return _buildRewardCard(reward, canRedeem);
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewardCard(RewardModel reward, bool canRedeem) {
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
                  Icons.card_giftcard,
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
                      reward.title,
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(
                      reward.description,
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
                    '${reward.pointsRequired} points',
                    style: const TextStyle(
                      fontSize: AppConstants.fontM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.reward,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: canRedeem
                    ? () => _redeemReward(reward.id, reward.pointsRequired)
                    : null,
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
