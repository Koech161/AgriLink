// lib/models/location_model.dart
class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String county;
  final String subCounty;
  final String ward;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.county,
    required this.subCounty,
    required this.ward,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      county: map['county'] ?? '',
      subCounty: map['subCounty'] ?? '',
      ward: map['ward'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'county': county,
      'subCounty': subCounty,
      'ward': ward,
    };
  }

  static Location get defaultLocation => Location(
        latitude: -1.2921, // Nairobi coordinates
        longitude: 36.8219,
        address: 'Nairobi, Kenya',
        county: 'Nairobi',
        subCounty: 'Nairobi',
        ward: 'Nairobi',
      );
}