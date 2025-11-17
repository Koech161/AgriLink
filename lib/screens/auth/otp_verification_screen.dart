// lib/screens/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _setupOTPListeners();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  void _setupOTPListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < _otpControllers.length - 1) {
          _focusNodes[i + 1].requestFocus();
        }
        
        // Auto-submit when all fields are filled
        if (_isOTPComplete() && !_isLoading) {
          _verifyOTP();
        }
      });
    }
  }

  bool _isOTPComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOTP() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Illustration
              Container(
                height: 150,
                child: Icon(
                  Icons.sms,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
              ),
              
              SizedBox(height: 40),
              
              // Title
              Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: 12),
              
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              
              SizedBox(height: 4),
              
              Text(
                '+254 ${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              
              SizedBox(height: 40),
              
              // OTP Input Fields
              _buildOTPInputFields(),
              
              SizedBox(height: 24),
              
              // Countdown & Resend
              _buildResendSection(),
              
              SizedBox(height: 40),
              
              // Verify Button
              CustomButton(
                text: _isLoading ? 'Verifying...' : 'Verify Code',
                onPressed: _isLoading ? null : _verifyOTP,
                backgroundColor: _isLoading || !_isOTPComplete() 
                    ? Colors.grey 
                    : AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              
              SizedBox(height: 24),
              
              // Help Text
              Text(
                'Didn\'t receive the code? Check your SMS messages or request a new code',
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
    );
  }

  Widget _buildOTPInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _otpControllers[index].text.isNotEmpty 
                  ? AppColors.primaryGreen 
                  : Colors.grey.shade300,
              width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
            ),
            boxShadow: [
              if (_otpControllers[index].text.isNotEmpty)
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code? ',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        if (_countdown > 0)
          Text(
            'Resend in $_countdown',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          TextButton(
            onPressed: _isResending ? null : _resendCode,
            child: Text(
              _isResending ? 'Resending...' : 'Resend Code',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // In lib/screens/auth/otp_verification_screen.dart
// Update the _verifyOTP method:

Future<void> _verifyOTP() async {
  if (!_isOTPComplete()) {
    Helpers.showSnackBar(context, 'Please enter the complete 6-digit code');
    return;
  }

  setState(() => _isLoading = true);

  try {
    // REAL OTP VERIFICATION
    final userCredential = await _authService.signInWithOTP(
      widget.verificationId,
      _getOTP(),
    );
    
    print('✅ OTP verified successfully! User: ${userCredential.user?.uid}');
    
    Helpers.showSnackBar(context, 'Successfully verified!');
    
    // Check if user has a profile in Firestore
    final appUser = await _authService.getCurrentUser();
    
    if (appUser != null) {
      // User has profile, go to main app
      Navigator.pushNamedAndRemoveUntil(context, '/main-app', (route) => false);
    } else {
      // User authenticated but no profile, go to role selection
      Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
    }
    
  } catch (e) {
    print('❌ OTP verification error: $e');
    Helpers.showSnackBar(context, 'Invalid verification code', isError: true);
  } finally {
    setState(() => _isLoading = false);
  }
}
  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
      _countdown = 60;
    });

    try {
      await _authService.verifyPhoneNumber(widget.phoneNumber);
      Helpers.showSnackBar(context, 'Verification code resent');
      _startCountdown();
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to resend code: $e', isError: true);
    } finally {
      setState(() => _isResending = false);
    }
  }
}