import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/medication_card.dart';
import '../profile/profile_screen.dart' show ProfileScreen;
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = 'User';
  String? _profilePictureUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final userData = await _firestoreService.getUser(userId);
        if (userData != null) {
          setState(() {
            _userName = userData['fullName'] ?? 'User';
            _profilePictureUrl = userData['profilePicture'] ?? '';
            _isLoading = false;
          });
        } else {
          // Fallback to Firebase Auth display name if Firestore doesn't have the name
          final user = _authService.currentUser;
          setState(() {
            _userName = user?.displayName ?? 'User';
            _profilePictureUrl = '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 140,
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.textWhite,
                          backgroundImage: (_profilePictureUrl != null &&
                                  _profilePictureUrl!.isNotEmpty)
                              ? CachedNetworkImageProvider(_profilePictureUrl!)
                                  as ImageProvider
                              : null,
                          child: (_profilePictureUrl == null ||
                                  _profilePictureUrl!.isEmpty)
                              ? Icon(Icons.person,
                                  size: 25, color: AppColors.primary)
                              : null,
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: _isLoading
                              ? const Text(
                                  'Hello! 👋',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontXXL,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                )
                              : Text(
                                  'Hello, ${_userName.split(' ')[0]}! 👋',
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontXXL,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                        ),
                      ],
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
            if (nameController.text.isNotEmpty &&
                dosageController.text.isNotEmpty) {
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
    final features = [
      {
        'title': 'MedInfo Hub',
        'description': 'Learn about your medications',
        'icon': Icons.medical_services,
        'color': AppColors.primary,
        'route': '/medinfo-hub',
      },
      {
        'title': 'Smart MedGuide',
        'description': 'Track your medication adherence',
        'icon': Icons.medication,
        'color': AppColors.secondary,
        'route': '/smart-medguide',
      },
      {
        'title': 'AI Health Assistant',
        'description': 'Get personalized health guidance',
        'icon': Icons.psychology,
        'color': AppColors.aiAssistant,
        'route': '/ai-assistant',
      },
      {
        'title': 'Virtual Consultation',
        'description': 'Connect with health professionals',
        'icon': Icons.video_call,
        'color': AppColors.consultation,
        'route': '/consultation',
      },
      {
        'title': 'Rewards & Achievements',
        'description': 'Track your progress and earn rewards',
        'icon': Icons.stars,
        'color': AppColors.reward,
        'route': '/rewards',
      },
      {
        'title': 'Symptom Tracker',
        'description': 'Log and monitor your symptoms',
        'icon': Icons.health_and_safety,
        'color': AppColors.info,
        'route': '/symptom-tracker',
      },
      {
        'title': 'Health Journal',
        'description': 'Keep a daily health diary',
        'icon': Icons.book,
        'color': AppColors.success,
        'route': '/health-journal',
      },
      {
        'title': 'Find Pharmacy',
        'description': 'Locate nearby pharmacies',
        'icon': Icons.local_pharmacy,
        'color': AppColors.info,
        'route': '/pharmacy-locator',
      },
      {
        'title': 'Emergency Help',
        'description': 'Quick access to emergency services',
        'icon': Icons.emergency,
        'color': AppColors.emergency,
        'route': '/emergency',
      },
      {
        'title': 'Family Management',
        'description': 'Manage medications for family members',
        'icon': Icons.family_restroom,
        'color': AppColors.secondary,
        'route': '/multi-user',
      },
      {
        'title': 'Health Records',
        'description': 'Store and manage health documents',
        'icon': Icons.folder_shared,
        'color': AppColors.warning,
        'route': '/health-records',
      },
      {
        'title': 'Milestone Tracker',
        'description': 'Track maternal and baby milestones',
        'icon': Icons.child_care,
        'color': AppColors.success,
        'route': '/milestone-tracker',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Features'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureItem(
              context,
              feature['title'] as String,
              feature['description'] as String,
              feature['icon'] as IconData,
              feature['color'] as Color,
              feature['route'] as String,
            );
          },
        ),
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
      elevation: AppConstants.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(icon, color: color, size: AppConstants.iconL),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.paddingXS),
              Text(
                description,
                style: const TextStyle(
                  fontSize: AppConstants.fontS,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: AppConstants.iconS,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ProfileScreen is imported from '../profile/profile_screen.dart'
