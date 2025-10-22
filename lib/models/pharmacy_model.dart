class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String hours;
  final bool isOpen24Hours;
  final bool isOpenNow;
  final double rating;
  final String distance;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.hours,
    required this.isOpen24Hours,
    required this.isOpenNow,
    required this.rating,
    required this.distance,
  });

  // Factory constructor for JSON deserialization
  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      hours: json['hours'] ?? '',
      isOpen24Hours: json['isOpen24Hours'] ?? false,
      isOpenNow: json['isOpenNow'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: json['distance'] ?? '',
    );
  }

  // Factory constructor for Firestore documents
  factory Pharmacy.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Pharmacy(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      hours: data['hours'] ?? '',
      isOpen24Hours: data['isOpen24Hours'] ?? false,
      isOpenNow: data['isOpenNow'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      distance: data['distance'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'hours': hours,
      'isOpen24Hours': isOpen24Hours,
      'isOpenNow': isOpenNow,
      'rating': rating,
      'distance': distance,
    };
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'hours': hours,
      'isOpen24Hours': isOpen24Hours,
      'isOpenNow': isOpenNow,
      'rating': rating,
      'distance': distance,
    };
  }
}
