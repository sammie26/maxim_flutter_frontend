import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/card_placeholder.dart';
import '../../services/auth_service.dart'; 
import 'step_card_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; 

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
  setState(() => _isLoading = true);


  final Map<String, dynamic>? authData = await _authService.login(context);

  if (mounted) {
    setState(() => _isLoading = false);

    if (authData != null) {
      // ✅ SUCCESS: We got a user!
      // authData should contain the 'sub' (Keycloak ID) and 'status' ('NEW' or 'EXISTING')
      final String keycloakId = authData['sub'];
      final String status = authData['status'];

      // 🎯 THE CRITICAL STEP: Save the ID to the global provider
      Provider.of<AuthProvider>(context, listen: false).setSession(keycloakId, authData);

      if (status == 'NEW') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StepCardScreen(
              currentStep: 1,
              totalSteps: 1,
              onNext: () => Navigator.pushReplacementNamed(context, '/home'),
              onBack: () => Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const WelcomeScreen())
              ),
            ),
          ),
        );
      } else {
        // If status is 'EXISTING', go straight to home
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardSize = screenWidth * 0.8;
    // Safely calculate height based on Aspect Ratio
    final cardHeight = cardSize / (CardPlaceholder.aspectRatio);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(150), 
                      bottomRight: Radius.circular(120),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF222222),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            SvgPicture.asset('lib/assets/Logo.svg', height: 35),
                            const SizedBox(height: 40),
                            const Text(
                              'One Account.\nEvery Bank.', 
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 44, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Sync every account you own.', 
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Flexible(
                  flex: 1, 
                  child: ColoredBox(color: Color(0xFFF0F0F0)),
                ),
              ],
            ),
            Positioned(
              top: screenHeight * 0.5 - cardHeight / 2,
              left: (screenWidth - cardSize) / 2,
              child: Transform.rotate(
                angle: -0.2,
                child: CardPlaceholder(
                  isWelcome: true, 
                  cardWidth: cardSize, 
                  imagePath: 'lib/assets/card_dark.png',
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : Column(
                    children: [
                      PrimaryButton(
                        text: 'Get Started', 
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: _handleLogin, 
                        child: const Text(
                          'Have an account?', 
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}