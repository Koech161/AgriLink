// lib/services/storage_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> bookStorage({
    required String facilityId,
    required String farmerId,
    required String produceId,
    required double quantity,
    required DateTime startDate,
    required int durationDays,
  }) async {
    try {
      final bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore
          .collection('storage_bookings')
          .doc(bookingId)
          .set({
            'id': bookingId,
            'facilityId': facilityId,
            'farmerId': farmerId,
            'produceId': produceId,
            'quantity': quantity,
            'startDate': startDate.toIso8601String(),
            'durationDays': durationDays,
            'status': 'pending',
            'createdAt': DateTime.now().toIso8601String(),
            'totalCost': quantity * 5.0, // Mock calculation
          });
    } catch (e) {
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getStorageBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('storage_bookings')
          .where('farmerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw e;
    }
  }
}