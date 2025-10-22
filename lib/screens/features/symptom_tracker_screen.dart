import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../models/symptom_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  String _selectedSeverity = '';
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;
  List<SymptomModel> _symptomLogs = [];

  @override
  void initState() {
    super.initState();
    _loadSymptomLogs();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSymptomLogs() async {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      _firestoreService.getUserSymptomLogs(userId).listen((snapshot) {
        setState(() {
          _symptomLogs = snapshot.docs
              .map((doc) => SymptomModel.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        });
      });
    }
  }

  Future<void> _saveSymptomLog() async {
    if (_selectedSymptoms.isEmpty || _selectedSeverity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select symptoms and severity level'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        await _firestoreService.addSymptomLog(
          userId: userId,
          symptoms: _selectedSymptoms,
          severity: _selectedSeverity,
          notes: _notesController.text,
          timestamp: _selectedDateTime,
        );

        // Clear form
        setState(() {
          _selectedSymptoms.clear();
          _selectedSeverity = '';
          _notesController.clear();
          _selectedDateTime = DateTime.now();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Symptoms logged successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging symptoms: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today, ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Mild':
        return AppColors.success;
      case 'Moderate':
        return AppColors.warning;
      case 'Severe':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Symptom Tracker'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Info Card
          CustomCard(
            gradient: LinearGradient(
              colors: [
                AppColors.info.withOpacity(0.1),
                AppColors.info.withOpacity(0.05),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: AppConstants.iconXL,
                  color: AppColors.info,
                ),
                SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Text(
                    'Track your symptoms and side effects to share with your health provider',
                    style: TextStyle(
                      fontSize: AppConstants.fontM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),

          // Common Symptoms
          const Text(
            'Select Symptoms',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          Wrap(
            spacing: AppConstants.paddingS,
            runSpacing: AppConstants.paddingS,
            children: CommonSymptoms.symptoms
                .map((symptom) => _buildSymptomChip(symptom))
                .toList(),
          ),
          const SizedBox(height: AppConstants.paddingL),

          // Date/Time Selection
          const Text(
            'Date & Time',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          CustomCard(
            child: ListTile(
              leading: const Icon(Icons.access_time, color: AppColors.primary),
              title: Text(_formatDateTime(_selectedDateTime)),
              trailing:
                  const Icon(Icons.calendar_today, color: AppColors.primary),
              onTap: _selectDateTime,
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),

          // Severity
          const Text(
            'Severity Level',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          Row(
            children: [
              Expanded(
                child: _buildSeverityCard(
                  'Mild',
                  Icons.sentiment_satisfied,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: _buildSeverityCard(
                  'Moderate',
                  Icons.sentiment_neutral,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: _buildSeverityCard(
                  'Severe',
                  Icons.sentiment_very_dissatisfied,
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),

          // Notes
          const Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe your symptoms in detail...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppConstants.paddingXL),

          // Submit Button
          _isLoading
              ? const LoadingIndicator()
              : CustomButton(
                  text: 'Log Symptoms',
                  icon: Icons.save,
                  onPressed: _saveSymptomLog,
                  fullWidth: true,
                ),
          const SizedBox(height: AppConstants.paddingL),

          // Recent Logs
          const Text(
            'Recent Logs',
            style: TextStyle(
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          _symptomLogs.isEmpty
              ? const CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingL),
                    child: Text(
                      'No symptom logs yet. Start tracking your symptoms above.',
                      style: TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: _symptomLogs
                      .take(10) // Show only the 10 most recent logs
                      .map((log) => _buildSymptomLogCard(
                            _formatDateTime(log.timestamp),
                            log.symptoms,
                            SymptomSeverity.getDisplayName(log.severity),
                            _getSeverityColor(log.severity),
                            log.notes,
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip(String symptom) {
    final isSelected = _selectedSymptoms.contains(symptom);
    return FilterChip(
      label: Text(symptom),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedSymptoms.add(symptom);
          } else {
            _selectedSymptoms.remove(symptom);
          }
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildSeverityCard(String label, IconData icon, Color color) {
    final isSelected = _selectedSeverity == label;
    return Card(
      elevation: isSelected ? AppConstants.elevationM : AppConstants.elevationS,
      color: isSelected ? color.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSeverity = label;
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            children: [
              Icon(
                icon,
                size: AppConstants.iconL,
                color: isSelected ? color : color.withOpacity(0.7),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontS,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomLogCard(
    String time,
    List<String> symptoms,
    String severity,
    Color severityColor,
    String notes,
  ) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: AppConstants.fontM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                  vertical: AppConstants.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    fontSize: AppConstants.fontS,
                    fontWeight: FontWeight.w600,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          Wrap(
            spacing: AppConstants.paddingS,
            children: symptoms
                .map((s) => Chip(
                      label: Text(s),
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: const TextStyle(fontSize: AppConstants.fontS),
                    ))
                .toList(),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingS),
            Text(
              notes,
              style: const TextStyle(
                fontSize: AppConstants.fontS,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
