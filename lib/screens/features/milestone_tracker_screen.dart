import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/reward_model.dart';

class MilestoneTrackerScreen extends StatefulWidget {
  const MilestoneTrackerScreen({super.key});

  @override
  State<MilestoneTrackerScreen> createState() => _MilestoneTrackerScreenState();
}

class _MilestoneTrackerScreenState extends State<MilestoneTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _medicationStats;
  Map<String, dynamic>? _postpartumProgress;
  Map<String, dynamic>? _vaccinationProgress;
  Map<String, dynamic>? _weightProgress;
  Map<String, dynamic>? _journalProgress;
  Map<String, dynamic>? _symptomProgress;
  List<AchievementModel> _achievements = [];
  Set<String> _earnedAchievementIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMilestoneData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMilestoneData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        // Load user stats and achievements
        final userStats =
            await _firestoreService.getAchievementProgress(userId);
        final medicationStats =
            await _firestoreService.getMedicationStats(userId);

        // Check and award any new achievements
        await _firestoreService.checkAndAwardAchievements(userId);

        // Load available achievements
        final achievementsSnapshot =
            await _firestoreService.getAvailableAchievements().first;
        final achievements = achievementsSnapshot.docs.map((doc) {
          return AchievementModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        // Load user's earned achievements
        final userAchievementsSnapshot =
            await _firestoreService.getUserAchievements(userId).first;
        final earnedAchievementIds = userAchievementsSnapshot.docs
            .map((doc) => doc.get('achievementId').toString())
            .toSet();

        // Load health records count
        final healthRecordsSnapshot =
            await _firestoreService.getUserHealthRecords(userId).first;
        final healthRecordsCount = healthRecordsSnapshot.docs.length;

        // Load all milestone progress data
        final postpartumProgress =
            await _firestoreService.getPostpartumProgress(userId);
        final vaccinationProgress =
            await _firestoreService.getVaccinationProgress(userId);
        final weightProgress =
            await _firestoreService.getWeightTrackingProgress(userId);
        final journalProgress =
            await _firestoreService.getJournalProgress(userId, 10);
        final symptomProgress =
            await _firestoreService.getSymptomProgress(userId, 15);

        setState(() {
          _userStats = userStats;
          _medicationStats = medicationStats;
          _postpartumProgress = postpartumProgress;
          _vaccinationProgress = vaccinationProgress;
          _weightProgress = weightProgress;
          _journalProgress = journalProgress;
          _symptomProgress = symptomProgress;
          _achievements = achievements;
          _earnedAchievementIds = earnedAchievementIds;
          _userStats!['healthRecordsCount'] = healthRecordsCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading milestone data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _authService.currentUserId;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Health Milestones',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textWhite,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Maternal'),
            Tab(text: 'Baby'),
          ],
        ),
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please log in to view milestones'))
          : RefreshIndicator(
              onRefresh: _loadMilestoneData,
              child: _isLoading
                  ? const LoadingIndicator()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildMaternalMilestonesTab(),
                        _buildBabyMilestonesTab(),
                      ],
                    ),
            ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        // Progress Overview Card
        CustomCard(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.2),
              AppColors.success.withOpacity(0.05)
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events,
                  size: AppConstants.iconXXL, color: AppColors.success),
              const SizedBox(height: AppConstants.paddingM),
              const Text('Your Journey Progress',
                  style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.paddingS),
              Text('Track your health and wellness achievements',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),

        // Key Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Medication Adherence',
                '${_medicationStats?['adherenceRate'] ?? 0}%',
                Icons.medication,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: _buildStatCard(
                'Current Streak',
                '${_userStats?['streakDays'] ?? 0} days',
                Icons.local_fire_department,
                AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Health Records',
                '${_userStats?['healthRecordsCount'] ?? 0}',
                Icons.folder,
                AppColors.info,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: _buildStatCard(
                'Achievements',
                '${_earnedAchievementIds.length}',
                Icons.stars,
                AppColors.reward,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingL),

        // Recent Achievements
        const Text('Recent Achievements',
            style: TextStyle(
                fontSize: AppConstants.fontXL, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.paddingM),
        _buildRecentAchievements(),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        children: [
          Icon(icon, size: AppConstants.iconXL, color: color),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            title,
            style: const TextStyle(
                fontSize: AppConstants.fontS, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    final recentAchievements = _achievements
        .where((achievement) => _earnedAchievementIds.contains(achievement.id))
        .take(3)
        .toList();

    if (recentAchievements.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            children: [
              Icon(Icons.emoji_events_outlined,
                  size: 48, color: AppColors.textLight),
              const SizedBox(height: AppConstants.paddingM),
              const Text(
                'No achievements yet',
                style: TextStyle(
                    fontSize: AppConstants.fontL,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.paddingS),
              const Text(
                'Complete health activities to earn your first achievement!',
                style: TextStyle(
                    fontSize: AppConstants.fontM, color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recentAchievements
          .map((achievement) => _buildAchievementCard(achievement, true))
          .toList(),
    );
  }

  Widget _buildMaternalMilestonesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        const Text('Maternal Health Milestones',
            style: TextStyle(
                fontSize: AppConstants.fontXL, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.paddingM),

        // Postpartum Recovery Milestone
        _buildMilestoneCard(
          'Postpartum Recovery',
          '6 weeks recovery period',
          _calculatePostpartumProgress(),
          AppColors.primary,
          _isPostpartumCompleted(),
        ),

        // Medication Adherence Milestone
        _buildMilestoneCard(
          'Medication Adherence',
          '90% adherence rate',
          (_medicationStats?['adherenceRate'] ?? 0).toDouble(),
          AppColors.secondary,
          (_medicationStats?['adherenceRate'] ?? 0) >= 90,
        ),

        // Health Records Milestone
        _buildMilestoneCard(
          'Health Documentation',
          '5 health records',
          _calculateHealthRecordsProgress(5),
          AppColors.info,
          (_userStats?['healthRecordsCount'] ?? 0) >= 5,
        ),

        // Streak Milestone
        _buildMilestoneCard(
          'Consistency Champion',
          '7 day streak',
          _calculateStreakProgress(7),
          AppColors.success,
          (_userStats?['streakDays'] ?? 0) >= 7,
        ),

        // Points Milestone
        _buildMilestoneCard(
          'Points Collector',
          '100 reward points',
          _calculatePointsProgress(100),
          AppColors.reward,
          (_userStats?['totalPoints'] ?? 0) >= 100,
        ),
      ],
    );
  }

  Widget _buildBabyMilestonesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        const Text('Baby Health Milestones',
            style: TextStyle(
                fontSize: AppConstants.fontXL, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.paddingM),

        // Vaccination Milestone
        _buildMilestoneCard(
          'Vaccination Tracker',
          '${_vaccinationProgress?['completedVaccinations'] ?? 0}/${_vaccinationProgress?['totalVaccinations'] ?? 8} vaccinations completed',
          _calculateVaccinationProgress(),
          AppColors.warning,
          _vaccinationProgress?['isCompleted'] ?? false,
        ),

        // Weight Monitoring Milestone
        _buildMilestoneCard(
          'Weight Monitoring',
          '${_weightProgress?['weightEntries'] ?? 0}/${_weightProgress?['targetEntries'] ?? 4} entries this month',
          _calculateWeightTrackingProgress(),
          AppColors.info,
          _weightProgress?['isCompleted'] ?? false,
        ),

        // Medication Management Milestone
        _buildMilestoneCard(
          'Medication Management',
          '30 medications taken',
          _calculateMedicationCountProgress(30),
          AppColors.primary,
          (_userStats?['totalDoses'] ?? 0) >= 30,
        ),

        // Health Journal Milestone
        _buildMilestoneCard(
          'Health Journaling',
          '${_journalProgress?['entryCount'] ?? 0}/${_journalProgress?['targetCount'] ?? 10} journal entries',
          _calculateJournalProgress(10),
          AppColors.secondary,
          _journalProgress?['isCompleted'] ?? false,
        ),

        // Symptom Tracking Milestone
        _buildMilestoneCard(
          'Symptom Awareness',
          '${_symptomProgress?['logCount'] ?? 0}/${_symptomProgress?['targetCount'] ?? 15} symptom logs',
          _calculateSymptomProgress(15),
          AppColors.success,
          _symptomProgress?['isCompleted'] ?? false,
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(String title, String subtitle, double progress,
      Color color, bool isCompleted) {
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
                    Text(title,
                        style: const TextStyle(
                            fontSize: AppConstants.fontL,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: AppConstants.fontS,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: AppConstants.iconL),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${progress.round()}% Complete',
                  style: TextStyle(
                      fontSize: AppConstants.fontS,
                      color: color,
                      fontWeight: FontWeight.w600)),
              if (isCompleted)
                Text('Completed!',
                    style: TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement, bool isEarned) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
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
                Text(
                  achievement.description,
                  style: const TextStyle(
                      fontSize: AppConstants.fontS,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (isEarned)
            const Icon(Icons.check_circle,
                color: AppColors.success, size: AppConstants.iconL),
        ],
      ),
    );
  }

  // Progress calculation methods
  double _calculatePostpartumProgress() {
    return _postpartumProgress?['recoveryProgress']?.toDouble() ?? 0.0;
  }

  bool _isPostpartumCompleted() {
    return _postpartumProgress?['isCompleted'] ?? false;
  }

  double _calculateHealthRecordsProgress(int target) {
    int current = _userStats?['healthRecordsCount'] ?? 0;
    return (current / target * 100).clamp(0.0, 100.0);
  }

  double _calculateStreakProgress(int target) {
    int current = _userStats?['streakDays'] ?? 0;
    return (current / target * 100).clamp(0.0, 100.0);
  }

  double _calculatePointsProgress(int target) {
    int current = _userStats?['totalPoints'] ?? 0;
    return (current / target * 100).clamp(0.0, 100.0);
  }

  double _calculateVaccinationProgress() {
    return _vaccinationProgress?['progress']?.toDouble() ?? 0.0;
  }

  double _calculateWeightTrackingProgress() {
    return _weightProgress?['progress']?.toDouble() ?? 0.0;
  }

  double _calculateMedicationCountProgress(int target) {
    int current = _userStats?['totalDoses'] ?? 0;
    return (current / target * 100).clamp(0.0, 100.0);
  }

  double _calculateJournalProgress(int target) {
    return _journalProgress?['progress']?.toDouble() ?? 0.0;
  }

  double _calculateSymptomProgress(int target) {
    return _symptomProgress?['progress']?.toDouble() ?? 0.0;
  }
}
