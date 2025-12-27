import 'package:flutter/material.dart';

class CardPlaceholder extends StatelessWidget {
  final bool isWelcome;
  final double scale;
  final double cardWidth;
  final String imagePath; // NEW: Parameter to specify the card image

  // A standard card aspect ratio (approx 1.6:1)
  static const double aspectRatio = 1.58;

  const CardPlaceholder({
    this.isWelcome = false,
    this.scale = 1.0,
    required this.cardWidth,
    required this.imagePath, // NEW: Must be provided
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          imagePath, // Use the provided image path
          fit: BoxFit.cover,
          width: cardWidth,
          // Calculate height to maintain aspect ratio
          height: cardWidth / aspectRatio,
        ),
      ),
    );
  }
}
