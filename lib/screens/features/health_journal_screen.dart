import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../models/health_journal_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class HealthJournalScreen extends StatefulWidget {
  const HealthJournalScreen({super.key});

  @override
  State<HealthJournalScreen> createState() => _HealthJournalScreenState();
}

class _HealthJournalScreenState extends State<HealthJournalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<HealthJournalModel> _journalEntries = [];
  Map<String, dynamic>? _todayEntry;
  Map<String, dynamic>? _journalStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournalData();
  }

  Future<void> _loadJournalData() async {
    if (!_authService.isAuthenticated) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String userId = _authService.currentUserId!;

    try {
      // Get today's entry
      _todayEntry = await _firestoreService.getTodayHealthJournalEntry(userId);

      // Get journal stats
      _journalStats = await _firestoreService.getHealthJournalStats(userId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading journal data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Daily Health Journal'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_authService.isAuthenticated) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Daily Health Journal'),
        body: const Center(
          child: Text('Please log in to view your health journal'),
        ),
      );
    }

    String userId = _authService.currentUserId!;
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
                Text(
                  _todayEntry != null ? 'Today\'s Entry' : 'No Entry Today',
                  style: const TextStyle(
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
                  text: _todayEntry != null ? 'Edit Entry' : 'Add Entry',
                  icon: _todayEntry != null ? Icons.edit : Icons.add,
                  backgroundColor: AppColors.textWhite,
                  textColor: AppColors.primary,
                  onPressed: () {
                    _showAddEntryDialog(context, existingEntry: _todayEntry);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),

          // Quick Stats
          _buildQuickStats(),
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

          // Stream of recent journal entries
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getRecentHealthJournalEntries(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingL),
                    child: Text(
                      'No journal entries yet. Start by adding your first entry!',
                      style: TextStyle(
                        fontSize: AppConstants.fontM,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return _buildJournalEntry(
                    data['date'] ?? '',
                    data['time'] ?? '',
                    data['content'] ?? '',
                    List<String>.from(data['tags'] ?? []),
                    doc.id,
                  );
                }).toList(),
              );
            },
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

  Widget _buildQuickStats() {
    if (_journalStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String mostCommonMood = _journalStats!['mostCommonMood'] ?? 'Good';
    String mostCommonEnergy = _journalStats!['mostCommonEnergy'] ?? 'Medium';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Mood',
            MoodOptions.getEmoji(mostCommonMood),
            MoodOptions.getDisplayName(mostCommonMood),
            _getMoodColor(mostCommonMood),
          ),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: _buildStatCard(
            'Energy',
            EnergyLevelOptions.getEmoji(mostCommonEnergy),
            EnergyLevelOptions.getDisplayName(mostCommonEnergy),
            _getEnergyColor(mostCommonEnergy),
          ),
        ),
      ],
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Great':
        return AppColors.success;
      case 'Good':
        return AppColors.primary;
      case 'Okay':
        return AppColors.warning;
      case 'Not Good':
        return Colors.orange;
      case 'Bad':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _getEnergyColor(String energy) {
    switch (energy) {
      case 'High':
        return AppColors.success;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
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
    String entryId,
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
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: AppConstants.fontS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () {
                      // TODO: Edit entry
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        size: 16, color: AppColors.error),
                    onPressed: () {
                      _deleteEntry(entryId);
                    },
                  ),
                ],
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

  void _showAddEntryDialog(BuildContext context,
      {Map<String, dynamic>? existingEntry}) {
    final TextEditingController controller = TextEditingController(
      text: existingEntry?['content'] ?? '',
    );
    String selectedMood = existingEntry?['mood'] ?? 'Good';
    String selectedEnergy = existingEntry?['energyLevel'] ?? 'High';
    List<String> selectedTags = existingEntry != null
        ? List<String>.from(existingEntry['tags'] ?? [])
        : [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingEntry != null
              ? 'Edit Journal Entry'
              : 'Add Journal Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How are you feeling?'),
                const SizedBox(height: AppConstants.paddingS),
                DropdownButtonFormField<String>(
                  value: selectedMood,
                  items: MoodOptions.getAll()
                      .map((mood) => DropdownMenuItem(
                            value: mood,
                            child: Row(
                              children: [
                                Text(MoodOptions.getEmoji(mood)),
                                const SizedBox(width: AppConstants.paddingS),
                                Text(mood),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMood = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Mood',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                DropdownButtonFormField<String>(
                  value: selectedEnergy,
                  items: EnergyLevelOptions.getAll()
                      .map((energy) => DropdownMenuItem(
                            value: energy,
                            child: Row(
                              children: [
                                Text(EnergyLevelOptions.getEmoji(energy)),
                                const SizedBox(width: AppConstants.paddingS),
                                Text(energy),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEnergy = value!;
                    });
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
                const SizedBox(height: AppConstants.paddingM),
                const Text('Tags'),
                const SizedBox(height: AppConstants.paddingS),
                Wrap(
                  spacing: AppConstants.paddingS,
                  runSpacing: AppConstants.paddingS,
                  children: CommonJournalTags.tags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
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
                _saveJournalEntry(
                  content: controller.text.trim(),
                  mood: selectedMood,
                  energyLevel: selectedEnergy,
                  tags: selectedTags,
                  existingEntry: existingEntry,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveJournalEntry({
    required String content,
    required String mood,
    required String energyLevel,
    required List<String> tags,
    Map<String, dynamic>? existingEntry,
  }) async {
    if (!_authService.isAuthenticated) return;

    String userId = _authService.currentUserId!;
    DateTime now = DateTime.now();
    String date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    String time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    try {
      if (existingEntry != null) {
        // Update existing entry
        // We need to get the document ID from the existing entry
        // Since we don't have it directly, we'll need to query for it
        // For now, let's just add a new entry
        await _firestoreService.addHealthJournalEntry(
          userId: userId,
          date: date,
          time: time,
          content: content,
          tags: tags,
          mood: mood,
          energyLevel: energyLevel,
          timestamp: now,
        );
      } else {
        // Add new entry
        await _firestoreService.addHealthJournalEntry(
          userId: userId,
          date: date,
          time: time,
          content: content,
          tags: tags,
          mood: mood,
          energyLevel: energyLevel,
          timestamp: now,
        );
      }

      // Reload data to update UI
      _loadJournalData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingEntry != null
              ? 'Journal entry updated'
              : 'Journal entry saved'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('Error saving journal entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving journal entry'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    try {
      await _firestoreService.deleteHealthJournalEntry(entryId);
      _loadJournalData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal entry deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('Error deleting journal entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting journal entry'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
