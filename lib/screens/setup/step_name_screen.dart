// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../widgets/primary_button.dart';
// import '../../widgets/step_header.dart';
// import '../../services/auth_service.dart'; 

// class StepNameScreen extends StatefulWidget {
//   final VoidCallback onNext;
//   final VoidCallback onBack;
//   final int currentStep;
//   final int totalSteps;
//   final String email; 

//   const StepNameScreen({
//     required this.onNext,
//     required this.onBack,
//     required this.currentStep,
//     required this.totalSteps,
//     required this.email,
//     super.key,
//   });

//   @override
//   State<StepNameScreen> createState() => _StepNameScreenState();
// }

// class _StepNameScreenState extends State<StepNameScreen> {
//   final AuthService _authService = AuthService();

//   // --- 1. Added Phone Controller ---
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController(); 
//   final TextEditingController _passwordController = TextEditingController(); 
  
//   DateTime? _dateOfBirth;
//   bool _isLoading = false;
//   bool _isPasswordVisible = false;

//   void _doNothing() {} 
  
//   @override
//   void initState() {
//     super.initState();
//     _firstNameController.addListener(_updateState);
//     // --- 2. Listen to Phone changes for validation ---
//     _phoneController.addListener(_updateState);
//     _passwordController.addListener(_updateState);
//   }

//   void _updateState() => setState(() {});

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _phoneController.dispose(); // --- 3. Dispose Controller ---
//     _passwordController.dispose(); 
//     super.dispose();
//   }

//   // --- 4. Updated Validation Logic ---
//   bool get _isFormValid {
//     // Requires First Name, Valid Phone (11 digits), Password (min 8), and DOB
//     return _firstNameController.text.trim().isNotEmpty &&
//         _phoneController.text.length == 11 && // Egyptian numbers are 11 digits
//         _passwordController.text.length >= 8 && 
//         _dateOfBirth != null;
//   }
  
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000), 
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(), 
//     );
//     if (picked != null && picked != _dateOfBirth) {
//       setState(() {
//         _dateOfBirth = picked;
//       });
//     }
//   }

//   // Inside StepNameScreen (Profile Setup)

//   void _handleContinue() async {
//     if (!_isFormValid || _isLoading) return;

//     setState(() { _isLoading = true; });

//     final firstName = _firstNameController.text.trim();
//     final lastName = _lastNameController.text.trim();
//     final phone = _phoneController.text.trim();
//     final password = _passwordController.text;
//     final fullName = '$firstName ${lastName.isNotEmpty ? lastName : ''}'.trim();
    
//     try {
//       // API CALL: Only Sign Up (POST /api/auth/signup)
//       // We do NOT call requestOtp here anymore.
//       final result = await _authService.updateUserDetails(
//         widget.email, 
//         fullName, 
//         phone, 
//         _dateOfBirth!, 
//         password,
//       );

//       if (result['success'] == true) {
//         // Success: The backend has verified the OTP proof and created the user.
//         widget.onNext();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(result['error'] ?? 'Failed to create account.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Connection error. Check server.')),
//       );
//     }

//     setState(() { _isLoading = false; });
//   }

//   InputDecoration _inputDecoration({
//     required String hintText,
//     Widget? suffixIcon,
//     Widget? prefixIcon, // Added prefix capability
//   }) {
//     return InputDecoration(
//       hintText: hintText,
//       filled: true,
//       fillColor: Colors.grey.shade200,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       suffixIcon: suffixIcon,
//       prefixIcon: prefixIcon,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final VoidCallback buttonAction = (_isFormValid && !_isLoading) 
//         ? () => _handleContinue() 
//         : _doNothing; 

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: widget.onBack,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               StepHeader(
//                 title: "Complete Your Profile",
//                 subtitle: 'Just a few more details to set up your account.',
//                 currentStep: widget.currentStep,
//                 totalSteps: widget.totalSteps,
//               ),

//               const SizedBox(height: 32),

//               // First Name
//               TextField(
//                 controller: _firstNameController, 
//                 keyboardType: TextInputType.text,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), 
//                 ],
//                 decoration: _inputDecoration(hintText: 'First Name (Required)'),
//               ),
//               const SizedBox(height: 16),

//               // Last Name
//               TextField(
//                 controller: _lastNameController, 
//                 keyboardType: TextInputType.text,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), 
//                 ],
//                 decoration: _inputDecoration(hintText: 'Last Name (Optional)'),
//               ),
//               const SizedBox(height: 16),

//               // --- 7. New Phone Number Field ---
//               TextField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 // Restrict to digits only and max 11 chars (Egyptian standard)
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(11),
//                 ],
//                 decoration: _inputDecoration(
//                   hintText: 'Mobile Number (01xxxxxxxxx)',
//                   prefixIcon: const Icon(Icons.phone_android, color: Colors.grey),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Password
//               TextField(
//                 controller: _passwordController, 
//                 keyboardType: TextInputType.visiblePassword,
//                 obscureText: !_isPasswordVisible,
//                 decoration: _inputDecoration(
//                   hintText: 'Set a Password (Min 8 characters)',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                       color: Colors.grey.shade600,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 32),
              
//               // DOB Picker
//               GestureDetector(
//                 onTap: _isLoading ? null : () => _selectDate(context), 
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _dateOfBirth == null 
//                             ? 'Date of Birth (Required)'
//                             : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
//                         style: TextStyle(
//                           color: _dateOfBirth == null ? Colors.grey.shade600 : Colors.black,
//                         ),
//                       ),
//                       const Icon(Icons.calendar_today, size: 20),
//                     ],
//                   ),
//                 ),
//               ),

//               const Spacer(),

//               PrimaryButton(
//                 text: _isLoading 
//                     ? (_isFormValid ? 'Saving...' : 'Continue')
//                     : 'Continue',
//                 onPressed: buttonAction, 
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }