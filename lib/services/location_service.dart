// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Location> getCurrentLocation() async {
    try {
      final position = await getCurrentPosition();
      
      // In a real app, you would use reverse geocoding here
      // For now, return a mock location based on coordinates
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Current Location',
        county: 'Nairobi', // This should come from reverse geocoding
        subCounty: 'Nairobi',
        ward: 'Nairobi',
      );
    } catch (e) {
      // Return default location if GPS fails
      return Location.defaultLocation;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // in kilometers
  }
}