import 'package:flutter/material.dart';

// 1. Import your new Entry Point (The Keycloak Login Screen)
import 'screens/setup/welcome_screen.dart';

// 2. Import your Dashboard/Main Screens
import 'screens/main/cards/cards_screen.dart';
import 'screens/main/rewards/rewards_screen.dart';
import 'screens/main/summary/summary_screen.dart';
import 'screens/main/transactions/transactions_screen.dart';

class MaximApp extends StatelessWidget {
  const MaximApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maxim Finance',
      debugShowCheckedModeBanner: false,

      // --- Theme Configuration ---
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),

      // --- THE NEW ENTRY POINT ---
      // We start directly at the Welcome Screen.
      // There is no more 'skipSignup' or 'OnboardingFlow' needed here.
      home: const WelcomeScreen(),

      // --- ROUTES ---
      routes: {
        // This is the destination after a successful Keycloak login
        "/home": (ctx) => const SummaryScreen(),

        // Individual routes for navigation within the app
        "/summary": (ctx) => const SummaryScreen(), 
        "/cards": (ctx) => const CardsScreen(),
        "/transactions": (ctx) => const TransactionsScreen(),
        "/rewards": (ctx) => const RewardsScreen(),
      },
    );
  }
}