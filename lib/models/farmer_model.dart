// lib/models/farmer_model.dart
class FarmerProfile {
  final String userId;
  final double farmSize;
  final List<String> mainCrops;
  final int yearsFarming;
  final String farmingMethod;
  final List<String> certifications;
  final double averageYield;
  final DateTime memberSince;
  final int totalListings;
  final double successRate;

  FarmerProfile({
    required this.userId,
    required this.farmSize,
    required this.mainCrops,
    required this.yearsFarming,
    required this.farmingMethod,
    this.certifications = const [],
    required this.averageYield,
    required this.memberSince,
    this.totalListings = 0,
    this.successRate = 0.0,
  });

  factory FarmerProfile.fromFirestore(Map<String, dynamic> data) {
    return FarmerProfile(
      userId: data['userId'],
      farmSize: data['farmSize'].toDouble(),
      mainCrops: List<String>.from(data['mainCrops']),
      yearsFarming: data['yearsFarming'],
      farmingMethod: data['farmingMethod'],
      certifications: List<String>.from(data['certifications']),
      averageYield: data['averageYield'].toDouble(),
      memberSince: DateTime.parse(data['memberSince']),
      totalListings: data['totalListings'] ?? 0,
      successRate: data['successRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'farmSize': farmSize,
      'mainCrops': mainCrops,
      'yearsFarming': yearsFarming,
      'farmingMethod': farmingMethod,
      'certifications': certifications,
      'averageYield': averageYield,
      'memberSince': memberSince.toIso8601String(),
      'totalListings': totalListings,
      'successRate': successRate,
    };
  }
}