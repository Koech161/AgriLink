// lib/models/user_model.dart
import './location_model.dart';

enum UserType { farmer, buyer, transporter, storageOwner }

class AppUser {
  final String uid;
  final String phoneNumber;
  final UserType userType;
  final String displayName;
  final String? email;
  final String county;
  final Location location;
  final DateTime createdAt;
  final bool isProfileComplete;
  final String? profileImageUrl;
  final double? rating;
  final int totalTransactions;

  AppUser({
    required this.uid,
    required this.phoneNumber,
    required this.userType,
    required this.displayName,
    this.email,
    required this.county,
    required this.location,
    required this.createdAt,
    this.isProfileComplete = false,
    this.profileImageUrl,
    this.rating,
    this.totalTransactions = 0,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      phoneNumber: data['phoneNumber'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == data['userType'],
      ),
      displayName: data['displayName'],
      email: data['email'],
      county: data['county'],
      location: Location.fromMap(data['location']),
      createdAt: DateTime.parse(data['createdAt']),
      isProfileComplete: data['isProfileComplete'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      rating: data['rating']?.toDouble(),
      totalTransactions: data['totalTransactions'] ?? 0,
    );
  }

  /// Backwards-compatible JSON factory used by some call sites.
  /// If other code calls `AppUser.fromJson(...)` this will delegate to
  /// `fromFirestore` so both names work.
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser.fromFirestore(json);

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'userType': userType.toString().split('.').last,
      'displayName': displayName,
      'email': email,
      'county': county,
      'location': location.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'isProfileComplete': isProfileComplete,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalTransactions': totalTransactions,
    };
  }

  // Add the copyWith method here
  AppUser copyWith({
    String? uid,
    String? phoneNumber,
    UserType? userType,
    String? displayName,
    String? email,
    String? county,
    Location? location,
    DateTime? createdAt,
    bool? isProfileComplete,
    String? profileImageUrl,
    double? rating,
    int? totalTransactions,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      county: county ?? this.county,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalTransactions: totalTransactions ?? this.totalTransactions,
    );
  }
}