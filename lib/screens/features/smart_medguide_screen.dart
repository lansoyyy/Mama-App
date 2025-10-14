import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/medication_card.dart';

class SmartMedGuideScreen extends StatefulWidget {
  const SmartMedGuideScreen({super.key});

  @override
  State<SmartMedGuideScreen> createState() => _SmartMedGuideScreenState();
}

class _SmartMedGuideScreenState extends State<SmartMedGuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add medication feature coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodayTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        // Progress Card
        Card(
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
                        value: 0.75,
                        strokeWidth: 12,
                        backgroundColor: AppColors.textWhite.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.textWhite,
                        ),
                      ),
                    ),
                    const Column(
                      children: [
                        Text(
                          '3/4',
                          style: TextStyle(
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
                const Text(
                  '75% Adherence Rate',
                  style: TextStyle(
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
        MedicationCard(
          medicationName: 'Prenatal Vitamins',
          dosage: '1 tablet',
          time: '8:00 AM',
          status: 'taken',
        ),
        MedicationCard(
          medicationName: 'Iron Supplement',
          dosage: '500mg',
          time: '12:00 PM',
          status: 'taken',
        ),
        MedicationCard(
          medicationName: 'Folic Acid',
          dosage: '400mcg',
          time: '2:00 PM',
          status: 'pending',
          onMarkTaken: () {},
          onMarkMissed: () {},
        ),
        MedicationCard(
          medicationName: 'Calcium',
          dosage: '600mg',
          time: '9:00 PM',
          status: 'pending',
          onMarkTaken: () {},
          onMarkMissed: () {},
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
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
        _buildScheduleCard('Monday', 4),
        _buildScheduleCard('Tuesday', 4),
        _buildScheduleCard('Wednesday', 4),
        _buildScheduleCard('Thursday', 4),
        _buildScheduleCard('Friday', 4),
        _buildScheduleCard('Saturday', 3),
        _buildScheduleCard('Sunday', 3),
      ],
    );
  }

  Widget _buildScheduleCard(String day, int medicationCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: ListTile(
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
        subtitle: Text('$medicationCount medications scheduled'),
        trailing: const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$day schedule details coming soon')),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
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
        Card(
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
                    _buildStatItem('Taken', '24', AppColors.taken),
                    _buildStatItem('Missed', '2', AppColors.missed),
                    _buildStatItem('Rate', '92%', AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),
        
        // History List
        MedicationCard(
          medicationName: 'Prenatal Vitamins',
          dosage: '1 tablet',
          time: 'Yesterday, 8:00 AM',
          status: 'taken',
        ),
        MedicationCard(
          medicationName: 'Iron Supplement',
          dosage: '500mg',
          time: 'Yesterday, 12:00 PM',
          status: 'taken',
        ),
        MedicationCard(
          medicationName: 'Folic Acid',
          dosage: '400mcg',
          time: 'Yesterday, 2:00 PM',
          status: 'missed',
        ),
      ],
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
