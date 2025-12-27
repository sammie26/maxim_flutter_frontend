import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/card_placeholder.dart';
import '../../widgets/step_header.dart';

class StepCardScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final int currentStep;
  final int totalSteps;

  const StepCardScreen({
    required this.onNext,
    required this.onBack,
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  @override
  State<StepCardScreen> createState() => _StepCardScreenState();
}

class _StepCardScreenState extends State<StepCardScreen> {
  late PageController _pageController;
  final int _initialPage = 1;
  double _currentPage = 1.0;

  final List<String> cardImagePaths = const [
    'lib/assets/card_dark.png',
    'lib/assets/card_orange.png',
    'lib/assets/card_pink.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: _initialPage,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _pageController.initialPage.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCardList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.75;
    const double maxScale = 1.0;
    const double minScale = 0.85;

    final baseCardHeight = cardWidth / CardPlaceholder.aspectRatio;
    final maxRequiredHeight = baseCardHeight * maxScale;

    return SizedBox(
      height: maxRequiredHeight + 10.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: cardImagePaths.length,
        itemBuilder: (context, index) {
          final double difference = (index - _currentPage).abs();
          final double scale = (maxScale - (difference * 0.15)).clamp(minScale, maxScale);
          final double opacity = (1.0 - (difference * 0.4)).clamp(0.6, 1.0);

          return Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: CardPlaceholder(
                    cardWidth: cardWidth,
                    isWelcome: false,
                    imagePath: cardImagePaths[index],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Back Button and Step Counter
            Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack, // Uses callback from WelcomeScreen
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Step ${widget.currentStep}/${widget.totalSteps}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Step Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: StepHeader(
                title: 'Choose a Card',
                subtitle: 'Pick the design for your virtual wallet.',
                currentStep: widget.currentStep,
                totalSteps: widget.totalSteps,
              ),
            ),

            const SizedBox(height: 30),

            // 3. Card Selection Carousel
            _buildCardList(context),

            const Spacer(),

            // 4. Primary Button
            Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 40.0),
              child: PrimaryButton(
                text: 'Finish',
                onPressed: widget.onNext, // Uses callback to go to /home
              ),
            ),
          ],
        ),
      ),
    );
  }
}