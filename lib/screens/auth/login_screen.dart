// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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
                  height: 200,
                  child: Icon(
                    Icons.phone_iphone,
                    size: 100,
                    color: AppColors.primaryGreen,
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Title
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 12),
                
                Text(
                  'Sign in with your phone number',
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
                            _PhoneNumberFormatter(),
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
                  onPressed: _isLoading ? null : _sendOTP,
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
                
                // Demo Account Info
                _buildDemoInfo(),
                
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

  Widget _buildDemoInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, size: 16, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Demo Information',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'For testing, use any 9-digit number starting with 7. Firebase will send actual OTP codes.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _phoneController.text = '712345678';
              Helpers.showSnackBar(context, 'Demo number filled');
            },
            child: Text(
              'Tap to use demo number: 712345678',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOTP() async {
    // Get the raw digits only (remove any formatting)
    final rawPhoneNumber = _phoneController.text.replaceAll(' ', '');
    
    if (rawPhoneNumber.isEmpty || rawPhoneNumber.length != 9) {
      Helpers.showSnackBar(context, 'Please enter a valid 9-digit phone number');
      return;
    }

    // Validate Kenyan phone number format (starts with 7, 1, or 0)
    if (!_isValidKenyanNumber(rawPhoneNumber)) {
      Helpers.showSnackBar(context, 'Please enter a valid Kenyan phone number starting with 7');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Format the complete phone number with country code
      final completePhoneNumber = '+254$rawPhoneNumber';
      print('🔄 Starting phone verification for: $completePhoneNumber');
      
      // Send to AuthService with complete formatted number
      final verificationId = await _authService.verifyPhoneNumber(completePhoneNumber);
      
      if (verificationId != null) {
        print('✅ Verification code sent successfully to $completePhoneNumber');
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              verificationId: verificationId,
              phoneNumber: completePhoneNumber, // Pass complete number for display
            ),
          ),
        );
      } else {
        throw Exception('Failed to get verification ID');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ OTP sending error: $e');
      
      String errorMessage = 'Failed to send verification code';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-phone-number':
            errorMessage = 'Invalid phone number format. Please check and try again.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Please try again later';
            break;
          case 'quota-exceeded':
            errorMessage = 'SMS quota exceeded. Please try again later';
            break;
          default:
            errorMessage = 'Authentication error: ${e.message}';
        }
      }
      
      Helpers.showSnackBar(context, errorMessage, isError: true);
    }
  }

  bool _isValidKenyanNumber(String number) {
    // Kenyan numbers typically start with 7 (Safaricom, Airtel), 1 (Telkom), or 0
    final kenyanRegex = RegExp(r'^[17]\d{8}$');
    return kenyanRegex.hasMatch(number);
  }
}

// Custom formatter for phone number display (XXX XXX XXX)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Format as XXX XXX XXX
    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(newText[i]);
    }
    
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}






// // lib/screens/auth/login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../utils/constants.dart';
// import '../../utils/helpers.dart';
// import '../../widgets/common/custom_button.dart';
// import 'phone_auth_screen.dart';
// import 'otp_verification_screen.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   String _selectedAuthMethod = 'phone'; // 'phone' or 'email'
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0.0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light.copyWith(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: BouncingScrollPhysics(),
//             child: Container(
//               height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
//               child: Column(
//                 children: [
//                   // Header Section
//                   _buildHeaderSection(),
                  
//                   // Login Form
//                   Expanded(
//                     child: FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: SlideTransition(
//                         position: _slideAnimation,
//                         child: _buildLoginForm(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             AppColors.primaryGreen,
//             AppColors.secondaryGreen,
//           ],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Back Button
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
//                 onPressed: () => Navigator.pop(context),
//                 padding: EdgeInsets.zero,
//                 constraints: BoxConstraints(),
//               ),
//             ],
//           ),
          
//           SizedBox(height: 20),
          
//           // App Logo & Title
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.agriculture,
//               color: Colors.white,
//               size: 40,
//             ),
//           ),
          
//           SizedBox(height: 16),
          
//           Text(
//             'Welcome Back',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
          
//           SizedBox(height: 8),
          
//           Text(
//             'Sign in to continue to AgriLink',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white.withOpacity(0.8),
//             ),
//             textAlign: TextAlign.center,
//           ),
          
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoginForm() {
//     return Padding(
//       padding: EdgeInsets.all(32),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Auth Method Toggle
//             _buildAuthMethodToggle(),
//             SizedBox(height: 32),
            
//             // Login Form Fields
//             _selectedAuthMethod == 'phone' 
//                 ? _buildPhoneLoginForm()
//                 : _buildEmailLoginForm(),
            
//             SizedBox(height: 24),
            
//             // Forgot Password
//             if (_selectedAuthMethod == 'email') 
//               _buildForgotPassword(),
            
//             SizedBox(height: 32),
            
//             // Login Button
//             _buildLoginButton(),
            
//             SizedBox(height: 24),
            
//             // Divider
//             _buildDivider(),
            
//             SizedBox(height: 24),
            
//             // Alternative Login Options
//             _buildAlternativeLoginOptions(),
            
//             Spacer(),
            
//             // Sign Up Link
//             _buildSignUpLink(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAuthMethodToggle() {
//     return Container(
//       padding: EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppColors.lightGreen,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               decoration: BoxDecoration(
//                 color: _selectedAuthMethod == 'phone' 
//                     ? AppColors.primaryGreen 
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextButton(
//                 onPressed: () => setState(() => _selectedAuthMethod = 'phone'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: _selectedAuthMethod == 'phone' 
//                       ? Colors.white 
//                       : AppColors.textSecondary,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.phone_iphone, size: 18),
//                     SizedBox(width: 8),
//                     Text('Phone'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               decoration: BoxDecoration(
//                 color: _selectedAuthMethod == 'email' 
//                     ? AppColors.primaryGreen 
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextButton(
//                 onPressed: () => setState(() => _selectedAuthMethod = 'email'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: _selectedAuthMethod == 'email' 
//                       ? Colors.white 
//                       : AppColors.textSecondary,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.email, size: 18),
//                     SizedBox(width: 8),
//                     Text('Email'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPhoneLoginForm() {
//     return Column(
//       children: [
//         TextFormField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           style: TextStyle(fontSize: 16),
//           decoration: InputDecoration(
//             labelText: 'Phone Number',
//             hintText: '7XX XXX XXX',
//             prefixIcon: Icon(Icons.phone_iphone, color: AppColors.primaryGreen),
//             prefix: Padding(
//               padding: EdgeInsets.only(right: 8),
//               child: Text(
//                 '+254',
//                 style: TextStyle(
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter your phone number';
//             }
//             if (value.length != 9) {
//               return 'Please enter a valid 9-digit number';
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 16),
//         Text(
//           'We\'ll send you a verification code via SMS',
//           style: TextStyle(
//             color: AppColors.textSecondary,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmailLoginForm() {
//     return Column(
//       children: [
//         TextFormField(
//           controller: _emailController,
//           keyboardType: TextInputType.emailAddress,
//           style: TextStyle(fontSize: 16),
//           decoration: InputDecoration(
//             labelText: 'Email Address',
//             hintText: 'your@email.com',
//             prefixIcon: Icon(Icons.email, color: AppColors.primaryGreen),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter your email';
//             }
//             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//               return 'Please enter a valid email';
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 16),
//         TextFormField(
//           controller: _passwordController,
//           obscureText: _obscurePassword,
//           style: TextStyle(fontSize: 16),
//           decoration: InputDecoration(
//             labelText: 'Password',
//             hintText: 'Enter your password',
//             prefixIcon: Icon(Icons.lock, color: AppColors.primaryGreen),
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                 color: AppColors.textSecondary,
//               ),
//               onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter your password';
//             }
//             if (value.length < 6) {
//               return 'Password must be at least 6 characters';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildForgotPassword() {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: TextButton(
//         onPressed: () {
//           _showForgotPasswordDialog();
//         },
//         child: Text(
//           'Forgot Password?',
//           style: TextStyle(
//             color: AppColors.primaryGreen,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginButton() {
//     return CustomButton(
//       text: _isLoading ? 'Signing In...' : 'Sign In',
//       onPressed: _isLoading ? null : _handleLogin,
//       backgroundColor: AppColors.primaryGreen,
//       foregroundColor: Colors.white,
//       icon: _isLoading 
//           ? SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             )
//           : Icon(Icons.arrow_forward_rounded, size: 20),
//     );
//   }

//   Widget _buildDivider() {
//     return Row(
//       children: [
//         Expanded(
//           child: Divider(color: Colors.grey.shade300),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'Or continue with',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 12,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Divider(color: Colors.grey.shade300),
//         ),
//       ],
//     );
//   }

//   Widget _buildAlternativeLoginOptions() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _SocialLoginButton(
//           icon: Icons.fingerprint,
//           label: 'Biometric',
//           onPressed: () => _handleBiometricLogin(),
//         ),
//         SizedBox(width: 16),
//         _SocialLoginButton(
//           icon: Icons.phone,
//           label: 'USSD',
//           onPressed: () => _showUSSDLoginDialog(),
//         ),
//         SizedBox(width: 16),
//         _SocialLoginButton(
//           icon: Icons.qr_code,
//           label: 'QR Code',
//           onPressed: () => _handleQRLogin(),
//         ),
//       ],
//     );
//   }

//   Widget _buildSignUpLink() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Don\'t have an account? ',
//           style: TextStyle(
//             color: AppColors.textSecondary,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             // Navigate to sign up screen
//             Navigator.pushNamed(context, '/role-selection');
//           },
//           child: Text(
//             'Sign Up',
//             style: TextStyle(
//               color: AppColors.primaryGreen,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       // Simulate API call
//       await Future.delayed(Duration(seconds: 2));

//       if (_selectedAuthMethod == 'phone') {
//         // Navigate to OTP verification
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OTPVerificationScreen(
//               verificationId: 'mock_verification_id',
//               phoneNumber: _phoneController.text,
//             ),
//           ),
//         );
//       } else {
//         // Handle email login
//         Helpers.showSnackBar(context, 'Successfully signed in!');
//         // Navigate to main app
//         Navigator.pushNamedAndRemoveUntil(context, '/main-app', (route) => false);
//       }
//     } catch (e) {
//       Helpers.showSnackBar(context, 'Login failed: $e', isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _handleBiometricLogin() async {
//     try {
//       setState(() => _isLoading = true);
      
//       // Simulate biometric authentication
//       await Future.delayed(Duration(seconds: 1));
      
//       final success = await _showBiometricDialog();
      
//       if (success) {
//         Helpers.showSnackBar(context, 'Biometric authentication successful!');
//         Navigator.pushNamedAndRemoveUntil(context, '/main-app', (route) => false);
//       }
//     } catch (e) {
//       Helpers.showSnackBar(context, 'Biometric authentication failed', isError: true);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _handleQRLogin() async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('QR Code Login'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//                 height: 150,
//                 child: Icon(
//                   Icons.qr_code_scanner,
//                   size: 80,
//                   color: AppColors.primaryGreen,
//                 ),
//               ),
//             SizedBox(height: 16),
//             Text('Scan QR code with your AgriLink mobile app to login'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Helpers.showSnackBar(context, 'QR code scanning initiated');
//             },
//             child: Text('Scan'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryGreen,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricDialog() async {
//     return await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Biometric Authentication'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               height: 120,
//               child: Icon(
//                 Icons.fingerprint,
//                 size: 80,
//                 color: AppColors.primaryGreen,
//               ),
//             ),
//             SizedBox(height: 16),
//             Text('Use your fingerprint to login securely'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Authenticate'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryGreen,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }

//   void _showForgotPasswordDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Reset Password'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Enter your email to receive a password reset link'),
//             SizedBox(height: 16),
//             TextFormField(
//               decoration: InputDecoration(
//                 labelText: 'Email Address',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Helpers.showSnackBar(context, 'Password reset link sent!');
//             },
//             child: Text('Send Link'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryGreen,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showUSSDLoginDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('USSD Login'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Dial the following USSD code to login:'),
//             SizedBox(height: 16),
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.lightGreen,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     '*384*1234#',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryGreen,
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   IconButton(
//                     icon: Icon(Icons.content_copy, size: 18),
//                     onPressed: () {
//                       Clipboard.setData(ClipboardData(text: '*384*1234#'));
//                       Helpers.showSnackBar(context, 'USSD code copied to clipboard');
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'This will authenticate you using your mobile number',
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _launchUSSDCode();
//             },
//             child: Text('Dial Now'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryGreen,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _launchUSSDCode() {
//     // In a real app, you would launch the USSD dialer
//     Helpers.showSnackBar(context, 'Opening dialer with USSD code...');
//     // You can use url_launcher package to launch tel: URLs
//   }
// }

// // Social Login Button Widget
// class _SocialLoginButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onPressed;

//   const _SocialLoginButton({
//     Key? key,
//     required this.icon,
//     required this.label,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: OutlinedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, size: 18),
//         label: Text(label),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.textPrimary,
//           padding: EdgeInsets.symmetric(vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           side: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//     );
//   }
// }