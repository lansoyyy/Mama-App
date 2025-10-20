import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/medication_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _medicationStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicationStats();
    _generateDailyLogsIfNeeded();
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

  Future<void> _generateDailyLogsIfNeeded() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        await _firestoreService.generateDailyMedicationLogs(userId);
      }
    } catch (e) {
      print('Error generating daily logs: $e');
    }
  }

  Future<void> _markMedicationTaken(String logId, String medicationId,
      String medicationName, String dosage, DateTime scheduledDate) async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        await _firestoreService.updateMedicationIntakeStatus(
          logId: logId,
          status: 'taken',
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$medicationName marked as taken!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Refresh stats
        _loadMedicationStats();
      }
    } catch (e) {
      print('Error marking medication as taken: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _markMedicationMissed(String logId, String medicationId,
      String medicationName, String dosage, DateTime scheduledDate) async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        await _firestoreService.updateMedicationIntakeStatus(
          logId: logId,
          status: 'missed',
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$medicationName marked as missed'),
            backgroundColor: AppColors.warning,
          ),
        );

        // Refresh stats
        _loadMedicationStats();
      }
    } catch (e) {
      print('Error marking medication as missed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(
              child: Text(
                'Please log in to view your medications',
                style: TextStyle(
                  fontSize: AppConstants.fontL,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _loadMedicationStats();
                await _generateDailyLogsIfNeeded();
              },
              child: CustomScrollView(
                slivers: [
                  // Stats Section
                  SliverToBoxAdapter(
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(AppConstants.paddingL),
                            child: Center(child: LoadingIndicator()),
                          )
                        : _medicationStats != null
                            ? _buildStatsSection()
                            : const SizedBox.shrink(),
                  ),

                  // Today's Medications Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Medications",
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

                  // Today's Medications List
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getTodayMedicationLogs(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.paddingL),
                            child: Center(child: LoadingIndicator()),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppConstants.paddingL),
                            child: Center(
                              child: Text(
                                'Error loading medications: ${snapshot.error}',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: AppConstants.fontM,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppConstants.paddingL),
                            child: EmptyState(
                              icon: Icons.medication_outlined,
                              title: 'No medications scheduled for today',
                              message: 'Add medications to get started',
                              actionText: 'Add Medication',
                              onAction: () {
                                _showAddMedicationDialog(context);
                              },
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = snapshot.data!.docs[index];
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
                                  ? () => _markMedicationTaken(
                                      logId,
                                      medicationId,
                                      medicationName,
                                      dosage,
                                      scheduledDate)
                                  : null,
                              onMarkMissed: status == 'pending'
                                  ? () => _markMedicationMissed(
                                      logId,
                                      medicationId,
                                      medicationName,
                                      dosage,
                                      scheduledDate)
                                  : null,
                            );
                          },
                          childCount: snapshot.data!.docs.length,
                        ),
                      );
                    },
                  ),

                  // All Medications Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: const Text(
                        'All Medications',
                        style: TextStyle(
                          fontSize: AppConstants.fontXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // All Medications List
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getUserMedications(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.paddingL),
                            child: Center(child: LoadingIndicator()),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppConstants.paddingL),
                            child: Center(
                              child: Text(
                                'Error loading medications: ${snapshot.error}',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: AppConstants.fontM,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppConstants.paddingL),
                            child: EmptyState(
                              icon: Icons.medication_outlined,
                              title: 'No medications added',
                              message:
                                  'Add your first medication to get started',
                              actionText: 'Add Medication',
                              onAction: () {
                                _showAddMedicationDialog(context);
                              },
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final medicationName =
                                data['name'] ?? 'Unknown Medication';
                            final dosage = data['dosage'] ?? 'Unknown Dosage';
                            final time = data['time'] ?? 'Unknown Time';
                            final medicationId = doc.id;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingM,
                                vertical: AppConstants.paddingS,
                              ),
                              elevation: AppConstants.elevationS,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusM),
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.all(AppConstants.paddingM),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusM),
                                  ),
                                  child: Icon(
                                    Icons.medication,
                                    color: AppColors.primary,
                                    size: AppConstants.iconL,
                                  ),
                                ),
                                title: Text(
                                  medicationName,
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontL,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                        height: AppConstants.paddingXS),
                                    Text(
                                      dosage,
                                      style: const TextStyle(
                                        fontSize: AppConstants.fontM,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                        height: AppConstants.paddingXS),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: AppConstants.iconS,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(
                                            width: AppConstants.paddingXS),
                                        Text(
                                          '${data['frequency']} • $time',
                                          style: const TextStyle(
                                            fontSize: AppConstants.fontS,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditMedicationDialog(
                                          context, medicationId, data);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmationDialog(context,
                                          medicationId, medicationName);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit,
                                              size: AppConstants.iconS),
                                          SizedBox(
                                              width: AppConstants.paddingS),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: AppConstants.iconS,
                                              color: AppColors.error),
                                          SizedBox(
                                              width: AppConstants.paddingS),
                                          Text('Delete',
                                              style: TextStyle(
                                                  color: AppColors.error)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: snapshot.data!.docs.length,
                        ),
                      );
                    },
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppConstants.paddingXXL),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMedicationDialog(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textWhite),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medication Overview',
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
                child: _buildStatCard(
                  'Active',
                  '${_medicationStats!['activeMedications'] ?? 0}',
                  Icons.medication,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _buildStatCard(
                  'Today',
                  '${_medicationStats!['totalScheduled'] ?? 0}',
                  Icons.today,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Adherence',
                  '${_medicationStats!['adherenceRate'] ?? 0}%',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '${_medicationStats!['streakDays'] ?? 0}',
                  Icons.local_fire_department,
                  AppColors.reward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: AppConstants.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
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

  void _showAddMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMedicationDialog(
        onMedicationAdded: () {
          Navigator.pop(context);
          _loadMedicationStats();
          _generateDailyLogsIfNeeded();
        },
      ),
    );
  }

  void _showEditMedicationDialog(BuildContext context, String medicationId,
      Map<String, dynamic> medicationData) {
    showDialog(
      context: context,
      builder: (context) => EditMedicationDialog(
        medicationId: medicationId,
        medicationData: medicationData,
        onMedicationUpdated: () {
          Navigator.pop(context);
          _loadMedicationStats();
          _generateDailyLogsIfNeeded();
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String medicationId, String medicationName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text(
            'Are you sure you want to delete $medicationName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteMedication(medicationId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$medicationName deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadMedicationStats();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting medication: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textWhite,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
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

class EditMedicationDialog extends StatefulWidget {
  final String medicationId;
  final Map<String, dynamic> medicationData;
  final VoidCallback onMedicationUpdated;

  const EditMedicationDialog({
    super.key,
    required this.medicationId,
    required this.medicationData,
    required this.onMedicationUpdated,
  });

  @override
  State<EditMedicationDialog> createState() => _EditMedicationDialogState();
}

class _EditMedicationDialogState extends State<EditMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;
  late String _selectedFrequency;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.medicationData['name'] ?? '');
    _dosageController =
        TextEditingController(text: widget.medicationData['dosage'] ?? '');
    _notesController =
        TextEditingController(text: widget.medicationData['notes'] ?? '');
    _selectedFrequency = widget.medicationData['frequency'] ?? 'Daily';

    // Parse time from string
    final timeString = widget.medicationData['time'] ?? '8:00 AM';
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minuteParts = parts[1].split(' ');
    final minute = int.parse(minuteParts[0]);
    final period = minuteParts[1];

    _selectedTime = TimeOfDay(
      hour: period == 'PM' && hour < 12
          ? hour + 12
          : (period == 'AM' && hour == 12 ? 0 : hour),
      minute: minute,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final timeString =
          '${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period.name.toUpperCase()}';

      await _firestoreService.updateMedication(
        medicationId: widget.medicationId,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        time: timeString,
        notes: _notesController.text.trim(),
      );

      widget.onMedicationUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text.trim()} updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating medication: $e'),
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
      title: const Text('Edit Medication'),
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
          onPressed: _isLoading ? null : _updateMedication,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textWhite,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
