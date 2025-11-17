// lib/screens/onboarding/profile_setup_screen.dart
import 'package:agrilink/screens/common/main_app.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/crop_selection_chip.dart';
import '../../widgets/onboarding/progress_indicator.dart';
import '../../utils/constants.dart';
import '../../models/location_model.dart';
import '../../widgets/common/custom_button.dart';
import '../farmer/farmer_dashboard.dart';
import '../buyer/buyer_dashboard.dart';
import '../transporter/transporter_dashboard.dart';

class ProfileSetupScreen extends StatefulWidget {
  final AppUser user;
  final bool isEditing;

  // Remove const constructor to fix the error
  const ProfileSetupScreen({
    Key? key,
    required this.user,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  
  final _farmSizeController = TextEditingController();
  
  String? _profileImageUrl;
  bool _isLoading = false;
  List<CropType> _selectedCrops = [];
  
  // Available crops
  final List<CropType> _availableCrops = [
    CropType(
      name: 'Maize',
      icon: '🌽',
      code: 'maize',
      color: Colors.yellow.shade700,
      shelfLife: 180,
      category: 'Grains',
      seasons: ['Long Rains', 'Short Rains'],
    ),
    CropType(
      name: 'Tomatoes',
      icon: '🍅',
      code: 'tomatoes',
      color: Colors.red,
      shelfLife: 14,
      category: 'Vegetables',
      seasons: ['All Year'],
    ),
    CropType(
      name: 'Bananas',
      icon: '🍌',
      code: 'bananas',
      color: Colors.yellow.shade600,
      shelfLife: 7,
      category: 'Fruits',
      seasons: ['All Year'],
    ),
    CropType(
      name: 'Beans',
      icon: '🫘',
      code: 'beans',
      color: Colors.brown,
      shelfLife: 365,
      category: 'Legumes',
      seasons: ['Long Rains', 'Short Rains'],
    ),
    CropType(
      name: 'Potatoes',
      icon: '🥔',
      code: 'potatoes',
      color: Colors.brown.shade400,
      shelfLife: 90,
      category: 'Vegetables',
      seasons: ['Long Rains'],
    ),
    CropType(
      name: 'Coffee',
      icon: '☕',
      code: 'coffee',
      color: Colors.brown.shade800,
      shelfLife: 365,
      category: 'Cash Crops',
      seasons: ['Main Season'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _profileImageUrl = widget.user.profileImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Profile' : 'Complete Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (!widget.isEditing) ...[
              OnboardingProgressIndicator(currentStep: 4, totalSteps: 4),
              SizedBox(height: 32),
            ],
            
            Text(
              widget.isEditing ? 'Update Your Profile' : 'Almost There!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.isEditing 
                  ? 'Update your profile information'
                  : 'Add final details to complete your profile',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfilePhotoSection(),
                    SizedBox(height: 24),
                    
                    // User Info Display
                    _buildUserInfoSection(),
                    SizedBox(height: 24),
                    
                    // Farmer-specific fields
                    if (widget.user.userType == UserType.farmer) 
                      _buildFarmerSpecificFields(),
                  ],
                ),
              ),
            ),
            
            // Complete Setup Button
            CustomButton(
              text: _isLoading 
                  ? 'Saving...' 
                  : widget.isEditing ? 'Update Profile' : 'Complete Setup',
              onPressed: _isLoading ? null : _saveProfile,
              backgroundColor: _isLoading ? Colors.grey : AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.lightGreen,
              backgroundImage: _profileImageUrl != null
                  ? (_profileImageUrl!.startsWith('data:image/') 
                      ? MemoryImage(
                          base64Decode(_profileImageUrl!.split(',').last)
                        ) as ImageProvider
                      : NetworkImage(_profileImageUrl!))
                  : null,
              child: _profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primaryGreen,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: _pickProfileImage,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Profile Photo',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow('Name', widget.user.displayName),
          _buildInfoRow('Phone', widget.user.phoneNumber),
          if (widget.user.email != null) _buildInfoRow('Email', widget.user.email!),
          _buildInfoRow('Role', _getUserTypeText(widget.user.userType)),
          _buildInfoRow('Location', '${widget.user.location.ward}, ${widget.user.location.subCounty}, ${widget.user.location.county}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerSpecificFields() {
    return Column(
      children: [
        TextFormField(
          controller: _farmSizeController,
          decoration: InputDecoration(
            labelText: 'Farm Size (Acres)',
            prefixIcon: Icon(Icons.agriculture),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'e.g., 5',
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        
        // Crop Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Crops',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Select crops you grow (optional)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCrops.map((crop) {
                return CropSelectionChip(
                  crop: crop,
                  isSelected: _selectedCrops.contains(crop),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCrops.add(crop);
                      } else {
                        _selectedCrops.remove(crop);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  String _getUserTypeText(UserType userType) {
    switch (userType) {
      case UserType.farmer: return 'Farmer';
      case UserType.buyer: return 'Buyer';
      case UserType.transporter: return 'Transporter';
      case UserType.storageOwner: return 'Storage Owner';
      default: return 'User';
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isLoading = true);
        
        try {
          // Convert to base64 for web compatibility
          final bytes = await image.readAsBytes();
          final base64Image = base64Encode(bytes);
          final imageUrl = 'data:image/jpeg;base64,$base64Image';
          
          setState(() {
            _profileImageUrl = imageUrl;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to process image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      // Update user with additional profile information
      final updatedUser = widget.user.copyWith(
        profileImageUrl: _profileImageUrl,
        isProfileComplete: true,
      );

      // Save to Firestore - Use the method that exists in your AuthService
      // If createUserProfileWithoutAuth doesn't exist, use createUserProfile
      await _authService.createUserProfile(updatedUser);
      
      print('✅ Profile saved successfully for: ${updatedUser.displayName}');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing 
                ? 'Profile updated successfully!' 
                : 'Profile completed successfully!'
          ),
          backgroundColor: AppColors.success,
        ),
      );

      if (widget.isEditing) {
        // If editing, go back
        Navigator.pop(context);
      } else {
        // If new user, go to dashboard after a short delay
        await Future.delayed(Duration(milliseconds: 1500));
        _navigateToDashboard(updatedUser);
      }
      
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Profile save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDashboard(AppUser user) {
    switch (user.userType) {
      case UserType.farmer:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => FarmerDashboard(user: user)),
          (route) => false,
        );
        break;
      case UserType.buyer:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BuyerDashboard(user: user)),
          (route) => false,
        );
        break;
      case UserType.transporter:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TransporterDashboard(user: user)),
          (route) => false,
        );
        break;
      case UserType.storageOwner:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => StorageOwnerDashboard(user: user)),
          (route) => false,
        );
        break;
      default:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => FarmerDashboard(user: user)),
          (route) => false,
        );
    }
  }
}