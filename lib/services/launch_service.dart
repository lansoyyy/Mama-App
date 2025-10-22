import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchService {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not launch $phoneUri');
      throw Exception('Could not launch phone call');
    }
  }

  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final String googleMapsUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android, use the Google Maps app
      googleMapsUrl = 'google.navigation:q=$latitude,$longitude';
    } else {
      // For iOS and web, use the web version
      final query =
          label != null ? Uri.encodeComponent(label) : '$latitude,$longitude';
      googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    }

    final Uri mapsUri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web version
      final webUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final webUri = Uri.parse(webUrl);

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch Google Maps');
        throw Exception('Could not launch Google Maps');
      }
    }
  }

  static Future<void> openDirectionsTo({
    required double latitude,
    required double longitude,
    String? destinationName,
  }) async {
    final String directionsUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android, use the Google Maps navigation
      directionsUrl = 'google.navigation:q=$latitude,$longitude';
    } else {
      // For iOS and web, use the web version with directions
      final destination = destinationName != null
          ? Uri.encodeComponent(destinationName)
          : '$latitude,$longitude';
      directionsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$destination';
    }

    final Uri directionsUri = Uri.parse(directionsUrl);

    if (await canLaunchUrl(directionsUri)) {
      await launchUrl(directionsUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web version
      final webUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
      final webUri = Uri.parse(webUrl);

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch directions');
        throw Exception('Could not launch directions');
      }
    }
  }
}
