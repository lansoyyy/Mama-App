import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class PharmacyLocatorScreen extends StatefulWidget {
  const PharmacyLocatorScreen({super.key});

  @override
  State<PharmacyLocatorScreen> createState() => _PharmacyLocatorScreenState();
}

class _PharmacyLocatorScreenState extends State<PharmacyLocatorScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  decoration: InputDecoration(
                    hintText: 'Search by location or pharmacy name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Getting current location...')),
                        );
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.textWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
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
                        selected: false,
                        onSelected: (selected) {},
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: FilterChip(
                        label: const Text('24 Hours'),
                        selected: false,
                        onSelected: (selected) {},
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: FilterChip(
                        label: const Text('Nearby'),
                        selected: true,
                        onSelected: (selected) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pharmacy List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              children: [
                _buildPharmacyCard(
                  'Mercury Drug',
                  '0.5 km away',
                  'Open until 10:00 PM',
                  '(032) 123-4567',
                  '123 Main St, Cebu City',
                  true,
                  4.5,
                ),
                _buildPharmacyCard(
                  'Watsons Pharmacy',
                  '1.2 km away',
                  'Open 24 Hours',
                  '(032) 234-5678',
                  '456 Osmena Blvd, Cebu City',
                  true,
                  4.3,
                ),
                _buildPharmacyCard(
                  'Rose Pharmacy',
                  '2.0 km away',
                  'Closed - Opens at 8:00 AM',
                  '(032) 345-6789',
                  '789 Colon St, Cebu City',
                  false,
                  4.7,
                ),
                _buildPharmacyCard(
                  'Southstar Drug',
                  '2.5 km away',
                  'Open until 9:00 PM',
                  '(032) 456-7890',
                  '321 Mango Ave, Cebu City',
                  true,
                  4.2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(
    String name,
    String distance,
    String hours,
    String phone,
    String address,
    bool isOpen,
    double rating,
  ) {
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
                      name,
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
                          rating.toString(),
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
                          distance,
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
                  color: isOpen
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Text(
                  isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    fontSize: AppConstants.fontS,
                    fontWeight: FontWeight.w600,
                    color: isOpen ? AppColors.success : AppColors.error,
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
                hours,
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
                  address,
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling $name...')),
                    );
                  },
                  icon: const Icon(Icons.phone, size: AppConstants.iconS),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Getting directions to $name...')),
                    );
                  },
                  icon: const Icon(Icons.directions, size: AppConstants.iconS),
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
