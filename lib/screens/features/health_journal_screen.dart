import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class HealthJournalScreen extends StatefulWidget {
  const HealthJournalScreen({super.key});

  @override
  State<HealthJournalScreen> createState() => _HealthJournalScreenState();
}

class _HealthJournalScreenState extends State<HealthJournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Daily Health Journal'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Today's Entry Card
          CustomCard(
            gradient: AppColors.primaryGradient,
            child: Column(
              children: [
                const Icon(
                  Icons.book,
                  size: AppConstants.iconXXL,
                  color: AppColors.textWhite,
                ),
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'Today\'s Entry',
                  style: TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(
                  DateTime.now().toString().split(' ')[0],
                  style: const TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                CustomButton(
                  text: 'Add Entry',
                  icon: Icons.add,
                  backgroundColor: AppColors.textWhite,
                  textColor: AppColors.primary,
                  onPressed: () {
                    _showAddEntryDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Mood',
                  '😊',
                  'Good',
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _buildStatCard(
                  'Energy',
                  '⚡',
                  'High',
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          // Recent Entries
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Entries',
                style: TextStyle(
                  fontSize: AppConstants.fontXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          _buildJournalEntry(
            'Today',
            '10:30 AM',
            'Feeling great today! Took all my vitamins on time. Had a good breakfast with fruits and vegetables.',
            ['Good Mood', 'High Energy', 'Healthy Eating'],
          ),
          _buildJournalEntry(
            'Yesterday',
            '9:15 AM',
            'Slight headache in the morning but felt better after taking medication. Rested well.',
            ['Mild Headache', 'Rested', 'Medication Taken'],
          ),
          _buildJournalEntry(
            '2 days ago',
            '8:00 AM',
            'Regular checkup went well. Doctor said everything is progressing nicely. Baby is healthy!',
            ['Checkup', 'Good News', 'Happy'],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEntryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, String emoji, String value, Color color) {
    return CustomCard(
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppConstants.fontS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalEntry(
    String date,
    String time,
    String content,
    List<String> tags,
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
                date,
                style: const TextStyle(
                  fontSize: AppConstants.fontL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: AppConstants.fontS,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            content,
            style: const TextStyle(
              fontSize: AppConstants.fontM,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Wrap(
            spacing: AppConstants.paddingS,
            children: tags
                .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        fontSize: AppConstants.fontS,
                        color: AppColors.primary,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String selectedMood = 'Good';
    String selectedEnergy = 'High';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Journal Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How are you feeling?'),
              const SizedBox(height: AppConstants.paddingS),
              DropdownButtonFormField<String>(
                value: selectedMood,
                items: ['Great', 'Good', 'Okay', 'Not Good', 'Bad']
                    .map((mood) => DropdownMenuItem(
                          value: mood,
                          child: Text(mood),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedMood = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              DropdownButtonFormField<String>(
                value: selectedEnergy,
                items: ['High', 'Medium', 'Low']
                    .map((energy) => DropdownMenuItem(
                          value: energy,
                          child: Text(energy),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedEnergy = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Energy Level',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Write about your day...',
                  border: OutlineInputBorder(),
                ),
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
              // TODO: Save entry
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Journal entry saved'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
