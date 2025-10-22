import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pharmacy_model.dart';
import '../utils/constants.dart';

class PharmacyService {
  Future<List<Pharmacy>> getPharmaciesInDavao() async {
    try {
      // Using Google Places API to find pharmacies in Davao City
      final response = await http.get(
        Uri.parse('${AppConstants.googlePlacesBaseUrl}/nearbysearch/json'
            '?location=${AppConstants.davaoCityLatitude},${AppConstants.davaoCityLongitude}'
            '&radius=10000'
            '&type=pharmacy'
            '&key=${AppConstants.googlePlacesApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null) {
          List<Pharmacy> pharmacies = [];

          for (var place in data['results']) {
            // Get detailed information including phone number
            final details = await _getPlaceDetails(place['place_id']);

            pharmacies.add(Pharmacy(
              id: place['place_id'],
              name: place['name'] ?? 'Unknown Pharmacy',
              address: place['vicinity'] ?? 'No address available',
              phone: details['formatted_phone_number'] ?? '',
              latitude: place['geometry']['location']['lat'] ?? 0.0,
              longitude: place['geometry']['location']['lng'] ?? 0.0,
              hours: _getOpeningHours(details['opening_hours']),
              isOpen24Hours: _is24Hours(details['opening_hours']),
              isOpenNow: details['opening_hours']?['open_now'] ?? false,
              rating: (place['rating'] ?? 0.0).toDouble(),
              distance:
                  'Calculating...', // Will be calculated based on user location
            ));
          }

          return pharmacies;
        } else {
          throw Exception(
              'Google Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
            'Failed to load pharmacies: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      print('Error fetching from Google Places API: $e');
      return _getMockPharmacies();
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.googlePlacesBaseUrl}/details/json'
            '?place_id=$placeId'
            '&fields=name,formatted_phone_number,opening_hours,geometry'
            '&key=${AppConstants.googlePlacesApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          return data['result'];
        }
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }

    return {};
  }

  String _getOpeningHours(Map<String, dynamic>? openingHours) {
    if (openingHours == null) return 'Hours not available';

    if (openingHours['open_now'] == true) {
      return 'Open now';
    } else {
      return 'Closed';
    }
  }

  bool _is24Hours(Map<String, dynamic>? openingHours) {
    if (openingHours == null || openingHours['periods'] == null) return false;

    // Check if any day has 24-hour operation
    for (var period in openingHours['periods']) {
      if (period['open']?['time'] == '0000' &&
          period['close']?['time'] == '0000') {
        return true;
      }
    }

    return false;
  }

  Future<List<Pharmacy>> searchPharmacies(String query) async {
    try {
      // Using Google Places Text Search API
      final response = await http.get(
        Uri.parse('${AppConstants.googlePlacesBaseUrl}/textsearch/json'
            '?query=pharmacy $query in Davao City'
            '&type=pharmacy'
            '&key=${AppConstants.googlePlacesApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null) {
          List<Pharmacy> pharmacies = [];

          for (var place in data['results']) {
            final details = await _getPlaceDetails(place['place_id']);

            pharmacies.add(Pharmacy(
              id: place['place_id'],
              name: place['name'] ?? 'Unknown Pharmacy',
              address: place['formatted_address'] ?? 'No address available',
              phone: details['formatted_phone_number'] ?? '',
              latitude: place['geometry']['location']['lat'] ?? 0.0,
              longitude: place['geometry']['location']['lng'] ?? 0.0,
              hours: _getOpeningHours(details['opening_hours']),
              isOpen24Hours: _is24Hours(details['opening_hours']),
              isOpenNow: details['opening_hours']?['open_now'] ?? false,
              rating: (place['rating'] ?? 0.0).toDouble(),
              distance: 'Calculating...',
            ));
          }

          return pharmacies;
        } else {
          throw Exception('Google Places API error: ${data['status']}');
        }
      } else {
        throw Exception(
            'Failed to search pharmacies: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to filtering existing data
      print('Error searching with Google Places API: $e');
      final allPharmacies = await getPharmaciesInDavao();
      return allPharmacies.where((pharmacy) {
        return pharmacy.name.toLowerCase().contains(query.toLowerCase()) ||
            pharmacy.address.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<List<Pharmacy>> filterPharmacies({
    bool? isOpenNow,
    bool? is24Hours,
    double? maxDistance,
  }) async {
    try {
      final allPharmacies = await getPharmaciesInDavao();
      return allPharmacies.where((pharmacy) {
        if (isOpenNow != null && pharmacy.isOpenNow != isOpenNow) {
          return false;
        }
        if (is24Hours != null && pharmacy.isOpen24Hours != is24Hours) {
          return false;
        }
        if (maxDistance != null) {
          final distance = double.tryParse(
                  pharmacy.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0;
          if (distance > maxDistance) {
            return false;
          }
        }
        return true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter pharmacies: $e');
    }
  }

  // Mock data for demonstration - replace with actual API calls
  List<Pharmacy> _getMockPharmacies() {
    return [
      Pharmacy(
        id: '1',
        name: 'Mercury Drug - Davao',
        address: 'CM Recto Street, Davao City',
        phone: '(082) 227-6131',
        latitude: 7.0731,
        longitude: 125.6128,
        hours: 'Open until 10:00 PM',
        isOpen24Hours: false,
        isOpenNow: true,
        rating: 4.5,
        distance: '0.5 km away',
      ),
      Pharmacy(
        id: '2',
        name: 'Watsons - SM City Davao',
        address: 'SM City Davao, Quimpo Blvd, Davao City',
        phone: '(082) 295-1234',
        latitude: 7.0759,
        longitude: 125.6084,
        hours: 'Open 24 Hours',
        isOpen24Hours: true,
        isOpenNow: true,
        rating: 4.3,
        distance: '1.2 km away',
      ),
      Pharmacy(
        id: '3',
        name: 'Rose Pharmacy - Bajada',
        address: 'J.P. Laurel Avenue, Bajada, Davao City',
        phone: '(082) 224-5678',
        latitude: 7.0776,
        longitude: 125.6156,
        hours: 'Closed - Opens at 8:00 AM',
        isOpen24Hours: false,
        isOpenNow: false,
        rating: 4.7,
        distance: '2.0 km away',
      ),
      Pharmacy(
        id: '4',
        name: 'Southstar Drug - Davao',
        address: 'Magsaysay Street, Davao City',
        phone: '(082) 222-3456',
        latitude: 7.0699,
        longitude: 125.6092,
        hours: 'Open until 9:00 PM',
        isOpen24Hours: false,
        isOpenNow: true,
        rating: 4.2,
        distance: '2.5 km away',
      ),
      Pharmacy(
        id: '5',
        name: 'The Generics Pharmacy',
        address: 'Roxas Avenue, Davao City',
        phone: '(082) 282-7890',
        latitude: 7.0745,
        longitude: 125.6134,
        hours: 'Open until 8:00 PM',
        isOpen24Hours: false,
        isOpenNow: true,
        rating: 4.1,
        distance: '3.1 km away',
      ),
    ];
  }
}
