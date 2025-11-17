// lib/screens/auth/phone_auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import 'otp_verification_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Illustration
                Container(
                  height: 150,
                  child: Icon(
                    Icons.phone_android,
                    size: 80,
                    color: AppColors.primaryGreen,
                  ),
                ),
                                
                SizedBox(height: 40),
                
                // Title
                Text(
                  'Enter Your Phone Number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 12),
                
                Text(
                  'We\'ll send you a verification code to sign in',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40),
                
                // Phone Input
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Country Code
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('🇰🇪', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              '+254',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Phone Number Input
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: '7XX XXX XXX',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Helper Text
                Text(
                  'Enter your 9-digit Safaricom/Airtel/Telkom number',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Continue Button
                CustomButton(
                  text: _isLoading ? 'Sending Code...' : 'Continue',
                  onPressed: _isLoading ? null : _verifyPhoneNumber,
                  backgroundColor: _isLoading ? Colors.grey : AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  icon: _isLoading 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.arrow_forward, size: 20),
                ),
                
                SizedBox(height: 24),
                
                // Terms and Privacy
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Future<void> _verifyPhoneNumber() async {
  if (_phoneController.text.isEmpty || _phoneController.text.length != 9) {
    Helpers.showSnackBar(context, 'Please enter a valid 9-digit phone number');
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Format phone number
    String phoneNumber = _phoneController.text;
    
    print('🔄 Verifying phone number: $phoneNumber');
    
    final verificationId = await _authService.verifyPhoneNumber(phoneNumber);
    
    if (verificationId != null) {
      print('✅ Verification code sent successfully');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            verificationId: verificationId,
            phoneNumber: _phoneController.text,
          ),
        ),
      );
    }
  } catch (e) {
    print('❌ Phone verification error: $e');
    
    String errorMessage = 'Failed to send verification code';
    if (e.toString().contains('invalid-phone-number')) {
      errorMessage = 'Invalid phone number format';
    } else if (e.toString().contains('too-many-requests')) {
      errorMessage = 'Too many attempts. Please try again later.';
    }
    
    Helpers.showSnackBar(context, '$errorMessage: $e', isError: true);
  } finally {
    setState(() => _isLoading = false);
  }
}
}