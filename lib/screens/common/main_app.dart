// lib/screens/common/main_app.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../onboarding/welcome_screen.dart';
import '../auth/phone_auth_screen.dart';
import '../farmer/farmer_dashboard.dart';
import '../buyer/buyer_dashboard.dart';
import '../transporter/transporter_dashboard.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';


class MainApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return _buildUserSpecificHome(snapshot.data!.uid);
        } else {
          return WelcomeScreen();
        }
      },
    );
  }

  Widget _buildUserSpecificHome(String uid) {
    return FutureBuilder<AppUser?>(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            ),
          );
        }

        final user = snapshot.data;
        
        if (user == null) {
          return PhoneAuthScreen();
        }

        switch (user.userType) {
          case UserType.farmer:
            return FarmerDashboard(user: user);
          case UserType.buyer:
            return BuyerDashboard(user: user);
          case UserType.transporter:
            return TransporterDashboard(user: user);
          case UserType.storageOwner:
            return StorageOwnerDashboard(user: user);
          default:
            return FarmerDashboard(user: user);
        }
      },
    );
  }
}

// Placeholder for Storage Owner Dashboard
class StorageOwnerDashboard extends StatelessWidget {
  final AppUser user;
  
  const StorageOwnerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage Owner Dashboard'),
      ),
      body: Center(
        child: Text('Storage Owner View for ${user.displayName}'),
      ),
    );
  }
}