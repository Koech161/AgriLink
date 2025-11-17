// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produce_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Produce Methods
  Future<void> addProduce(Produce produce) async {
    try {
      await _firestore
          .collection(AppConstants.firebaseProduceCollection)
          .doc(produce.id)
          .set(produce.toFirestore());
    } catch (e) {
      throw e;
    }
  }

  Stream<List<Produce>> getProduceStream() {
    return _firestore
        .collection(AppConstants.firebaseProduceCollection)
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Produce.fromFirestore(doc.data()))
            .toList());
  }

  Stream<List<Produce>> getProduceByFarmer(String farmerId) {
    return _firestore
        .collection(AppConstants.firebaseProduceCollection)
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Produce.fromFirestore(doc.data()))
            .toList());
  }

  Future<void> updateProduceStatus(String produceId, ProduceStatus status) async {
    try {
      await _firestore
          .collection(AppConstants.firebaseProduceCollection)
          .doc(produceId)
          .update({
            'status': status.toString().split('.').last,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw e;
    }
  }

  // User Methods
  Stream<AppUser?> getUserStream(String uid) {
    return _firestore
        .collection(AppConstants.firebaseUsersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists 
            ? AppUser.fromFirestore(snapshot.data()!) 
            : null);
  }

  Future<List<AppUser>> getUsersByType(UserType userType) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.firebaseUsersCollection)
          .where('userType', isEqualTo: userType.toString().split('.').last)
          .get();
      
      return snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  // Storage Facilities
  Future<List<Map<String, dynamic>>> getStorageFacilities(String county) async {
    // Mock data - replace with actual Firestore implementation
    return [
      {
        'id': '1',
        'name': 'GreenCold Storage',
        'county': county,
        'capacity': 1000,
        'availableSpace': 450,
        'pricePerKg': 5.0,
        'rating': 4.5,
      },
      {
        'id': '2', 
        'name': 'FarmFresh Coolers',
        'county': county,
        'capacity': 800,
        'availableSpace': 200,
        'pricePerKg': 4.5,
        'rating': 4.2,
      },
    ];
  }
}