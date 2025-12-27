// import 'package:flutter/material.dart';
// import '../screens/setup/welcome_screen.dart';
// import '../screens/setup/step_email_screen.dart';
// import '../screens/setup/step_otp_screen.dart';
// import '../screens/setup/step_name_screen.dart';
// import '../screens/setup/step_accounts_screen.dart';
// import '../screens/setup/step_card_screen.dart';
// import 'onboarding_step.dart';
// import '../screens/setup/login_screen.dart';

// class OnboardingFlow extends StatefulWidget {
//   // NEW: Add a callback for when the entire flow is complete.
//   // This could navigate to the main app dashboard.
//   final VoidCallback onFlowComplete;
  
//   // NEW: Add a callback for the login path
//   final VoidCallback onLoginPath;

//   const OnboardingFlow({
//     required this.onFlowComplete,
//     required this.onLoginPath,
//     super.key,
//   });

//   @override
//   State<OnboardingFlow> createState() => _OnboardingFlowState();
// }

// class _OnboardingFlowState extends State<OnboardingFlow> {
//   OnboardingStep _currentStep = OnboardingStep.welcome;
//   final int totalSteps = 5;

//   // State variable to persist the email address
//   String? _userEmail; 
  
//   // State variable to persist the user's name
//   // String? _userName; 

//   // MODIFIED _next function to accept an optional data payload (like email or name)
//   void _next({String? data}) {
//     setState(() {
//       switch (_currentStep) {
//         case OnboardingStep.welcome:
//           _currentStep = OnboardingStep.step1Email;
//           break;
//         case OnboardingStep.step1Email:
//           // CAPTURE DATA: Store the email
//           if (data != null) {
//             _userEmail = data;
//           }
//           _currentStep = OnboardingStep.step2OTP;
//           break;
//         case OnboardingStep.step2OTP:
//           _currentStep = OnboardingStep.step3Name;
//           break;
//         case OnboardingStep.step3Name:
//           // CAPTURE DATA: Store the user's name (Assuming StepNameScreen passes the name back)
//           if (data != null) {
//             // _userName = data;
//           }
//           _currentStep = OnboardingStep.step4Accounts;
//           break;
//         case OnboardingStep.step4Accounts:
//           _currentStep = OnboardingStep.step5Card;
//           break;

//         case OnboardingStep.step5Card:
//           // FINAL STEP: Execute the completion callback
//           widget.onFlowComplete();
//           break;
//       }
//     });
//   }

//   void _back() {
//     setState(() {
//       switch (_currentStep) {
//         case OnboardingStep.step1Email:
//           _currentStep = OnboardingStep.welcome;
//           break;
//         case OnboardingStep.step2OTP:
//           _currentStep = OnboardingStep.step1Email;
//           break;
//         case OnboardingStep.step3Name:
//           _currentStep = OnboardingStep.step2OTP;
//           break;
//         case OnboardingStep.step4Accounts:
//           _currentStep = OnboardingStep.step3Name;
//           break;
//         case OnboardingStep.step5Card:
//           _currentStep = OnboardingStep.step4Accounts;
//           break;
//         default:
//           break;
//       }
//     });
//   }

//   int get currentStepIndex {
//     switch (_currentStep) {
//       case OnboardingStep.step1Email:
//         return 1;
//       case OnboardingStep.step2OTP:
//         return 2;
//       case OnboardingStep.step3Name:
//         return 3;
//       case OnboardingStep.step4Accounts:
//         return 4;
//       case OnboardingStep.step5Card:
//         return 5;
//       default:
//         return 0;
//     }
//   }

//   // --- Login Handler ---
//   // This pushes the LoginScreen onto the navigation stack
//   void _navigateToLogin(BuildContext context) {
//     // We navigate using the standard Flutter Navigator here,
//     // which allows the user to dismiss the login screen and come back 
//     // to the WelcomeScreen/OnboardingFlow if they change their mind.
//     Navigator.of(context).push(
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget screen;

//     switch (_currentStep) {
//       case OnboardingStep.welcome:
//         screen = WelcomeScreen(
//           onGetStarted: () => _next(),
//           // Connects the "Have an account?" button to the login handler
//           onLogin: () => _navigateToLogin(context), 
//         );
//         break;

//       case OnboardingStep.step1Email:
//         screen = StepEmailScreen(
//           onNext: (email) => _next(data: email),
//           onBack: _back,
//           currentStep: currentStepIndex,
//           totalSteps: totalSteps,
//         );
//         break;

//       case OnboardingStep.step2OTP:
//       case OnboardingStep.step3Name:
//         if (_userEmail == null) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             setState(() {
//               _currentStep = OnboardingStep.step1Email;
//             });
//           });
//           screen = Container();
//         } else {
//           if (_currentStep == OnboardingStep.step2OTP) {
//             screen = StepOtpScreen(
//               onNext: () => _next(),
//               onBack: _back,
//               currentStep: currentStepIndex,
//               totalSteps: totalSteps,
//               email: _userEmail!, // Passing required email
//             );
//           } else { // OnboardingStep.step3Name
//             screen = StepNameScreen(
//               // Assuming StepNameScreen takes the name in its `onNext` callback,
//               // we need to update this to capture the name like we did with email.
//               // For now, keeping it simple:
//               onNext: () => _next(),
//               onBack: _back,
//               currentStep: currentStepIndex,
//               totalSteps: totalSteps,
//               email: _userEmail!, // Passing required email
//             );
//           }
//         }
//         break;

//       case OnboardingStep.step4Accounts:
//         screen = StepAccountsScreen(
//           onNext: () => _next(),
//           onBack: _back,
//           currentStep: currentStepIndex,
//           totalSteps: totalSteps,
//         );
//         break;

//       case OnboardingStep.step5Card:
//         screen = StepCardScreen(
//           // This button now triggers the completion callback
//           onNext: () => _next(), 
//           onBack: _back,
//           currentStep: currentStepIndex,
//           totalSteps: totalSteps,
//         );
//         break;
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         child: screen,
//       ),
//     );
//   }
// }