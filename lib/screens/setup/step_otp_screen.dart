// import 'package:flutter/material.dart';
// import '../../widgets/primary_button.dart';
// import '../../widgets/step_header.dart';
// // Import the new combined input widget
// import '../../widgets/five_digit_otp_input.dart'; 
// import '../../services/auth_service.dart';

// class StepOtpScreen extends StatefulWidget {
//   final VoidCallback onNext;
//   final VoidCallback onBack;
//   final int currentStep;
//   final int totalSteps;
//   final String email;

//   const StepOtpScreen({
//     required this.onNext,
//     required this.onBack,
//     required this.currentStep,
//     required this.totalSteps,
//     required this.email,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<StepOtpScreen> createState() => _StepOtpScreenState();
// }

// class _StepOtpScreenState extends State<StepOtpScreen> {
  
//   final AuthService _authService = AuthService();
//   String _otpCode = ''; // Stores the 5-digit OTP
//   bool _isLoading = false;
//   String? _errorMessage;
//   final int _expectedLength = 5; // Define 5 digits here

//   // This is the function called by the FiveDigitOtpInput manager
//   void _onOtpChanged(String otp) {
//     setState(() {
//       _otpCode = otp;
//       _errorMessage = null; 
//     });
//   }

//   void _handleContinue() async {
//     if (_isLoading) return;

//     // 5-Digit Validation Check
//     if (_otpCode.length != _expectedLength) {
//       setState(() {
//         _errorMessage = "Please enter the full $_expectedLength-digit code.";
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       var result = await _authService.verifyOtp(widget.email, _otpCode);
      
//       if (result['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(result['message'])),
//         );
//         widget.onNext(); 
//       } else {
//         setState(() {
//           _errorMessage = result['error'] ?? 'Invalid code. Please try again.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Connection failed. Check your network or server status.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
    
//     final VoidCallback onPressedCallback = _isLoading 
//         ? () {}
//         : _handleContinue;
        
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ... (Navigation and StepHeader remain the same)
//               Row(
//                 children: [
//                   IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
//                   const SizedBox(width: 8),
//                   Text('Step ${widget.currentStep}/${widget.totalSteps}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               StepHeader(
//                 title: 'Enter OTP',
//                 subtitle: 'Enter the $_expectedLength-digit password sent to ${widget.email}',
//                 currentStep: widget.currentStep,
//                 totalSteps: widget.totalSteps,
//               ),
//               const SizedBox(height: 32),
              
//               // ➡️ Use the new self-contained input widget here
//               FiveDigitOtpInput(
//                 onOtpChanged: _onOtpChanged, // Passes the state function to the manager
//               ),
              
//               // Error Message Display
//               if (_errorMessage != null) 
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.0),
//                   child: Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
                
//               const Spacer(),
              
//               // Primary Button
//               PrimaryButton(
//                 text: _isLoading ? 'Verifying...' : 'Continue', 
//                 onPressed: onPressedCallback,
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }