import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
// Assuming your AppColors are in this path
import '../../../theme/app_theme.dart'; 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  PreferredSizeWidget _buildAuthAppBar(BuildContext context) {
    // Standard back-button-only AppBar
    return AppBar(
      backgroundColor: AppColors.kLightBackground,
      elevation: 0,
      title: const Text(
        'Login',
        style: TextStyle(
          color: AppColors.kDarkBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded), // Use a close button for dismissive auth flow
        color: AppColors.kDarkBackground,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Helper for consistent text field styling
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.kHostAccentColor),
      labelStyle: const TextStyle(color: AppColors.kDullTextColor),
      filled: true,
      fillColor: AppColors.kAccentWhite,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.kProgressColor, width: 2),
      ),
    );
  }

  // Placeholder function for actual login logic
  void _performLogin(BuildContext context) {
    // In a real app: call API, validate form, check credentials, and navigate to MainScreen
    
    // Simulate successful login and dismiss the login screens
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login successful! Navigating to dashboard...'),
        backgroundColor: AppColors.kProgressColor,
        duration: Duration(seconds: 2),
      ),
    );

    // In a complete app, you would replace the entire navigation stack here 
    // to go to the main application screen (Home/Dashboard).
    // For this flow, we'll just close the current screen:
    Navigator.of(context).pushNamed('/summary'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      appBar: _buildAuthAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Access Your Account',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.kDarkBackground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your registered email or phone and password to continue.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.kDullTextColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 40),

            // Email/Phone Input
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.kDarkBackground),
              decoration: _inputDecoration(
                'Email or Phone Number',
                Icons.person_outline,
              ),
            ),
            const SizedBox(height: 20),

            // Password Input
            TextFormField(
              obscureText: true,
              style: const TextStyle(color: AppColors.kDarkBackground),
              decoration: _inputDecoration(
                'Password',
                Icons.lock_outline,
              ),
            ),
            const SizedBox(height: 10),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forgot Password flow initiated...'),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.kProgressColor, // Use accent color for links
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Login Button
            PrimaryButton(
              text: 'Login to Maxim',
              onPressed: () => _performLogin(context),
              
            ),
          ],
        ),
      ),
    );
  }
}