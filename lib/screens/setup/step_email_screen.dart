// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../widgets/primary_button.dart';
// import '../../widgets/step_header.dart'; // <--- Retained import
// import '../../services/auth_service.dart'; // <--- New import for functionality

// class StepEmailScreen extends StatefulWidget {
//   // 1. CRITICAL FIX: The type of onNext must accept the email string.
//   final void Function(String email) onNext; 
//   final VoidCallback onBack;
//   final int currentStep;
//   final int totalSteps;

//   const StepEmailScreen({
//     required this.onNext,
//     required this.onBack,
//     required this.currentStep,
//     required this.totalSteps,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<StepEmailScreen> createState() => _StepEmailScreenState();
// }

// class _StepEmailScreenState extends State<StepEmailScreen> {
//   final TextEditingController emailController = TextEditingController();
//   String? errorMessage;
//   // New State for functionality
//   bool _isLoading = false; 
//   final AuthService _authService = AuthService(); // New service instance

//   /// Email validation using regex (Unchanged)
//   bool _isValidEmail(String email) {
//     final emailRegex = RegExp(
//       r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
//     );
//     return emailRegex.hasMatch(email);
//   }

//   // Merged _handleContinue with full async functionality
//   void _handleContinue() async {
//     // Prevent multiple clicks while loading
//     if (_isLoading) {
//       return;
//     }

//     final email = emailController.text.trim();
//     bool localError = false;

//     // 1. Local Validation Check
//     setState(() {
//       errorMessage = null;
//       if (email.isEmpty) {
//         errorMessage = "Email cannot be empty";
//         localError = true;
//       } else if (!_isValidEmail(email)) {
//         errorMessage = "Please enter a valid email address";
//         localError = true;
//       }
//     });

//     if (localError) {
//       return; 
//     }

//     // 2. Start Loading State
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // 3. API CALL: This is the new functionality
//       var result = await _authService.requestOtp(email);
      
//       if (result['success'] == true) {
//         // Show success message
//         if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(result['message'] ?? 'OTP sent successfully!')),
//             );
//         }
//         // 4. CRITICAL FIX: Pass the email string to the next step
//         widget.onNext(email); 
//       } else {
//         // Show API error
//         setState(() {
//           errorMessage = result['error'] ?? 'Failed to send OTP.';
//         });
//       }
//     } catch (e) {
//       // Handle network or server-side error
//       setState(() {
//         errorMessage = 'Network connection failed. Please check your server and URL.';
//       });
//     } finally {
//       // 5. Stop Loading State
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Back button + Step indicator (Unchanged)
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back),
//                       onPressed: widget.onBack,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Step ${widget.currentStep}/${widget.totalSteps}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // StepHeader (Unchanged)
//                 StepHeader(
//                   title: 'Enter Your Email',
//                   subtitle: 'Provide your email to continue',
//                   currentStep: widget.currentStep,
//                   totalSteps: widget.totalSteps,
//                 ),

//                 const SizedBox(height: 32),

//                 // EMAIL INPUT (Unchanged)
//                 TextField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//                     labelText: 'Email',
//                     labelStyle: const TextStyle(color: Colors.black54),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     errorText: errorMessage,
//                   ),
//                 ),

//                 const Spacer(),

//                 // PRIMARY BUTTON (Retains original structure, updates text/disabling)
//                 PrimaryButton(
//                   // Use the loading state for button text and to prevent multiple presses
//                   text: _isLoading ? 'Sending OTP...' : 'Send Verification Code',
//                   onPressed: _handleContinue, // Always call the handler
//                 ),

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }