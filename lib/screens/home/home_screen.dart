import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/medication_card.dart';
import '../profile/profile_screen.dart' show ProfileScreen;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardScreen(),
          MedicationsScreen(),
          FeaturesScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddMedicationDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            activeIcon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps),
            label: 'Features',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello, Maria! 👋',
                      style: TextStyle(
                        fontSize: AppConstants.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            ],
          ),

          // Stats Section
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Overview',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppConstants.paddingM,
                    crossAxisSpacing: AppConstants.paddingM,
                    childAspectRatio: 1,
                    children: const [
                      StatCard(
                        title: 'Adherence Rate',
                        value: '92%',
                        icon: Icons.trending_up,
                        color: AppColors.success,
                        subtitle: 'Excellent!',
                      ),
                      StatCard(
                        title: 'Today\'s Doses',
                        value: '3/4',
                        icon: Icons.medication,
                        color: AppColors.primary,
                        subtitle: '1 remaining',
                      ),
                      StatCard(
                        title: 'Streak Days',
                        value: '12',
                        icon: Icons.local_fire_department,
                        color: AppColors.reward,
                        subtitle: 'Keep it up!',
                      ),
                      StatCard(
                        title: 'Reward Points',
                        value: '850',
                        icon: Icons.stars,
                        color: AppColors.secondary,
                        subtitle: '150 to next reward',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Upcoming Medications
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Medications',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/smart-medguide');
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),

          // Medication List
          SliverList(
            delegate: SliverChildListDelegate([
              MedicationCard(
                medicationName: 'Prenatal Vitamins',
                dosage: '1 tablet',
                time: '2:00 PM',
                status: 'pending',
                onMarkTaken: () {},
                onMarkMissed: () {},
              ),
              MedicationCard(
                medicationName: 'Iron Supplement',
                dosage: '500mg',
                time: '8:00 AM',
                status: 'taken',
              ),
              MedicationCard(
                medicationName: 'Folic Acid',
                dosage: '400mcg',
                time: '9:00 PM',
                status: 'pending',
                onMarkTaken: () {},
                onMarkMissed: () {},
              ),
            ]),
          ),

          // Quick Actions
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: AppConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.psychology,
                          label: 'AI Assistant',
                          color: AppColors.aiAssistant,
                          onTap: () {
                            Navigator.pushNamed(context, '/ai-assistant');
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.video_call,
                          label: 'Consultation',
                          color: AppColors.consultation,
                          onTap: () {
                            Navigator.pushNamed(context, '/consultation');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.emergency,
                          label: 'Emergency',
                          color: AppColors.emergency,
                          onTap: () {
                            Navigator.pushNamed(context, '/emergency');
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.local_pharmacy,
                          label: 'Find Pharmacy',
                          color: AppColors.info,
                          onTap: () {
                            Navigator.pushNamed(context, '/pharmacy-locator');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Column(
            children: [
              Icon(icon, size: AppConstants.iconL, color: color),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontS,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Medication Dialog
void _showAddMedicationDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  String selectedFrequency = 'Daily';
  TimeOfDay selectedTime = TimeOfDay.now();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                hintText: 'e.g., Prenatal Vitamins',
                prefixIcon: Icon(Icons.medication),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                hintText: 'e.g., 1 tablet, 500mg',
                prefixIcon: Icon(Icons.medical_information),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            DropdownButtonFormField<String>(
              value: selectedFrequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: ['Daily', 'Twice Daily', 'Three Times Daily', 'Weekly']
                  .map((freq) => DropdownMenuItem(
                        value: freq,
                        child: Text(freq),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedFrequency = value!;
              },
            ),
            const SizedBox(height: AppConstants.paddingM),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(selectedTime.format(context)),
              onTap: () async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  selectedTime = time;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty && dosageController.text.isNotEmpty) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${nameController.text} added successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all fields'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

// Placeholder screens for bottom navigation
class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildMedicationStatCard(
                  'Active',
                  '8',
                  Icons.medication,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _buildMedicationStatCard(
                  'Today',
                  '4',
                  Icons.today,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          // Medications List
          const Text(
            'All Medications',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          MedicationCard(
            medicationName: 'Prenatal Vitamins',
            dosage: '1 tablet',
            time: '8:00 AM',
            status: 'pending',
            onMarkTaken: () {},
            onMarkMissed: () {},
          ),
          MedicationCard(
            medicationName: 'Iron Supplement',
            dosage: '500mg',
            time: '8:00 AM',
            status: 'taken',
          ),
          MedicationCard(
            medicationName: 'Folic Acid',
            dosage: '400mcg',
            time: '9:00 PM',
            status: 'pending',
            onMarkTaken: () {},
            onMarkMissed: () {},
          ),
          MedicationCard(
            medicationName: 'Calcium',
            dosage: '600mg',
            time: '2:00 PM',
            status: 'pending',
            onMarkTaken: () {},
            onMarkMissed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMedicationDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  static Widget _buildMedicationStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: AppConstants.elevationS,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppConstants.iconL),
            const SizedBox(height: AppConstants.paddingS),
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
                fontSize: AppConstants.fontM,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Features'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _buildFeatureItem(
            context,
            'MedInfo Hub',
            'Learn about your medications',
            Icons.medical_services,
            AppColors.primary,
            '/medinfo-hub',
          ),
          _buildFeatureItem(
            context,
            'Smart MedGuide',
            'Track your medication adherence',
            Icons.medication,
            AppColors.secondary,
            '/smart-medguide',
          ),
          _buildFeatureItem(
            context,
            'AI Health Assistant',
            'Get personalized health guidance',
            Icons.psychology,
            AppColors.aiAssistant,
            '/ai-assistant',
          ),
          _buildFeatureItem(
            context,
            'Virtual Consultation',
            'Connect with health professionals',
            Icons.video_call,
            AppColors.consultation,
            '/consultation',
          ),
          _buildFeatureItem(
            context,
            'Rewards & Achievements',
            'Track your progress and earn rewards',
            Icons.stars,
            AppColors.reward,
            '/rewards',
          ),
          _buildFeatureItem(
            context,
            'Symptom Tracker',
            'Log and monitor your symptoms',
            Icons.health_and_safety,
            AppColors.info,
            '/symptom-tracker',
          ),
          _buildFeatureItem(
            context,
            'Health Journal',
            'Keep a daily health diary',
            Icons.book,
            AppColors.success,
            '/health-journal',
          ),
          _buildFeatureItem(
            context,
            'Find Pharmacy',
            'Locate nearby pharmacies',
            Icons.local_pharmacy,
            AppColors.info,
            '/pharmacy-locator',
          ),
          _buildFeatureItem(
            context,
            'Emergency Help',
            'Quick access to emergency services',
            Icons.emergency,
            AppColors.emergency,
            '/emergency',
          ),
          _buildFeatureItem(
            context,
            'Family Management',
            'Manage medications for family members',
            Icons.family_restroom,
            AppColors.secondary,
            '/multi-user',
          ),
          _buildFeatureItem(
            context,
            'Health Records',
            'Store and manage health documents',
            Icons.folder_shared,
            AppColors.warning,
            '/health-records',
          ),
          _buildFeatureItem(
            context,
            'Milestone Tracker',
            'Track maternal and baby milestones',
            Icons.child_care,
            AppColors.success,
            '/milestone-tracker',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      elevation: AppConstants.elevationS,
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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.fontL,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}

// ProfileScreen is imported from '../profile/profile_screen.dart'
