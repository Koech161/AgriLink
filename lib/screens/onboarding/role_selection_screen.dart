// lib/screens/onboarding/role_selection_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../widgets/onboarding/role_card.dart';
import '../../widgets/onboarding/progress_indicator.dart';
import  '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserType? _selectedRole;

  final List<Map<String, dynamic>> _roles = [
    {
      'type': UserType.farmer,
      'title': 'Farmer',
      'description': 'Sell your produce and find storage',
      'icon': Icons.agriculture,
      'color': AppColors.primaryGreen,
    },
    {
      'type': UserType.buyer,
      'title': 'Buyer',
      'description': 'Purchase fresh produce directly',
      'icon': Icons.shopping_basket,
      'color': Colors.orange,
    },
    {
      'type': UserType.transporter,
      'title': 'Transporter',
      'description': 'Help move produce to markets',
      'icon': Icons.local_shipping,
      'color': Colors.blue,
    },
    {
      'type': UserType.storageOwner,
      'title': 'Storage Owner',
      'description': 'Offer storage facilities to farmers',
      'icon': Icons.warehouse,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Select Your Role'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress Indicator
            OnboardingProgressIndicator(currentStep: 1, totalSteps: 4),
            SizedBox(height: 32),
            
            // Title
            Text(
              'How will you use AgriLink?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose the role that best describes you',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            
            // Role Selection Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  return RoleCard(
                    title: role['title'],
                    description: role['description'],
                    icon: role['icon'],
                    color: role['color'],
                    isSelected: _selectedRole == role['type'],
                    onTap: () {
                      setState(() {
                        _selectedRole = role['type'];
                      });
                    },
                  );
                },
              ),
            ),
            
            // Continue Button
            CustomButton(
              text: 'Continue',
              onPressed: _selectedRole != null
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/location',
                        arguments: _selectedRole,
                      );
                    }
                  : null,
              backgroundColor: _selectedRole != null
                  ? AppColors.primaryGreen
                  : Colors.grey,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}