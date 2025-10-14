import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class MedInfoHubScreen extends StatefulWidget {
  const MedInfoHubScreen({super.key});

  @override
  State<MedInfoHubScreen> createState() => _MedInfoHubScreenState();
}

class _MedInfoHubScreenState extends State<MedInfoHubScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'MedInfo Hub'),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingL),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.radiusXL),
                bottomRight: Radius.circular(AppConstants.radiusXL),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Learn About Your Medications',
                  style: TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Search Bar
                TextField(
                  onChanged: (value) {
                    // TODO: Implement search functionality
                  },
                  decoration: InputDecoration(
                    hintText: 'Search medications...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.textWhite,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Language Selector
                Row(
                  children: [
                    const Icon(Icons.language, color: AppColors.textWhite),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        dropdownColor: AppColors.primary,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 20),
                        ),
                        items: AppConstants.supportedLanguages
                            .map((lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              children: [
                _buildCategoryCard(
                  'Prenatal Vitamins',
                  'Essential vitamins for pregnancy',
                  Icons.medical_services,
                  AppColors.primary,
                ),
                _buildCategoryCard(
                  'Iron Supplements',
                  'Prevent anemia during pregnancy',
                  Icons.bloodtype,
                  AppColors.error,
                ),
                _buildCategoryCard(
                  'Folic Acid',
                  'Important for baby development',
                  Icons.favorite,
                  AppColors.secondary,
                ),
                _buildCategoryCard(
                  'Calcium',
                  'Strengthen bones and teeth',
                  Icons.health_and_safety,
                  AppColors.info,
                ),
                _buildCategoryCard(
                  'Pain Relief',
                  'Safe pain management options',
                  Icons.healing,
                  AppColors.warning,
                ),
                _buildCategoryCard(
                  'Antibiotics',
                  'Understanding safe antibiotics',
                  Icons.medication_liquid,
                  AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title details coming soon')),
        );
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(icon, color: color, size: AppConstants.iconL),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: AppConstants.iconS,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
