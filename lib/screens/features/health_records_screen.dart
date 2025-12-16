import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/blood_pressure_model.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Form controllers for health records
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _fileUrlController = TextEditingController();

  // Form controllers for blood pressure
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bpNotesController = TextEditingController();

  bool _isLoading = false;
  String _selectedType = 'Prescription';
  DateTime _selectedDate = DateTime.now();

  // Blood pressure specific variables
  String _selectedPosition = 'Sitting';
  String _selectedArm = 'Left';
  String _deviceController = '';
  bool _hasSymptoms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedType = 'Prescription';
            break;
          case 1:
            _selectedType = 'Lab Result';
            break;
          case 2:
            _selectedType = 'Vaccination';
            break;
          case 3:
            // Blood Pressure tab - no type change needed
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _providerController.dispose();
    _notesController.dispose();
    _fileUrlController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _bpNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _authService.currentUserId;

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
            Tab(text: 'Vaccinations'),
            Tab(text: 'Blood Pressure')
          ],
        ),
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please log in to view health records'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHealthRecordsTab('Prescription', currentUserId),
                _buildHealthRecordsTab('Lab Result', currentUserId),
                _buildHealthRecordsTab('Vaccination', currentUserId),
                _buildBloodPressureTab(currentUserId),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tabController.index == 3
            ? _showAddBloodPressureDialog
            : _showAddHealthRecordDialog,
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 3 ? 'Add Reading' : 'Add Record'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildHealthRecordsTab(String recordType, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getUserHealthRecords(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(recordType),
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: AppConstants.paddingM),
                Text(
                  'No ${_getPluralType(recordType)} yet',
                  style: const TextStyle(
                    fontSize: AppConstants.fontL,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(
                  'Tap the + button to add your first ${recordType.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Filter records by type
        List<DocumentSnapshot> filteredRecords =
            snapshot.data!.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['type'] == recordType;
        }).toList();

        if (filteredRecords.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(recordType),
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: AppConstants.paddingM),
                Text(
                  'No ${_getPluralType(recordType)} yet',
                  style: const TextStyle(
                    fontSize: AppConstants.fontL,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(
                  'Tap the + button to add your first ${recordType.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: filteredRecords.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return _buildRecordCard(
              doc.id,
              data['title'] ?? '',
              data['provider'] ?? '',
              data['date'] ?? '',
              data['type'] ?? '',
              data['notes'] ?? '',
              data['fileUrl'] ?? '',
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecordCard(String recordId, String title, String provider,
      String date, String type, String notes, String fileUrl) {
    IconData icon = _getIconForType(type);
    Color color = _getColorForType(type);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () {
        _showRecordDetailsDialog(
            recordId, title, provider, date, type, notes, fileUrl);
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
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: AppConstants.fontL,
                              fontWeight: FontWeight.w600)),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmationDialog(recordId, title);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(provider,
                    style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textSecondary)),
                Text(date,
                    style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textLight)),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingXS),
                  Text(
                    notes.length > 50 ? '${notes.substring(0, 50)}...' : notes,
                    style: const TextStyle(
                        fontSize: AppConstants.fontXS,
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic),
                  ),
                ],
                if (fileUrl.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingXS),
                  Row(
                    children: [
                      Icon(Icons.attach_file,
                          size: 12, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      const Text(
                        'Attachment',
                        style: TextStyle(
                            fontSize: AppConstants.fontXS,
                            color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
        ],
      ),
    );
  }

  void _showAddHealthRecordDialog() {
    _clearControllers();
    _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add $_selectedType'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter record title',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _providerController,
                  decoration: InputDecoration(
                    labelText: 'Provider',
                    hintText: 'Doctor, hospital, or clinic name',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Additional information',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _fileUrlController,
                  decoration: InputDecoration(
                    labelText: 'File URL (Optional)',
                    hintText: 'Link to document or image',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _addHealthRecord(),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordDetailsDialog(String recordId, String title, String provider,
      String date, String type, String notes, String fileUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Type', type),
              _buildDetailRow('Provider', provider),
              _buildDetailRow('Date', date),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(notes),
              ],
              if (fileUrl.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'Attachment:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    child: Image.network(
                      fileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  color: AppColors.textLight,
                                  size: AppConstants.iconXL),
                              const SizedBox(height: AppConstants.paddingS),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppConstants.fontM,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening file...')),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.link, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileUrl,
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String recordId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Record'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                    _deleteHealthRecord(recordId);
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _providerController.clear();
    _notesController.clear();
    _fileUrlController.clear();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Prescription':
        return Icons.medication;
      case 'Lab Result':
        return Icons.biotech;
      case 'Vaccination':
        return Icons.vaccines;
      case 'Blood Pressure':
        return Icons.favorite;
      default:
        return Icons.description;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Prescription':
        return AppColors.primary;
      case 'Lab Result':
        return AppColors.info;
      case 'Vaccination':
        return AppColors.warning;
      case 'Blood Pressure':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPluralType(String type) {
    switch (type) {
      case 'Prescription':
        return 'Prescriptions';
      case 'Lab Result':
        return 'Lab Results';
      case 'Vaccination':
        return 'Vaccinations';
      case 'Blood Pressure':
        return 'Blood Pressure Readings';
      default:
        return 'Records';
    }
  }

  Future<void> _addHealthRecord() async {
    if (_titleController.text.trim().isEmpty ||
        _providerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      await _firestoreService.addHealthRecord(
        userId: currentUserId,
        type: _selectedType,
        title: _titleController.text.trim(),
        provider: _providerController.text.trim(),
        date: _formatDate(_selectedDate),
        notes: _notesController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_selectedType added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteHealthRecord(String recordId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.deleteHealthRecord(recordId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health record deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Blood Pressure Methods
  Widget _buildBloodPressureTab(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getUserBloodPressureReadings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'No blood pressure readings yet',
                  style: TextStyle(
                    fontSize: AppConstants.fontL,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                const Text(
                  'Tap the + button to add your first reading',
                  style: TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final notes = snapshot.data!.docs
            .map((doc) => BloodPressureModel.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        return Column(
          children: [
            // Summary card
            Container(
              margin: const EdgeInsets.all(AppConstants.paddingM),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Readings',
                        style: TextStyle(
                          fontSize: AppConstants.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Average',
                              '${_calculateAverage(snapshot.data!.docs, 'systolic')}/${_calculateAverage(snapshot.data!.docs, 'diastolic')}',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: _buildSummaryCard(
                              'Latest',
                              _getLatestReading(snapshot.data!.docs),
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM,
              ),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trend',
                        style: TextStyle(
                          fontSize: AppConstants.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: _BloodPressureTrendChart(readings: notes),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Row(
                        children: [
                          _buildLegendDot(color: Colors.red, label: 'Systolic'),
                          const SizedBox(width: AppConstants.paddingM),
                          _buildLegendDot(
                              color: Colors.blue, label: 'Diastolic'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            // Readings list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM),
                children: List.generate(notes.length, (index) {
                  final bp = notes[index];
                  final Duration? interval = index + 1 < notes.length
                      ? bp.timestamp.difference(notes[index + 1].timestamp)
                      : null;
                  return _buildBloodPressureCard(bp, interval: interval);
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontS,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodPressureCard(BloodPressureModel bp, {Duration? interval}) {
    Color categoryColor = _getCategoryColor(bp.getBloodPressureCategory());

    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () => _showBloodPressureDetailsDialog(bp),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(Icons.favorite, color: categoryColor),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${bp.systolic}/${bp.diastolic} mmHg',
                        style: const TextStyle(
                          fontSize: AppConstants.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteBloodPressureConfirmationDialog(bp);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Heart Rate: ${bp.heartRate} bpm',
                      style: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingXS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        bp.getBloodPressureCategory(),
                        style: TextStyle(
                          fontSize: AppConstants.fontXS,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  bp.getFormattedDateTime(),
                  style: const TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textLight,
                  ),
                ),
                if (interval != null) ...[
                  const SizedBox(height: AppConstants.paddingXS),
                  Text(
                    'Interval: ${_formatDuration(interval)}',
                    style: const TextStyle(
                      fontSize: AppConstants.fontXS,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
                if (bp.notes.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingXS),
                  Text(
                    bp.notes.length > 50
                        ? '${bp.notes.substring(0, 50)}...'
                        : bp.notes,
                    style: const TextStyle(
                      fontSize: AppConstants.fontXS,
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: AppConstants.iconS),
        ],
      ),
    );
  }

  void _showAddBloodPressureDialog() {
    _clearBloodPressureControllers();
    DateTime selectedDateTime = DateTime.now();
    bool hasSymptoms = _hasSymptoms;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Blood Pressure Reading'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _systolicController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Systolic (Upper)',
                          hintText: '120',
                          border: const OutlineInputBorder(),
                          suffixText: 'mmHg',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: TextField(
                        controller: _diastolicController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Diastolic (Lower)',
                          hintText: '80',
                          border: const OutlineInputBorder(),
                          suffixText: 'mmHg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _heartRateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Heart Rate',
                    hintText: '72',
                    border: const OutlineInputBorder(),
                    suffixText: 'bpm',
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                ListTile(
                  title: const Text('Date & Time'),
                  subtitle: Text(_formatDateTime(selectedDateTime)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: AppConstants.paddingM),
                DropdownButtonFormField<String>(
                  value: _selectedPosition,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sitting', child: Text('Sitting')),
                    DropdownMenuItem(
                        value: 'Standing', child: Text('Standing')),
                    DropdownMenuItem(
                        value: 'Lying down', child: Text('Lying down')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value!;
                    });
                  },
                ),
                const SizedBox(height: AppConstants.paddingM),
                DropdownButtonFormField<String>(
                  value: _selectedArm,
                  decoration: const InputDecoration(
                    labelText: 'Arm',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Left', child: Text('Left')),
                    DropdownMenuItem(value: 'Right', child: Text('Right')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedArm = value!;
                    });
                  },
                ),
                const SizedBox(height: AppConstants.paddingM),
                TextField(
                  controller: _bpNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Additional information',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.paddingS),
                SwitchListTile(
                  value: hasSymptoms,
                  title: const Text('Symptoms present'),
                  subtitle: const Text(
                      'Headache, chest pain, shortness of breath, etc.'),
                  onChanged: (value) {
                    setState(() {
                      hasSymptoms = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _addBloodPressureReading(
                        selectedDateTime,
                        hasSymptoms: hasSymptoms,
                      ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Reading'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBloodPressureDetailsDialog(BloodPressureModel bp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blood Pressure Reading'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Blood Pressure', '${bp.systolic}/${bp.diastolic} mmHg'),
              _buildDetailRow('Heart Rate', '${bp.heartRate} bpm'),
              _buildDetailRow('Category', bp.getBloodPressureCategory()),
              _buildDetailRow('Date & Time', bp.getFormattedDateTime()),
              _buildDetailRow('Position', bp.position),
              _buildDetailRow('Arm', bp.arm),
              _buildDetailRow('Symptoms', bp.hasSymptoms ? 'Yes' : 'No'),
              if (bp.device.isNotEmpty) _buildDetailRow('Device', bp.device),
              if (bp.notes.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(bp.notes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteBloodPressureConfirmationDialog(BloodPressureModel bp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Blood Pressure Reading'),
        content: Text(
            'Are you sure you want to delete the reading from ${bp.getFormattedDate()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                    _deleteBloodPressureReading(bp.id);
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearBloodPressureControllers() {
    _systolicController.clear();
    _diastolicController.clear();
    _heartRateController.clear();
    _bpNotesController.clear();
    _selectedPosition = 'Sitting';
    _selectedArm = 'Left';
    _deviceController = '';
    _hasSymptoms = false;
  }

  String _formatDuration(Duration duration) {
    final totalMinutes = duration.inMinutes.abs();
    final days = totalMinutes ~/ (60 * 24);
    final hours = (totalMinutes % (60 * 24)) ~/ 60;
    final minutes = totalMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    }
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateAverage(List<DocumentSnapshot> docs, String field) {
    if (docs.isEmpty) return '0';

    int total = 0;
    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      total += (data[field] as num? ?? 0).toInt();
    }

    return (total / docs.length).round().toString();
  }

  String _getLatestReading(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) return '0/0';

    Map<String, dynamic> data = docs.first.data() as Map<String, dynamic>;
    int systolic = data['systolic'] ?? 0;
    int diastolic = data['diastolic'] ?? 0;

    return '$systolic/$diastolic';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Normal':
        return const Color(0xFF8BC34A);
      case 'Elevated':
        return const Color(0xFFFFEB3B);
      case 'Stage 1 Hypertension':
        return const Color(0xFFFF9800);
      case 'Stage 2 Hypertension':
        return const Color(0xFFBF360C);
      case 'Severe Hypertension':
        return const Color(0xFF8B0000);
      case 'Hypertensive Emergency':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }

  Future<void> _addBloodPressureReading(DateTime timestamp,
      {required bool hasSymptoms}) async {
    if (_systolicController.text.trim().isEmpty ||
        _diastolicController.text.trim().isEmpty ||
        _heartRateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    int systolic = int.tryParse(_systolicController.text.trim()) ?? 0;
    int diastolic = int.tryParse(_diastolicController.text.trim()) ?? 0;
    int heartRate = int.tryParse(_heartRateController.text.trim()) ?? 0;

    if (systolic <= 0 || diastolic <= 0 || heartRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive numbers')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      await _firestoreService.addBloodPressureReading(
        userId: currentUserId,
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: timestamp,
        notes: _bpNotesController.text.trim(),
        position: _selectedPosition,
        arm: _selectedArm,
        device: _deviceController,
        additionalData: {
          'hasSymptoms': hasSymptoms,
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Blood pressure reading added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteBloodPressureReading(String readingId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.deleteBloodPressureReading(readingId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Blood pressure reading deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _BloodPressureTrendChart extends StatelessWidget {
  final List<BloodPressureModel> readings;

  const _BloodPressureTrendChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = readings.length <= 14
        ? readings.reversed.toList()
        : readings.take(14).toList().reversed.toList();

    return CustomPaint(
      painter: _BloodPressureTrendPainter(readings: visible),
    );
  }
}

class _BloodPressureTrendPainter extends CustomPainter {
  final List<BloodPressureModel> readings;

  _BloodPressureTrendPainter({required this.readings});

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final padding = 8.0;
    final chartRect = Rect.fromLTWH(
      padding,
      padding,
      max(0.0, size.width - padding * 2),
      max(0.0, size.height - padding * 2),
    );

    if (chartRect.width <= 0 || chartRect.height <= 0) return;

    int minVal = readings.first.diastolic;
    int maxVal = readings.first.systolic;
    for (final r in readings) {
      minVal = min(minVal, min(r.systolic, r.diastolic));
      maxVal = max(maxVal, max(r.systolic, r.diastolic));
    }

    final range = max(1, maxVal - minVal);

    final systolicPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final diastolicPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    final n = readings.length;
    final dx = n <= 1 ? 0.0 : chartRect.width / (n - 1);

    final systolicPath = Path();
    final diastolicPath = Path();

    Offset pointFor(int index, int value) {
      final x = chartRect.left + dx * index;
      final t = (value - minVal) / range;
      final y = chartRect.bottom - (t * chartRect.height);
      return Offset(x, y);
    }

    for (int i = 0; i < n; i++) {
      final r = readings[i];
      final s = pointFor(i, r.systolic);
      final d = pointFor(i, r.diastolic);
      if (i == 0) {
        systolicPath.moveTo(s.dx, s.dy);
        diastolicPath.moveTo(d.dx, d.dy);
      } else {
        systolicPath.lineTo(s.dx, s.dy);
        diastolicPath.lineTo(d.dx, d.dy);
      }

      dotPaint.color = Colors.red;
      canvas.drawCircle(s, 2.5, dotPaint);
      dotPaint.color = Colors.blue;
      canvas.drawCircle(d, 2.5, dotPaint);
    }

    canvas.drawPath(systolicPath, systolicPaint);
    canvas.drawPath(diastolicPath, diastolicPaint);
  }

  @override
  bool shouldRepaint(covariant _BloodPressureTrendPainter oldDelegate) {
    return oldDelegate.readings != readings;
  }
}
