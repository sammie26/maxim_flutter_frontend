// import 'package:flutter/material.dart';
// import '../../widgets/primary_button.dart';
// import '../../widgets/bank_tile.dart';
// import '../../widgets/step_header.dart';

// class StepAccountsScreen extends StatelessWidget {
//   final VoidCallback onNext;
//   final VoidCallback onBack;
//   final int currentStep;
//   final int totalSteps;

//   const StepAccountsScreen({
//     required this.onNext,
//     required this.onBack,
//     required this.currentStep,
//     required this.totalSteps,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final banks = ['CIB', 'Banque Misr', 'QNB'];

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
//                   const SizedBox(width: 8),
//                   Text('Step $currentStep/$totalSteps', style: const TextStyle(fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               StepHeader(
//                 title: 'Link your bank',
//                 subtitle: 'Choose your bank to connect',
//                 currentStep: currentStep,
//                 totalSteps: totalSteps,
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ListView(
//                   children: banks.map((name) => BankTile(name: name, logo: Icons.account_balance)).toList(),
//                 ),
//               ),
//               PrimaryButton(text: 'Continue', onPressed: onNext),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
