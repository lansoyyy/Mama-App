import 'package:flutter/material.dart';
import '../../models/medication_model.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class MedicationDetailScreen extends StatefulWidget {
  final MedicationCategory category;

  const MedicationDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  String _selectedLanguage = 'English';
  List<MedicationModel> _medications = [];
  List<MedicationModel> _filteredMedications = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _medications = getMedicationsByCategory(widget.category.id);
    _filteredMedications = List.from(_medications);
    _searchController.addListener(_filterMedications);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMedications() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredMedications = List.from(_medications);
      } else {
        _filteredMedications = _medications.where((medication) {
          final searchLower = _searchController.text.toLowerCase();
          final nameLower = medication.name.toLowerCase();
          final descriptionLower = medication.description.toLowerCase();

          if (_selectedLanguage == 'Filipino' &&
              medication.translationFilipino != null) {
            final translationLower =
                medication.translationFilipino!.toLowerCase();
            return nameLower.contains(searchLower) ||
                descriptionLower.contains(searchLower) ||
                translationLower.contains(searchLower);
          } else if (_selectedLanguage == 'Cebuano' &&
              medication.translationCebuano != null) {
            final translationLower =
                medication.translationCebuano!.toLowerCase();
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

  String _getLocalizedCategoryName() {
    return _getLocalizedText(
        widget.category.name,
        _selectedLanguage == 'Filipino'
            ? widget.category.translationFilipino
            : _selectedLanguage == 'Cebuano'
                ? widget.category.translationCebuano
                : null);
  }

  String _getLocalizedCategoryDescription() {
    return _getLocalizedText(
        widget.category.description,
        _selectedLanguage == 'Filipino'
            ? widget.category.translationFilipino
            : _selectedLanguage == 'Cebuano'
                ? widget.category.translationCebuano
                : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _getLocalizedCategoryName()),
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
                // Category Icon and Info
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: widget.category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Icon(
                    widget.category.iconData,
                    color: widget.category.color,
                    size: AppConstants.iconXXL,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                Text(
                  _getLocalizedCategoryName(),
                  style: const TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(
                  _getLocalizedCategoryDescription(),
                  style: const TextStyle(
                    fontSize: AppConstants.fontM,
                    color: AppColors.textWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingL),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _selectedLanguage == 'Filipino'
                        ? 'Maghanap ng gamot...'
                        : _selectedLanguage == 'Cebuano'
                            ? 'Pangita og tambal...'
                            : 'Search medications...',
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
                          _filterMedications();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Medications List
          Expanded(
            child: _filteredMedications.isEmpty
                ? Center(
                    child: Text(
                      _selectedLanguage == 'Filipino'
                          ? 'Walang nahanap na gamot'
                          : _selectedLanguage == 'Cebuano'
                              ? 'Wala makit nga tambal'
                              : 'No medications found',
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    itemCount: _filteredMedications.length,
                    itemBuilder: (context, index) {
                      final medication = _filteredMedications[index];
                      return _buildMedicationCard(medication);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationModel medication) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      onTap: () {
        _showMedicationDetails(medication);
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              Icons.medication,
              color: widget.category.color,
              size: AppConstants.iconL,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedText(
                      medication.name,
                      _selectedLanguage == 'Filipino'
                          ? medication.translationFilipino
                          : _selectedLanguage == 'Cebuano'
                              ? medication.translationCebuano
                              : null),
                  style: const TextStyle(
                    fontSize: AppConstants.fontL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(
                  medication.description,
                  style: const TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: medication.isSafeForPregnancy
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        medication.isSafeForPregnancy
                            ? (_selectedLanguage == 'Filipino'
                                ? 'Ligtas'
                                : _selectedLanguage == 'Cebuano'
                                    ? 'Luwas'
                                    : 'Safe')
                            : (_selectedLanguage == 'Filipino'
                                ? 'Huwag gamitin'
                                : _selectedLanguage == 'Cebuano'
                                    ? 'Ayaw gamita'
                                    : 'Avoid'),
                        style: TextStyle(
                          fontSize: AppConstants.fontXS,
                          color: medication.isSafeForPregnancy
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Text(
                      'Category ${medication.pregnancyCategory}',
                      style: const TextStyle(
                        fontSize: AppConstants.fontXS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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

  void _showMedicationDetails(MedicationModel medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: widget.category.color,
                      size: AppConstants.iconL,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedText(
                              medication.name,
                              _selectedLanguage == 'Filipino'
                                  ? medication.translationFilipino
                                  : _selectedLanguage == 'Cebuano'
                                      ? medication.translationCebuano
                                      : null),
                          style: const TextStyle(
                            fontSize: AppConstants.fontXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          medication.description,
                          style: const TextStyle(
                            fontSize: AppConstants.fontM,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),

              // Safety Status
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: medication.isSafeForPregnancy
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      medication.isSafeForPregnancy
                          ? Icons.check_circle
                          : Icons.warning,
                      color: medication.isSafeForPregnancy
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: Text(
                        medication.isSafeForPregnancy
                            ? (_selectedLanguage == 'Filipino'
                                ? 'Ligtas para sa buntis'
                                : _selectedLanguage == 'Cebuano'
                                    ? 'Luwas sa buntis'
                                    : 'Safe for pregnancy')
                            : (_selectedLanguage == 'Filipino'
                                ? 'Huwag gamitin habang buntis'
                                : _selectedLanguage == 'Cebuano'
                                    ? 'Ayaw gamita samtang buntis'
                                    : 'Avoid during pregnancy'),
                        style: TextStyle(
                          fontSize: AppConstants.fontM,
                          fontWeight: FontWeight.w600,
                          color: medication.isSafeForPregnancy
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),

              // Uses
              _buildSection(
                _selectedLanguage == 'Filipino'
                    ? 'Mga Gamit'
                    : _selectedLanguage == 'Cebuano'
                        ? 'Mga Gamit'
                        : 'Uses',
                Icons.check_circle_outline,
                medication.uses,
              ),
              const SizedBox(height: AppConstants.paddingL),

              // Dosage
              _buildSection(
                _selectedLanguage == 'Filipino'
                    ? 'Dosis'
                    : _selectedLanguage == 'Cebuano'
                        ? 'Dosis'
                        : 'Dosage',
                Icons.medication_liquid,
                medication.dosage,
              ),
              const SizedBox(height: AppConstants.paddingL),

              // Side Effects
              _buildSection(
                _selectedLanguage == 'Filipino'
                    ? 'Mga Epekto'
                    : _selectedLanguage == 'Cebuano'
                        ? 'Mga Epekto'
                        : 'Side Effects',
                Icons.warning_amber,
                medication.sideEffects,
              ),
              const SizedBox(height: AppConstants.paddingL),

              // Precautions
              _buildSection(
                _selectedLanguage == 'Filipino'
                    ? 'Mga Babala'
                    : _selectedLanguage == 'Cebuano'
                        ? 'Mga Babala'
                        : 'Precautions',
                Icons.info_outline,
                medication.precautions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: widget.category.color, size: AppConstants.iconM),
            const SizedBox(width: AppConstants.paddingS),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.fontL,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: AppConstants.fontM,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }
}
