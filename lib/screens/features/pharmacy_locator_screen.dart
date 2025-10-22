import 'package:flutter/material.dart';
import '../../models/pharmacy_model.dart';
import '../../services/pharmacy_service.dart';
import '../../services/launch_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';

class PharmacyLocatorScreen extends StatefulWidget {
  const PharmacyLocatorScreen({super.key});

  @override
  State<PharmacyLocatorScreen> createState() => _PharmacyLocatorScreenState();
}

class _PharmacyLocatorScreenState extends State<PharmacyLocatorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PharmacyService _pharmacyService = PharmacyService();

  List<Pharmacy> _pharmacies = [];
  List<Pharmacy> _filteredPharmacies = [];
  bool _isLoading = true;
  bool _showOpenNow = false;
  bool _show24Hours = false;
  bool _showNearby = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pharmacies = await _pharmacyService.getPharmaciesInDavao();
      setState(() {
        _pharmacies = pharmacies;
        _filteredPharmacies = pharmacies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pharmacies: $e')),
        );
      }
    }
  }

  void _filterPharmacies() {
    setState(() {
      _filteredPharmacies = _pharmacies.where((pharmacy) {
        // Apply search filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          if (!pharmacy.name.toLowerCase().contains(query) &&
              !pharmacy.address.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Apply open now filter
        if (_showOpenNow && !pharmacy.isOpenNow) {
          return false;
        }

        // Apply 24 hours filter
        if (_show24Hours && !pharmacy.isOpen24Hours) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> _callPharmacy(Pharmacy pharmacy) async {
    try {
      await LaunchService.makePhoneCall(pharmacy.phone);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not make phone call: $e')),
        );
      }
    }
  }

  Future<void> _getDirections(Pharmacy pharmacy) async {
    try {
      await LaunchService.openDirectionsTo(
        latitude: pharmacy.latitude,
        longitude: pharmacy.longitude,
        destinationName: pharmacy.name,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open directions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Find Pharmacy'),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: AppColors.surfaceLight,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterPharmacies(),
                  decoration: InputDecoration(
                    hintText: 'Search by location or pharmacy name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Getting current location...')),
                        );
                      },
                    ),
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
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: const Text('Open Now'),
                        selected: _showOpenNow,
                        onSelected: (selected) {
                          setState(() {
                            _showOpenNow = selected;
                          });
                          _filterPharmacies();
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: FilterChip(
                        label: const Text('24 Hours'),
                        selected: _show24Hours,
                        onSelected: (selected) {
                          setState(() {
                            _show24Hours = selected;
                          });
                          _filterPharmacies();
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: FilterChip(
                        label: const Text('Nearby'),
                        selected: _showNearby,
                        onSelected: (selected) {
                          setState(() {
                            _showNearby = selected;
                          });
                          _filterPharmacies();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pharmacy List
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _filteredPharmacies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_pharmacy_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: AppConstants.paddingM),
                            Text(
                              'No pharmacies found',
                              style: TextStyle(
                                fontSize: AppConstants.fontL,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingS),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                fontSize: AppConstants.fontM,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        itemCount: _filteredPharmacies.length,
                        itemBuilder: (context, index) {
                          final pharmacy = _filteredPharmacies[index];
                          return _buildPharmacyCard(pharmacy);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  size: AppConstants.iconL,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.name,
                      style: const TextStyle(
                        fontSize: AppConstants.fontL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: AppConstants.iconS,
                          color: AppColors.reward,
                        ),
                        const SizedBox(width: AppConstants.paddingXS),
                        Text(
                          pharmacy.rating.toString(),
                          style: const TextStyle(
                            fontSize: AppConstants.fontS,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingS),
                        const Icon(
                          Icons.location_on,
                          size: AppConstants.iconS,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppConstants.paddingXS),
                        Text(
                          pharmacy.distance,
                          style: const TextStyle(
                            fontSize: AppConstants.fontS,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                  vertical: AppConstants.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: pharmacy.isOpenNow
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Text(
                  pharmacy.isOpenNow ? 'Open' : 'Closed',
                  style: TextStyle(
                    fontSize: AppConstants.fontS,
                    fontWeight: FontWeight.w600,
                    color: pharmacy.isOpenNow
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Hours
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: AppConstants.iconS,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                pharmacy.hours,
                style: const TextStyle(
                  fontSize: AppConstants.fontS,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),

          // Address
          Row(
            children: [
              const Icon(
                Icons.place,
                size: AppConstants.iconS,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: Text(
                  pharmacy.address,
                  style: const TextStyle(
                    fontSize: AppConstants.fontS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pharmacy.phone.isNotEmpty
                      ? () => _callPharmacy(pharmacy)
                      : null,
                  icon: const Icon(Icons.phone, size: AppConstants.iconS),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _getDirections(pharmacy),
                  icon: const Icon(
                    Icons.directions,
                    size: AppConstants.iconS,
                    color: Colors.white,
                  ),
                  label: const Text('Directions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
