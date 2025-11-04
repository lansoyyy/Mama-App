import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../models/medication_model.dart';
import 'medication_detail_screen.dart';

class MedInfoHubScreen extends StatefulWidget {
  const MedInfoHubScreen({super.key});

  @override
  State<MedInfoHubScreen> createState() => _MedInfoHubScreenState();
}

class _MedInfoHubScreenState extends State<MedInfoHubScreen> {
  String _selectedLanguage = 'English';
  List<MedicationCategory> _categories = [];
  List<MedicationCategory> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categories = getMedicationCategories();
    _filteredCategories = List.from(_categories);
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    setState(() {
      if (_searchController.text.trim().isEmpty) {
        _filteredCategories = List.from(_categories);
      } else {
        final searchLower = _searchController.text.trim().toLowerCase();
        _filteredCategories = _categories.where((category) {
          final nameLower = category.name.toLowerCase();
          final descriptionLower = category.description.toLowerCase();

          if (_selectedLanguage == 'Filipino' &&
              category.translationFilipino != null) {
            final translationLower =
                category.translationFilipino!.toLowerCase();
            return nameLower.contains(searchLower) ||
                descriptionLower.contains(searchLower) ||
                translationLower.contains(searchLower);
          } else if (_selectedLanguage == 'Cebuano' &&
              category.translationCebuano != null) {
            final translationLower = category.translationCebuano!.toLowerCase();
            return nameLower.contains(searchLower) ||
                descriptionLower.contains(searchLower) ||
                translationLower.contains(searchLower);
          }

          return nameLower.contains(searchLower) ||
              descriptionLower.contains(searchLower);
        }).toList();
      }
    });
  }

  String _getLocalizedText(String? englishText, String? translatedText) {
    if (_selectedLanguage == 'English' || translatedText == null) {
      return englishText ?? '';
    }
    return translatedText;
  }

  String _getLocalizedTitle() {
    switch (_selectedLanguage) {
      case 'Filipino':
        return 'Matuto Tungkol sa Iyong mga Gamot';
      case 'Cebuano':
        return 'Kat-unan Mahitungod sa Imong mga Tambal';
      default:
        return 'Learn About Your Medications';
    }
  }

  String _getLocalizedSearchHint() {
    switch (_selectedLanguage) {
      case 'Filipino':
        return 'Maghanap ng gamot...';
      case 'Cebuano':
        return 'Pangita og tambal...';
      default:
        return 'Search medications...';
    }
  }

  String _getLocalizedEmptyResult() {
    switch (_selectedLanguage) {
      case 'Filipino':
        return 'Walang nahanap na kategorya';
      case 'Cebuano':
        return 'Wala makit nga kategorya';
      default:
        return 'No categories found';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'MedInfo Hub'),
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
                Text(
                  _getLocalizedTitle(),
                  style: const TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _getLocalizedSearchHint(),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textPrimary),
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
                                  child: Text(
                                    lang,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                          _filterCategories();
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
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      _getLocalizedEmptyResult(),
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(MedicationCategory category) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicationDetailScreen(
              category: category,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(category.iconData,
                color: category.color, size: AppConstants.iconL),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedText(
                      category.name,
                      _selectedLanguage == 'Filipino'
                          ? category.translationFilipino
                          : _selectedLanguage == 'Cebuano'
                              ? category.translationCebuano
                              : null),
                  style: const TextStyle(
                    fontSize: AppConstants.fontL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(
                  _getLocalizedText(
                      category.description,
                      _selectedLanguage == 'Filipino'
                          ? category.translationFilipino
                          : _selectedLanguage == 'Cebuano'
                              ? category.translationCebuano
                              : null),
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
