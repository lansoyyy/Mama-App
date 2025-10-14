import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
            children: [
              _buildSymptomChip('Nausea'),
              _buildSymptomChip('Headache'),
              _buildSymptomChip('Fatigue'),
              _buildSymptomChip('Dizziness'),
              _buildSymptomChip('Stomach Pain'),
              _buildSymptomChip('Vomiting'),
              _buildSymptomChip('Fever'),
              _buildSymptomChip('Rash'),
              _buildSymptomChip('Swelling'),
              _buildSymptomChip('Difficulty Breathing'),
              _buildSymptomChip('Chest Pain'),
              _buildSymptomChip('Other'),
            ],
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
          CustomButton(
            text: 'Log Symptoms',
            icon: Icons.save,
            onPressed: () {
              // TODO: Save symptoms
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Symptoms logged successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
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
          
          _buildSymptomLogCard(
            'Today, 10:30 AM',
            ['Nausea', 'Fatigue'],
            'Mild',
            AppColors.success,
          ),
          _buildSymptomLogCard(
            'Yesterday, 3:00 PM',
            ['Headache', 'Dizziness'],
            'Moderate',
            AppColors.warning,
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
    return Card(
      elevation: AppConstants.elevationS,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
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
        ],
      ),
    );
  }
}
