import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/medication_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class SmartMedGuideScreen extends StatefulWidget {
  const SmartMedGuideScreen({super.key});

  @override
  State<SmartMedGuideScreen> createState() => _SmartMedGuideScreenState();
}

class _SmartMedGuideScreenState extends State<SmartMedGuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _medicationStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMedicationStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicationStats() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final stats = await _firestoreService.getMedicationStats(userId);
        setState(() {
          _medicationStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading medication stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final medicationDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (medicationDate == today) {
      dateStr = 'Today';
    } else if (medicationDate == yesterday) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    return '$dateStr, ${_formatTime(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Smart MedGuide',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textWhite,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Schedule'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildScheduleTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    final userId = _authService.currentUserId;

    if (userId == null) {
      return const Center(
        child: Text(
          'Please log in to view your medications',
          style: TextStyle(
            fontSize: AppConstants.fontL,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadMedicationStats();
      },
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Progress Card
          _isLoading || _medicationStats == null
              ? Card(
                  elevation: AppConstants.elevationM,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: const Center(
                      child: LoadingIndicator(),
                    ),
                  ),
                )
              : Card(
                  elevation: AppConstants.elevationM,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Today\'s Progress',
                          style: TextStyle(
                            fontSize: AppConstants.fontXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: (_medicationStats!['totalScheduled'] ??
                                            0) >
                                        0
                                    ? (_medicationStats!['totalTaken'] ?? 0) /
                                        (_medicationStats!['totalScheduled'] ??
                                            1)
                                    : 0.0,
                                strokeWidth: 12,
                                backgroundColor:
                                    AppColors.textWhite.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.textWhite,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${_medicationStats!['totalTaken'] ?? 0}/${_medicationStats!['totalScheduled'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontDisplay,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                Text(
                                  'Doses Taken',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontS,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                        Text(
                          '${_medicationStats!['adherenceRate'] ?? 0}% Adherence Rate',
                          style: const TextStyle(
                            fontSize: AppConstants.fontM,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: AppConstants.paddingL),

          // Medications List
          const Text(
            'Today\'s Medications',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Stream of today's medications
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getTodayMedicationLogs(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading medications: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No medications scheduled for today',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final medicationName =
                      data['medicationName'] ?? 'Unknown Medication';
                  final dosage = data['dosage'] ?? 'Unknown Dosage';
                  final scheduledDate =
                      (data['scheduledDate'] as Timestamp).toDate();
                  final status = data['status'] ?? 'pending';
                  final logId = doc.id;
                  final medicationId = data['medicationId'] ?? '';

                  return MedicationCard(
                    medicationName: medicationName,
                    dosage: dosage,
                    time: _formatTime(scheduledDate),
                    status: status,
                    onMarkTaken: status == 'pending'
                        ? () async {
                            try {
                              await _firestoreService
                                  .updateMedicationIntakeStatus(
                                logId: logId,
                                status: 'taken',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('$medicationName marked as taken!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _loadMedicationStats();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        : null,
                    onMarkMissed: status == 'pending'
                        ? () async {
                            try {
                              await _firestoreService
                                  .updateMedicationIntakeStatus(
                                logId: logId,
                                status: 'missed',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('$medicationName marked as missed'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                              _loadMedicationStats();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        : null,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final userId = _authService.currentUserId;

    if (userId == null) {
      return const Center(
        child: Text(
          'Please log in to view your schedule',
          style: TextStyle(
            fontSize: AppConstants.fontL,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadMedicationStats();
      },
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          const Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Get all active medications
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getUserMedications(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading medications: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No medications found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              // Generate weekly schedule based on medications
              final medications = snapshot.data!.docs;
              final Map<String, List<Map<String, dynamic>>> weeklySchedule = {};

              // Initialize days of the week
              final days = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ];
              for (final day in days) {
                weeklySchedule[day] = [];
              }

              // Calculate schedule for each medication
              for (final medDoc in medications) {
                final medication = medDoc.data() as Map<String, dynamic>;
                final name = medication['name'] ?? 'Unknown';
                final dosage = medication['dosage'] ?? 'Unknown';
                final frequency = medication['frequency'] ?? 'Daily';
                final timeStr = medication['time'] ?? '8:00 AM';

                // Parse time
                List<String> timeParts = timeStr.split(':');
                int hour = int.parse(timeParts[0]);
                int minute = int.parse(timeParts[1].split(' ')[0]);
                String period =
                    timeParts.length > 1 ? timeParts[1].split(' ')[1] : 'AM';

                // Convert to 24-hour format
                if (period == 'PM' && hour < 12) {
                  hour += 12;
                } else if (period == 'AM' && hour == 12) {
                  hour = 0;
                }

                // Add to each day based on frequency
                for (final day in days) {
                  if (frequency == 'Daily') {
                    weeklySchedule[day]!.add({
                      'name': name,
                      'dosage': dosage,
                      'time': '$hour:$minute',
                    });
                  } else if (frequency == 'Twice Daily') {
                    // Add morning and evening doses
                    weeklySchedule[day]!.add({
                      'name': name,
                      'dosage': dosage,
                      'time': '8:0', // 8:00 AM
                    });
                    weeklySchedule[day]!.add({
                      'name': name,
                      'dosage': dosage,
                      'time': '20:0', // 8:00 PM
                    });
                  } else if (frequency == 'Three Times Daily') {
                    // Add morning, afternoon, and evening doses
                    weeklySchedule[day]!.add({
                      'name': name,
                      'dosage': dosage,
                      'time': '8:0', // 8:00 AM
                    });
                    weeklySchedule[day]!.add({
                      'name': name,
                      'dosage': dosage,
                      'time': '14:0', // 2:00 PM
                    });
                    weeklySchedule[day]!.add({
                      'name': name,
                      'dosage': dosage,
                      'time': '20:0', // 8:00 PM
                    });
                  } else if (frequency == 'Weekly') {
                    // For weekly, just add to Monday for simplicity
                    if (day == 'Monday') {
                      weeklySchedule[day]!.add({
                        'name': name,
                        'dosage': dosage,
                        'time': '$hour:$minute',
                      });
                    }
                  }
                }
              }

              // Build schedule cards for each day
              return Column(
                children: days.map((day) {
                  final dayMedications = weeklySchedule[day]!;
                  return _buildScheduleCard(day, dayMedications);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
      String day, List<Map<String, dynamic>> medications) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: const Icon(Icons.calendar_today, color: AppColors.primary),
        ),
        title: Text(
          day,
          style: const TextStyle(
            fontSize: AppConstants.fontL,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('${medications.length} medications scheduled'),
        children: medications.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(AppConstants.paddingM),
                  child: Text(
                    'No medications scheduled',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              ]
            : medications.map((med) {
                final timeParts = med['time'].split(':');
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                final period = hour >= 12 ? 'PM' : 'AM';
                final displayHour =
                    hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                final timeStr =
                    '$displayHour:${minute.toString().padLeft(2, '0')} $period';

                return ListTile(
                  title: Text(med['name']),
                  subtitle: Text('${med['dosage']} • $timeStr'),
                  leading:
                      const Icon(Icons.medication, color: AppColors.primary),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final userId = _authService.currentUserId;

    if (userId == null) {
      return const Center(
        child: Text(
          'Please log in to view your history',
          style: TextStyle(
            fontSize: AppConstants.fontL,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadMedicationStats();
      },
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          const Text(
            'Adherence History',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Weekly Stats
          _isLoading || _medicationStats == null
              ? Card(
                  child: SizedBox(
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      child: const Center(child: LoadingIndicator()),
                    ),
                  ),
                )
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    child: Column(
                      children: [
                        const Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: AppConstants.fontL,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                                'Taken',
                                '${_medicationStats!['totalTaken'] ?? 0}',
                                AppColors.taken),
                            _buildStatItem(
                                'Missed',
                                '${_medicationStats!['totalMissed'] ?? 0}',
                                AppColors.missed),
                            _buildStatItem(
                                'Rate',
                                '${_medicationStats!['adherenceRate'] ?? 0}%',
                                AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: AppConstants.paddingL),

          // History List - Get medication logs for the past week
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('medication_logs')
                .where('userId', isEqualTo: userId)
                .where('scheduledDate',
                    isGreaterThanOrEqualTo:
                        DateTime.now().subtract(const Duration(days: 7)))
                .orderBy('scheduledDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading history: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No medication history found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final medicationName =
                      data['medicationName'] ?? 'Unknown Medication';
                  final dosage = data['dosage'] ?? 'Unknown Dosage';
                  final scheduledDate =
                      (data['scheduledDate'] as Timestamp).toDate();
                  final status = data['status'] ?? 'pending';

                  return MedicationCard(
                    medicationName: medicationName,
                    dosage: dosage,
                    time: _formatDateTime(scheduledDate),
                    status: status,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppConstants.fontXXL,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontS,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
