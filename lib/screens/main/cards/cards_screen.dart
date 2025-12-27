import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maxim___frontend/models/card.dart';
import 'package:maxim___frontend/services/card_service.dart';
import 'package:maxim___frontend/providers/auth_provider.dart';
import 'package:maxim___frontend/screens/shared/appbar_expanded.dart';
import 'package:maxim___frontend/theme/app_theme.dart';
import 'card_details_screen.dart';

const double kCardHeight = 220.0;
const double kStackOffset = 45.0;

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int? _selectedCardIndex;
  late Future<List<CardData>> _cardsFuture;
  final CardService _cardService = CardService();

  @override
  void initState() {
    super.initState();
    _refreshCards();
  }

  // 🔄 Function to trigger a fresh fetch from the database
  void _refreshCards() {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    _cardsFuture = _cardService.fetchUserCards(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      body: Column(
        children: [
          AppBarExpanded("Cards"),
          Expanded(
            child: FutureBuilder<List<CardData>>(
              future: _cardsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final cards = snapshot.data!;
                return Column(
                  children: [
                    _buildContentHeader(),
                    _buildCardStack(cards),
                    _buildBottomActionButtons(context, cards),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _selectedCardIndex == null ? 'My Cards' : 'Card Selected',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkBackground,
          ),
        ),
      ),
    );
  }

  // 🏗️ The Dynamic Stack Logic
  Widget _buildCardStack(List<CardData> cards) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topCenter,
        children: cards.asMap().entries.map((entry) {
          final int index = entry.key;
          final CardData card = entry.value;

          return _CardDisplay(
            imageUrl: card.imagePath, // ✅ Dynamically mapped from DB color
            index: index,
            totalCards: cards.length,
            selectedCardIndex: _selectedCardIndex,
            onTap: () {
              setState(() {
                _selectedCardIndex = (_selectedCardIndex == index) ? null : index;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context, List<CardData> cards) {
    final bool hasSelection = _selectedCardIndex != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: GestureDetector(
        onTap: () {
          if (hasSelection) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardDetailsScreen(card: cards[_selectedCardIndex!]),
              ),
            );
          } else {
            // Logic for linking a new card
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.kDarkBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              hasSelection ? 'View Card Details' : '+ Link New Card',
              style: const TextStyle(
                color: AppColors.kAccentWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("No cards found. Tap below to add one."),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text("❌ Error loading cards: $error"),
    );
  }
}

// ─── CARD DISPLAY (UI Remains the Same) ───────────────────────────────────

class _CardDisplay extends StatelessWidget {
  final String imageUrl;
  final int index;
  final int totalCards;
  final int? selectedCardIndex;
  final VoidCallback onTap;

  const _CardDisplay({
    required this.imageUrl,
    required this.index,
    required this.totalCards,
    required this.selectedCardIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double top;
    double scale = 1.0;

    if (selectedCardIndex == null) {
      top = index * kStackOffset;
    } else if (index == selectedCardIndex) {
      top = 0;
    } else if (index < selectedCardIndex!) {
      top = index * 8;
      scale = 0.95;
    } else {
      top = kCardHeight + 30 + (index - selectedCardIndex!) * 20;
      scale = 0.9;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      top: top,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 400),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width - 32,
            height: kCardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.contain,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}