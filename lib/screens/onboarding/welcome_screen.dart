// lib/screens/onboarding/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Animation (fixed height so it behaves well on small screens)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.36,
                          child: Lottie.asset(
                            'assets/animations/farming.json',
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Content
                        Column(
                          children: [
                            Text(
                              'Welcome to AgriLink',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Connect with storage, transport, and buyers to reduce post-harvest losses and maximize your profits',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            _buildFeatureRow(
                              icon: Icons.warehouse,
                              text: 'Find nearby storage facilities',
                            ),
                            SizedBox(height: 12),
                            _buildFeatureRow(
                              icon: Icons.local_shipping,
                              text: 'Book reliable transport',
                            ),
                            SizedBox(height: 12),
                            _buildFeatureRow(
                              icon: Icons.shopping_cart,
                              text: 'Connect with verified buyers',
                            ),
                          ],
                        ),

                        // Action Buttons (stick to bottom via spaceBetween)
                        Column(
                          children: [
                            CustomButton(
                              text: 'Get Started',
                              onPressed: () {
                                Navigator.pushNamed(context, '/role-selection');
                              },
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}