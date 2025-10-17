import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Send password reset email via Firebase
        final result = await _authService.sendPasswordResetEmail(
          _emailController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success']) {
            setState(() {
              _emailSent = true;
            });
            Navigator.pushNamed(context, '/login');
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXL),

          // Title
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: AppConstants.fontXXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Subtitle
          const Text(
            'Don\'t worry! It happens. Please enter the email address associated with your account.',
            style: TextStyle(
              fontSize: AppConstants.fontM,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingXL),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.paddingXL),

          // Submit Button
          CustomButton(
            text: 'Send Reset Link',
            onPressed: _isLoading ? null : _sendResetLink,
            isLoading: _isLoading,
          ),
          const SizedBox(height: AppConstants.paddingL),

          // Back to Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Remember your password? ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.paddingXXL),

        // Success Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 60,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXL),

        // Success Title
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: AppConstants.fontXXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingM),

        // Success Message
        Text(
          'We have sent a password reset link to\n${_emailController.text}',
          style: const TextStyle(
            fontSize: AppConstants.fontM,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingXL),

        // Instructions Card
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.info, size: AppConstants.iconM),
                  const SizedBox(width: AppConstants.paddingS),
                  const Text(
                    'What\'s next?',
                    style: TextStyle(
                      fontSize: AppConstants.fontL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingM),
              _buildInstructionStep('1', 'Check your email inbox'),
              _buildInstructionStep('2', 'Click the reset link in the email'),
              _buildInstructionStep('3', 'Create a new password'),
              _buildInstructionStep('4', 'Login with your new password'),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingXL),

        // Resend Button
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Resend Email'),
        ),
        const SizedBox(height: AppConstants.paddingM),

        // Back to Login Button
        CustomButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: AppConstants.paddingL),

        // Didn't receive email?
        Center(
          child: TextButton(
            onPressed: () {
              _showHelpDialog();
            },
            child: const Text('Didn\'t receive the email?'),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: AppConstants.fontS,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.fontM,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('If you didn\'t receive the email, please:'),
            SizedBox(height: AppConstants.paddingM),
            Text('• Check your spam/junk folder'),
            Text('• Verify the email address is correct'),
            Text('• Wait a few minutes and try again'),
            Text('• Contact support if the issue persists'),
            SizedBox(height: AppConstants.paddingM),
            Text(
              'Support: support@mamaapp.com',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Contact support feature coming soon')),
              );
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}
