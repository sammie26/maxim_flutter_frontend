// tier_page.dart

import 'package:flutter/material.dart';
import 'package:maxim___frontend/models/tier.dart';

import 'package:maxim___frontend/theme/app_theme.dart';

// MOCK USER XP
const int kUserCurrentXP = 2500;

final List<Tier> tiers = [
  Tier(
    name: 'Bronze',
    xpRequired: 0,
    xpPerPayment: 10,
    color: AppColors.kBronze,
    icon: Icons.shield_outlined,
    features: ['Earn 10 XP per payment'],
  ),
  Tier(
    name: 'Silver',
    xpRequired: 1000,
    xpPerPayment: 25,
    color: AppColors.kSilver,
    icon: Icons.shield,
    features: ['Earn 25 XP per payment'],
  ),
  Tier(
    name: 'Gold',
    xpRequired: 2500,
    xpPerPayment: 40,
    color: AppColors.kGold,
    icon: Icons.workspace_premium,
    features: ['Earn 40 XP per payment', 'Unlock BNPL'],
  ),
  Tier(
    name: 'Platinum',
    xpRequired: 4500,
    xpPerPayment: 55,
    color: AppColors.kPlatinum,
    icon: Icons.auto_awesome,
    features: ['Earn 55 XP per payment', 'Increased BNPL limit'],
  ),
  Tier(
    name: 'Ascendant',
    xpRequired: 6500,
    xpPerPayment: 70,
    color: AppColors.kAscendant,
    icon: Icons.diamond_outlined,
    features: [
      'Earn 70 XP per payment',
      'Maximum BNPL limit',
      'Exclusive Ascendant badge',
    ],
  ),
];

class RewardsTierPage extends StatelessWidget {
  const RewardsTierPage({super.key});

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.kDarkBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.kAccentWhite,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        'Your Tier Status',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.kDarkBackground,
        ),
      ),
    );
  }

  Widget _buildTierCard(Tier tier, Tier currentTier) {
    final bool isCurrent = tier == currentTier;
    final bool unlocked = kUserCurrentXP >= tier.xpRequired;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kAccentWhite,
        borderRadius: BorderRadius.circular(18),
        border: isCurrent
            ? Border.all(color: tier.color, width: 3)
            : Border.all(
                color: AppColors.kDullTextColor.withValues(alpha: .15),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tier.icon, color: tier.color, size: 32),
              const SizedBox(width: 12),
              Text(
                tier.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCurrent) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tier.color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'CURRENT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Earn ${tier.xpPerPayment} XP per payment',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...tier.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: unlocked
                        ? tier.color
                        : AppColors.kDullTextColor.withValues(alpha: .4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Tier currentTier = tiers.lastWhere(
      (t) => kUserCurrentXP >= t.xpRequired,
      orElse: () => tiers.first,
    );

    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildTitle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: tiers
                    .map((t) => _buildTierCard(t, currentTier))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
