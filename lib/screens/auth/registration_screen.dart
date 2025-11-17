// lib/screens/auth/registration_screen.dart
import 'package:agrilink/models/location_model.dart';
import 'package:agrilink/models/user_model.dart';
import 'package:agrilink/screens/onboarding/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import 'phone_auth_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final UserType userType;
  final String county;
  final String subCounty;
  final String ward;

  const RegistrationScreen({
    Key? key,
    required this.userType,
    required this.county,
    required this.subCounty,
    required this.ward,
  }) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Join AgriLink as a ${_getUserTypeText(widget.userType)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),

            // Location Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primaryGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.ward}, ${widget.subCounty}, ${widget.county}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Registration Form
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name*',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number*',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '0712 345 678',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 9) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Action Buttons
            Column(
              children: [
                CustomButton(
                  text: _isLoading ? 'Creating Account...' : 'Create Account',
                  onPressed: _isLoading ? null : _createAccount,
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navigate to phone verification for existing users
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhoneAuthScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getUserTypeText(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return 'Farmer';
      case UserType.buyer:
        return 'Buyer';
      case UserType.transporter:
        return 'Transporter';
      case UserType.storageOwner:
        return 'Storage Owner';
      default:
        return 'User';
    }
  }

  Future<void> _createAccount() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // For now, create account directly without phone verification
      // In production, you'd verify phone number first
      
      // Generate user ID
      final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create user object
      final user = AppUser(
        uid: userId,
        phoneNumber: _phoneController.text,
        userType: widget.userType,
        displayName: _nameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        county: widget.county,
        location: Location(
          latitude: -1.2921,
          longitude: 36.8219,
          address: '${widget.ward}, ${widget.subCounty}, ${widget.county}',
          county: widget.county,
          subCounty: widget.subCounty,
          ward: widget.ward,
        ),
        createdAt: DateTime.now(),
        isProfileComplete: true,
        profileImageUrl: null,
      );

      // Navigate to profile setup for additional details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSetupScreen(
            user: user,
            isEditing: false,
          ),
        ),
      );

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}