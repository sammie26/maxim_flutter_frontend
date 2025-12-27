import 'package:flutter/material.dart';
import 'package:maxim___frontend/screens/shared/appbar_expanded.dart';
import 'package:maxim___frontend/screens/main/rewards/rewards_tier_page.dart';
import 'package:maxim___frontend/screens/main/rewards/financial_insight_page.dart';
import '../../../theme/app_theme.dart';

// --- UTILITY SCREENS (for navigation placeholders) ---

class TierDetailsScreen extends StatelessWidget {
  const TierDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tier Details',
          style: TextStyle(color: AppColors.kDarkBackground),
        ),
        backgroundColor: AppColors.kLightBackground,
        iconTheme: const IconThemeData(color: AppColors.kDarkBackground),
        elevation: 0,
      ),
      body: const Center(child: Text('This is the detailed Tier page.')),
    );
  }
}

// NOTE: FinancialInsightScreen is replaced by FinancialInsightPage imported above
// This commented code is kept for context but is not active:
/*
class FinancialInsightScreen extends StatelessWidget {
  const FinancialInsightScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Insight',
          style: TextStyle(color: AppColors.kDarkBackground),
        ),
        backgroundColor: AppColors.kLightBackground,
        iconTheme: const IconThemeData(color: AppColors.kDarkBackground),
        elevation: 0,
      ),
      body: const Center(
        child: Text('This is the detailed Financial Insight page.'),
      ),
    );
  }
}
*/

// --- MOCK DATA MODELS ---

enum TierStatus { locked, current, unlocked }

class Tier {
  final int level;
  final String name;
  final String badgeIcon;
  final int xpRequired;
  final String rewardDescription;
  final TierStatus status;

  Tier({
    required this.level,
    required this.name,
    required this.badgeIcon,
    required this.xpRequired,
    required this.rewardDescription,
    this.status = TierStatus.locked,
  });
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final bool isUser;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    this.isUser = false,
  });
}

// --- MOCK DATA ---
final List<Tier> mockTiers = [
  Tier(
    level: 1,
    name: 'Bronze Starter',
    badgeIcon: 'star_outline',
    xpRequired: 0,
    rewardDescription: '1% Cashback on digital purchases.',
    status: TierStatus.unlocked,
  ),
  Tier(
    level: 2,
    name: 'Silver Achiever',
    badgeIcon: 'verified',
    xpRequired: 500,
    rewardDescription: '1.5% Cashback. + Higher daily transfer limit.',
    status: TierStatus.unlocked,
  ),
  Tier(
    level: 3,
    name: 'Gold BNPL Access',
    badgeIcon: 'workspace_premium',
    xpRequired: 1500,
    rewardDescription: 'Unlock Limited BNPL Reward (EGP 500 limit).',
    status: TierStatus.current,
  ),
  Tier(
    level: 4,
    name: 'Platinum',
    badgeIcon: 'diamond',
    xpRequired: 3000,
    rewardDescription: '2% Cashback. Exclusive financial coaching.',
    status: TierStatus.locked,
  ),
  Tier(
    level: 5,
    name: 'Diamond Master',
    badgeIcon: 'military_tech',
    xpRequired: 5000,
    rewardDescription: '3% Cashback. Dedicated wealth manager.',
    status: TierStatus.locked,
  ),
];

final List<LeaderboardEntry> mockLeaderboard = [
  LeaderboardEntry(rank: 1, name: 'Laila Sameh', xp: 4500),
  LeaderboardEntry(rank: 2, name: 'Omar Gaber', xp: 3200),
  LeaderboardEntry(rank: 3, name: 'You (Host)', xp: 1850, isUser: true),
  LeaderboardEntry(rank: 4, name: 'Sara Emad', xp: 1450),
  LeaderboardEntry(rank: 5, name: 'Khaled Fathi', xp: 900),
  LeaderboardEntry(rank: 6, name: 'Ahmad Hassan', xp: 400),
];

// --- STATEFUL WIDGET ---

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _currentXp = 1850; // User's current XP
  final Tier _currentTier = mockTiers[2]; // Level 3: Gold BNPL Access
  final Tier _nextTier = mockTiers[3]; // Level 4: Platinum Expert

  // NEW STATE: Track redemption status for unique reward IDs
  // Use a map to store the redemption status (true = redeemed)
  final Map<String, bool> _redeemedStatus = {
    'BNPLStarterReward': false,
    'RestaurantDiscount': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    if (_currentTier.level == mockTiers.last.level) return 1.0;

    final int xpNeededForNext = _nextTier.xpRequired - _currentTier.xpRequired;
    final int xpEarnedInCurrentTier = _currentXp - _currentTier.xpRequired;

    return xpEarnedInCurrentTier / xpNeededForNext;
  }

  // Placeholder for navigation to a blank page for the header icons
  void _navigateToBlankPage(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(color: AppColors.kDarkBackground),
            ),
            backgroundColor: AppColors.kLightBackground,
            iconTheme: const IconThemeData(color: AppColors.kDarkBackground),
            elevation: 0,
          ),
          body: Center(child: Text('You navigated to $title.')),
        ),
      ),
    );
  }

  // --- POPUP DIALOG FOR REDEEM REWARDS ---
  void _showRedeemPopup(
      BuildContext context, String rewardId, String title, String detail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.kDarkBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Redeem Confirmation',
                    style: TextStyle(
                      color: AppColors.kAccentWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.kAccentGrey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.kAccentGrey),
              const SizedBox(height: 16),

              // Reward Details
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.kAccentWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reward Detail: $detail',
                style: const TextStyle(
                  color: AppColors.kAccentGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Redemption Logic: Update the state map
                    if (rewardId.isNotEmpty && !_redeemedStatus[rewardId]!) {
                      setState(() {
                        _redeemedStatus[rewardId] = true;
                      });
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title redeemed successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kAccentWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Redeem',
                    style: TextStyle(
                      color: AppColors.kDarkBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // BUILD METHODS
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      body: Column(
        children: [
          AppBarExpanded("Rewards"),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildEarnRedeemView(), _buildLeaderboardView()],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- WIDGETS -------------------

  Widget _buildTabBar() {
    return Container(
      color: AppColors.kAccentWhite, // Ensure a solid background for the tabs
      child: TabBar(
        controller: _tabController,
        // New Indicator Style (Line underneath, theme-based)
        indicatorColor: AppColors.kDarkBackground,
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.kDarkBackground,
        unselectedLabelColor: AppColors.kDullTextColor.withValues(alpha: 0.8),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        tabs: const [
          Tab(text: 'Earn & Redeem'),
          Tab(text: 'Leaderboard'),
        ],
      ),
    );
  }

  // --- EARN & REDEEM VIEW (Summary) ---

  Widget _buildEarnRedeemView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildTierProgressCard(), // Contained logic for tier card
          const SizedBox(height: 40),
          _buildEarnSection(),
          const SizedBox(height: 40),
          _buildRedeemSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTierProgressCard() {
    final double progress = _calculateProgress();
    final int xpRemaining = _nextTier.xpRequired - _currentXp;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RewardsTierPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kAccentWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.kDullTextColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Tier: ${_currentTier.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kDarkBackground,
                  ),
                ),
                Icon(
                  _currentTier.badgeIcon == 'star_outline'
                      ? Icons.star_outline
                      : _currentTier.badgeIcon == 'verified'
                          ? Icons.verified
                          : _currentTier.badgeIcon == 'workspace_premium'
                              ? Icons.workspace_premium
                              : _currentTier.badgeIcon == 'diamond'
                                  ? Icons.diamond
                                  : Icons.military_tech,
                  color: AppColors.kHostAccentColor,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Themed Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.kLightBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.kProgressColor,
              ), // Theme color
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 10),

            Text(
              '$xpRemaining XP to reach ${_nextTier.name}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.kDullTextColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Themed reward description text
            Text(
              _currentTier.rewardDescription,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.kDarkBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earn XP & Cashback',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkBackground,
          ),
        ),
        const SizedBox(height: 16),
        // Made Financial Insight Card Tappable
        _buildEarnTaskCard(
          title: 'Financial Insight: Credit Scores',
          description:
              'Watch a 60-second video on credit score basics and take a quick quiz.',
          xpReward: '+100 XP',
          icon: Icons.school_outlined,
          color: AppColors.kDarkBackground,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FinancialInsightPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        // Themed Digital Purchase Bonus Card (no blue)
        _buildEarnTaskCard(
          title: 'Digital Purchase Bonus',
          description:
              'Make any digital payment (min. EGP 100) to earn 1% cashback and XP.',
          xpReward: 'Cashback + 50 XP',
          icon: Icons.shopping_bag_outlined,
          color: AppColors.kDarkBackground,
          onTap: () => _navigateToBlankPage(context, 'Digital Purchase'),
        ),
      ],
    );
  }

  Widget _buildEarnTaskCard({
    required String title,
    required String description,
    required String xpReward,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kAccentWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.kDullTextColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.kDarkBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.kDullTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              xpReward,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Redeem Rewards',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkBackground,
          ),
        ),
        const SizedBox(height: 16),

        // Themed BNPL Card
        _buildRedeemCard(
          rewardId: 'BNPLStarterReward', // Unique ID for state tracking
          title: 'BNPL Starter Reward',
          subtitle: 'Limited Credit Access',
          amount: 'EGP 500 Limit',
          isActive: _currentTier.level >= 3 && !_redeemedStatus['BNPLStarterReward']!, // Check redemption status
          icon: Icons.attach_money_rounded,
          // Use kDarkBackground if active/unredeemed, kDullTextColor if locked/redeemed
          color: _currentTier.level >= 3
              ? AppColors.kDarkBackground
              : AppColors.kDullTextColor,
          onTap: () => _showRedeemPopup(
            context,
            'BNPLStarterReward',
            'BNPL Starter Reward',
            'EGP 500 limit on first BNPL purchase.',
          ),
        ),
        const SizedBox(height: 12),

        // New Reward Placeholder: Restaurant Discount
        _buildRedeemCard(
          rewardId: 'RestaurantDiscount', // Unique ID for state tracking
          title: 'Restaurant Discount',
          subtitle: '15% off at all partner locations',
          amount: 'Redeem Now',
          isActive: !_redeemedStatus['RestaurantDiscount']!, // Check redemption status
          icon: Icons.restaurant_menu_rounded,
          color: AppColors.kDarkBackground,
          onTap: () => _showRedeemPopup(
            context,
            'RestaurantDiscount',
            'Restaurant Discount',
            'Redeem for a 15% discount code.',
          ),
        ),
        const SizedBox(height: 12),

        // New Reward Placeholder: Fee Waiver (Tier 4)
        _buildRedeemCard(
          rewardId: 'FeeWaiver', // Unique ID
          title: 'Transaction Fee Waiver',
          subtitle: 'Next Tier Reward: Waive monthly transaction fees.',
          amount: 'Upgrade',
          isActive: false,
          icon: Icons.swap_horiz_rounded,
          color: AppColors.kDullTextColor,
          onTap: () => _navigateToBlankPage(context, 'Fee Waiver Details'),
        ),
        const SizedBox(height: 12),

        // New Reward Placeholder: BNPL Tier 5 Access
        _buildRedeemCard(
          rewardId: 'AdvancedBNPL', // Unique ID
          title: 'Advanced BNPL Access',
          subtitle:
              'Tier 5 Exclusive: Increased credit limit and flexible terms.',
          amount: 'Coming Soon',
          isActive: false,
          icon: Icons.currency_exchange_rounded,
          color: AppColors.kDullTextColor,
          onTap: () => _navigateToBlankPage(context, 'Advanced BNPL Details'),
        ),
      ],
    );
  }

  Widget _buildRedeemCard({
    required String rewardId,
    required String title,
    required String subtitle,
    required String amount,
    required bool isActive,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Check if the reward has been redeemed
    final bool isRedeemed = _redeemedStatus[rewardId] ?? false;

    // 1. Conditional Text and Color Logic
    String displayAmount = amount;
    Color displayColor = color;
    double fontSize = 14; // Default font size for amount (smaller as requested)

    if (isRedeemed) {
      displayAmount = 'Redeemed';
      displayColor = AppColors.kDullTextColor; // Use the "disabled" color theme
    } else if (!isActive) {
      // If inactive (Upgrade/Coming Soon), use the dull color
      displayColor = AppColors.kDullTextColor;
    } 
    
    // If active and not redeemed, keep the original color
    if (isActive && !isRedeemed) {
      displayColor = color;
    }


    return GestureDetector(
      onTap: isActive && !isRedeemed ? onTap : () {}, // Only allow tap if active and not redeemed
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kAccentWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Use the determined displayColor for the border
            color: displayColor.withValues(alpha: 0.2), 
            width: 1
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: displayColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: displayColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      // Dim title if redeemed or inactive
                      color: (isRedeemed || !isActive) 
                          ? AppColors.kDullTextColor 
                          : AppColors.kDarkBackground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.kDullTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              displayAmount,
              style: TextStyle(
                // Use the determined font size and color
                fontSize: fontSize, 
                fontWeight: FontWeight.bold,
                color: displayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LEADERBOARD VIEW (Unchanged) ---

  Widget _buildLeaderboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 20, right: 20, bottom: 10),
          child: Text(
            'Top XP Earners',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.kDarkBackground,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: mockLeaderboard.length,
            itemBuilder: (context, index) {
              final entry = mockLeaderboard[index];
              return _buildLeaderboardEntry(entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry) {
    final Color rankColor = entry.rank == 1
        ? const Color(0xFFD4AF37)
        : entry.rank == 2
            ? const Color(0xFFAFAFAF)
            : entry.rank == 3
                ? const Color(0xFFCD7F32)
                : entry.isUser
                    ? AppColors.kProgressColor
                    : AppColors.kDullTextColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: entry.isUser
            ? AppColors.kProgressColor.withValues(alpha: 0.1)
            : AppColors.kAccentWhite,
        borderRadius: BorderRadius.circular(10),
        border: entry.isUser
            ? Border.all(color: AppColors.kProgressColor, width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Rank Indicator
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.isUser
                  ? AppColors.kProgressColor
                  : AppColors.kDarkBackground.withValues(alpha: 0.8),
            ),
            child: Icon(
              entry.isUser ? Icons.person_pin : Icons.person,
              color: AppColors.kAccentWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Name
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: entry.isUser ? FontWeight.bold : FontWeight.w500,
                color: AppColors.kDarkBackground,
              ),
            ),
          ),
          // XP Amount
          Text(
            '${entry.xp} XP',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.kDarkBackground,
            ),
          ),
        ],
      ),
    );
  }
}