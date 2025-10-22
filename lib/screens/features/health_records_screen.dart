import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

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

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _fileUrlController = TextEditingController();

  bool _isLoading = false;
  String _selectedType = 'Prescription';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: 'Vaccinations')
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
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHealthRecordDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
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
}
