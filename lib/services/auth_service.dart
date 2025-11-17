// lib/services/auth_service.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> verifyPhoneNumber(String phoneNumber) async {
  try {
    String formattedNumber = _formatPhoneNumber(phoneNumber);
    print('📞 Verifying phone: $formattedNumber');
    
    Completer<String?> completer = Completer<String?>();
    
    await _auth.verifyPhoneNumber(
      phoneNumber: formattedNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('✅ Verification completed automatically');
        await _auth.signInWithCredential(credential);
        completer.complete(null);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('❌ Verification failed: ${e.message}');
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        print('📲 Code sent successfully. Verification ID: $verificationId');
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('⏰ Code auto-retrieval timeout');
        completer.complete(verificationId);
      },
      timeout: Duration(seconds: 60),
    );
    
    return await completer.future;
  } catch (e) {
    print('Phone verification error: $e');
    rethrow;
  }
}

  Future<UserCredential> signInWithOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw e;
    }
  }

  Future<void> createUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection(AppConstants.firebaseUsersCollection)
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      throw e;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.firebaseUsersCollection)
          .doc(firebaseUser.uid)
          .get();
      
      if (userDoc.exists) {
        return AppUser.fromFirestore(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.firebaseUsersCollection)
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw e;
    }
  }
  Future<void> createUserProfileWithoutAuth(AppUser user) async {
  try {
    // print('Creating user profile without auth for: ${user.uid}');
    
    // Create user without requiring authentication
    await _firestore
        .collection(AppConstants.firebaseUsersCollection)
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
        
    // print('User profile created successfully without auth');
  } catch (e) {
    // print('Error creating user profile without auth: $e');
    throw e;
  }
}

Future<QuerySnapshot> checkIfUserExists(String email) async {
  try {
    return await _firestore
        .collection(AppConstants.firebaseUsersCollection)
        .where('email', isEqualTo: email)
        .get();
  } catch (e) {
    print('Error checking user existence: $e');
    rethrow;
  }
}


  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return '+254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('254')) {
      return '+$phoneNumber';
    } else if (!phoneNumber.startsWith('+')) {
      return '+$phoneNumber';
    }
    return phoneNumber;
  }
}


