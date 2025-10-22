import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen>
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
        title: 'Health Records',
        bottom: TabBar(
          labelColor: Colors.white,
          controller: _tabController,
          indicatorColor: AppColors.textWhite,
          tabs: const [
            Tab(text: 'Prescriptions'),
            Tab(text: 'Lab Results'),
            Tab(text: 'Vaccinations')
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrescriptionsTab(),
          _buildLabResultsTab(),
          _buildVaccinationsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Upload document feature coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        _buildRecordCard('Prenatal Vitamins', 'Dr. Maria Santos',
            'Jan 15, 2025', Icons.medication, AppColors.primary),
        _buildRecordCard('Iron Supplement', 'Dr. Juan Reyes', 'Jan 10, 2025',
            Icons.medication, AppColors.error),
        _buildRecordCard('Folic Acid', 'Dr. Maria Santos', 'Jan 5, 2025',
            Icons.medication, AppColors.secondary),
      ],
    );
  }

  Widget _buildLabResultsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        _buildRecordCard('Blood Test', 'City Hospital', 'Jan 20, 2025',
            Icons.biotech, AppColors.info),
        _buildRecordCard('Ultrasound', 'Maternal Clinic', 'Jan 12, 2025',
            Icons.monitor_heart, AppColors.success),
      ],
    );
  }

  Widget _buildVaccinationsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        _buildRecordCard('Tetanus Vaccine', 'Health Center', 'Dec 15, 2024',
            Icons.vaccines, AppColors.warning),
        _buildRecordCard('Flu Shot', 'Health Center', 'Nov 20, 2024',
            Icons.vaccines, AppColors.info),
      ],
    );
  }

  Widget _buildRecordCard(
      String title, String provider, String date, IconData icon, Color color) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title details coming soon')),
        );
      },
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600)),
                Text(provider,
                    style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textSecondary)),
                Text(date,
                    style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textLight)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
        ],
      ),
    );
  }
}
