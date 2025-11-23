// lib/screens/auth/registration_screen.dart
import 'package:agrilink/models/location_model.dart';
import 'package:agrilink/models/user_model.dart';
import 'package:agrilink/screens/onboarding/profile_setup_screen.dart';
import 'package:agrilink/services/auth_service.dart';
import 'package:agrilink/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter, FilteringTextInputFormatter;
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import 'login_screen.dart';

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
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _checkingAccount = false;
  final _formKey = GlobalKey<FormState>();

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
        child: Form(
          key: _formKey,
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
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
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
                  hintText: '712 345 678',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 9) {
                    return 'Please enter a valid 9-digit number';
                  }
                  if (!value.startsWith(RegExp(r'[17]'))) {
                    return 'Please enter a valid Kenyan number';
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
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  if (_checkingAccount)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Checking account availability...',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    CustomButton(
                      text: _isLoading ? 'Creating Account...' : 'Create Account',
                      onPressed: _isLoading ? null : _checkAccountAndCreate,
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
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

  Future<void> _checkAccountAndCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _checkingAccount = true);

    try {
      // Check if phone number already exists
      final phoneNumber = '+254${_phoneController.text.replaceAll(' ', '')}';
      final phoneExists = await _userService.checkPhoneNumberExists(phoneNumber);
      
      if (phoneExists) {
        setState(() => _checkingAccount = false);
        _showAccountExistsDialog(
          'Phone Number Already Registered',
          'The phone number ${_phoneController.text} is already registered. Please sign in instead.',
        );
        return;
      }

      // Check if email already exists (if provided)
      if (_emailController.text.isNotEmpty) {
        final emailExists = await _userService.checkEmailExists(_emailController.text);
        
        if (emailExists) {
          setState(() => _checkingAccount = false);
          _showAccountExistsDialog(
            'Email Already Registered',
            'The email ${_emailController.text} is already registered. Please sign in instead.',
          );
          return;
        }
      }

      // If no existing account found, proceed with account creation
      setState(() {
        _checkingAccount = false;
        _isLoading = true;
      });

      await _createAccount();

    } catch (e) {
      setState(() {
        _checkingAccount = false;
        _isLoading = false;
      });
      Helpers.showSnackBar(context, 'Error checking account: $e', isError: true);
    }
  }

  void _showAccountExistsDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            child: Text('Sign In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    try {
      // Generate user ID
      final String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Format phone number with country code
      final formattedPhone = '+254${_phoneController.text.replaceAll(' ', '')}';
      
      // Create user object
      final user = AppUser(
        uid: userId,
        phoneNumber: formattedPhone,
        userType: widget.userType,
        displayName: _nameController.text.trim(),
        email: _emailController.text.isNotEmpty ? _emailController.text.trim() : null,
        county: widget.county,
        location: Location(
          latitude: -1.2921, // Default Nairobi coordinates
          longitude: 36.8219,
          address: '${widget.ward}, ${widget.subCounty}, ${widget.county}',
          county: widget.county,
          subCounty: widget.subCounty,
          ward: widget.ward,
        ),
        createdAt: DateTime.now(),
        isProfileComplete: false, // Set to false as they need to complete profile
        profileImageUrl: null,
      );

      // Save user to database
      await _userService.createUser(user);

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
      Helpers.showSnackBar(context, 'Failed to create account: $e', isError: true);
    }
  }
}