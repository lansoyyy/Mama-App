import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/medication_card.dart';
import '../../widgets/notification_badge.dart';
import '../profile/profile_screen.dart' show ProfileScreen;
import '../medications/medications_screen.dart' show MedicationsScreen;
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Key to access the IndexedStack state
  final GlobalKey<_HomeScreenState> _homeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _homeKey,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(key: ValueKey(_selectedIndex)),
          MedicationsScreen(key: ValueKey(_selectedIndex)),
          FeaturesScreen(),
          ProfileScreen(),
        ],
      ),
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
  Map<String, dynamic>? _medicationStats;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        // Load user data
        final userData = await _firestoreService.getUser(userId);
        if (userData != null) {
          setState(() {
            _userName = userData['fullName'] ?? 'User';
            _profilePictureUrl = userData['profilePicture'] ?? '';
          });
        } else {
          // Fallback to Firebase Auth display name if Firestore doesn't have the name
          final user = _authService.currentUser;
          setState(() {
            _userName = user?.displayName ?? 'User';
            _profilePictureUrl = '';
          });
        }

        // Load medication stats
        await _loadMedicationStats();

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMedicationStats() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final stats = await _firestoreService.getMedicationStats(userId);
        setState(() {
          _medicationStats = stats;
        });

        // Generate daily logs if needed
        await _firestoreService.generateDailyMedicationLogs(userId);
      }
    } catch (e) {
      print('Error loading medication stats: $e');
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
              NotificationIconButton(
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
                    children: [
                      StatCard(
                        title: 'Adherence Rate',
                        value: '${_medicationStats?['adherenceRate'] ?? 0}%',
                        icon: Icons.trending_up,
                        color: AppColors.success,
                        subtitle: (_medicationStats?['adherenceRate'] ?? 0) >=
                                90
                            ? 'Excellent!'
                            : (_medicationStats?['adherenceRate'] ?? 0) >= 75
                                ? 'Good!'
                                : 'Keep trying!',
                      ),
                      StatCard(
                        title: 'Today\'s Doses',
                        value:
                            '${_medicationStats?['totalTaken'] ?? 0}/${_medicationStats?['totalScheduled'] ?? 0}',
                        icon: Icons.medication,
                        color: AppColors.primary,
                        subtitle:
                            '${_medicationStats?['totalPending'] ?? 0} remaining',
                      ),
                      StatCard(
                        title: 'Streak Days',
                        value: '${_medicationStats?['streakDays'] ?? 0}',
                        icon: Icons.local_fire_department,
                        color: AppColors.reward,
                        subtitle: (_medicationStats?['streakDays'] ?? 0) > 0
                            ? 'Keep it up!'
                            : 'Start today!',
                      ),
                      StatCard(
                        title: 'Reward Points',
                        value: '${_medicationStats?['rewardPoints'] ?? 0}',
                        icon: Icons.stars,
                        color: AppColors.secondary,
                        subtitle:
                            '${1000 - ((_medicationStats?['rewardPoints'] ?? 0) % 1000)} to next reward',
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
          StreamBuilder<QuerySnapshot>(
            stream: _authService.currentUserId != null
                ? _firestoreService
                    .getTodayMedicationLogs(_authService.currentUserId!)
                : Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingL),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingL),
                    child: Center(
                      child: Text(
                        'Error loading medications',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                );
              }

              final medications =
                  snapshot.data!.docs.take(3).toList(); // Show only first 3

              if (medications.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingL),
                    child: Center(
                      child: Text(
                        'No medications scheduled for today',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = medications[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final medicationName =
                        data['medicationName'] ?? 'Unknown Medication';
                    final dosage = data['dosage'] ?? 'Unknown Dosage';
                    final scheduledDate =
                        (data['scheduledDate'] as Timestamp).toDate();
                    final status = data['status'] ?? 'pending';
                    final logId = doc.id;
                    final medicationId = data['medicationId'] ?? '';

                    String _formatTime(DateTime dateTime) {
                      final hour = dateTime.hour;
                      final minute = dateTime.minute;
                      final period = hour >= 12 ? 'PM' : 'AM';
                      final displayHour =
                          hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
                    }

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
                                    content: Text(
                                        '$medicationName marked as taken!'),
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
                                    content: Text(
                                        '$medicationName marked as missed'),
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
                  },
                  childCount: medications.length,
                ),
              );
            },
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
  showDialog(
    context: context,
    builder: (context) => AddMedicationDialog(
      onMedicationAdded: () {
        Navigator.pop(context);
        // Switch to the Medications tab and then back to refresh
        final homeScreenState =
            context.findAncestorStateOfType<_HomeScreenState>();
        if (homeScreenState != null) {
          homeScreenState.setState(() {
            homeScreenState._selectedIndex = 1; // Switch to Medications tab
          });

          // Switch back to Dashboard after a brief delay
          Future.delayed(const Duration(milliseconds: 100), () {
            homeScreenState.setState(() {
              homeScreenState._selectedIndex = 0; // Back to Dashboard
            });
          });
        }
      },
    ),
  );
}

class AddMedicationDialog extends StatefulWidget {
  final VoidCallback onMedicationAdded;

  const AddMedicationDialog({
    super.key,
    required this.onMedicationAdded,
  });

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedFrequency = 'Daily';
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final timeString =
            '${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period.name.toUpperCase()}';

        await _firestoreService.addMedication(
          userId: userId,
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          frequency: _selectedFrequency,
          time: timeString,
          notes: _notesController.text.trim(),
        );

        widget.onMedicationAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding medication: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medication'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g., Prenatal Vitamins',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 1 tablet, 500mg',
                  prefixIcon: Icon(Icons.medical_information),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.paddingM),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
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
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
              const SizedBox(height: AppConstants.paddingM),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addMedication,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textWhite,
                  ),
                )
              : const Text('Add'),
        ),
      ],
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
