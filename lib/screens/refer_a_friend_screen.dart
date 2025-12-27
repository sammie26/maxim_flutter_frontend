import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:share_plus/share_plus.dart'; // Used for actual sharing

// Assuming your AppColors are in this path
import '../../../theme/app_theme.dart'; 

// Mock Data
const String kReferralCode = 'MAXIM2025ABC';
const String kRewardText = 'EGP 100 for you & EGP 100 for your friend';
const String kShareMessage =
    "I'm loving MAXIM! Use my personal code $kReferralCode to get EGP 100 when you sign up and make your first transaction. Start earning rewards today!";

class ReferAFriendScreen extends StatefulWidget {
  const ReferAFriendScreen({super.key});

  @override
  State<ReferAFriendScreen> createState() => _ReferAFriendScreenState();
}

class _ReferAFriendScreenState extends State<ReferAFriendScreen> {
  // Simple state to control the "Copied!" notification
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(const ClipboardData(text: kReferralCode));
    setState(() {
      _isCopied = true;
    });
    // Reset the state after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareCode() {
    // This uses the share_plus package to trigger the native sharing sheet
    Share.share(kShareMessage);
  }

  // ----------------------------------------------------------------------
  // CUSTOM APP BAR WIDGET
  // ----------------------------------------------------------------------

  PreferredSizeWidget _buildSleekAppBar() {
    return AppBar(
      // 1. Theme and Color Consistency
      backgroundColor: AppColors.kLightBackground,
      elevation: 0, // Remove shadow for a modern look
      
      // 2. Title Styling
      title: const Text(
        "Refer a Friend",
        style: TextStyle(
          color: AppColors.kDarkBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true, // Center the title

      // 3. Back Button Styling (Leading Widget)
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.kDarkBackground, // Consistent icon color
        onPressed: () => Navigator.of(context).pop(), // Ensure it navigates back
      ),

      // 4. Removing Actions
      actions: const [
        // Setting actions to an empty list ensures no menu or other icons appear
        SizedBox(width: 56), 
      ],
    );
  }

  // ----------------------------------------------------------------------
  // BUILD METHOD
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      appBar: _buildSleekAppBar(), // Use the custom-built AppBar
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // --- 1. Hero / Reward Section ---
            _buildRewardHighlight(),
            const SizedBox(height: 40),

            // --- 2. Code Display ---
            _buildCodeDisplayCard(),
            const SizedBox(height: 40),

            // --- 3. Share Button ---
            _buildShareButton(),
            const SizedBox(height: 40),

            // --- 4. How It Works (Steps) ---
            _buildHowItWorks(),
            const SizedBox(height: 20),

            // --- 5. Referral History Placeholder ---
            _buildReferralHistoryLink(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // WIDGET BUILDING METHODS (Unchanged from previous response)
  // ----------------------------------------------------------------------
  
  Widget _buildRewardHighlight() {
    return Column(
      children: [
        Icon(
          Icons.celebration_rounded,
          size: 80,
          color: AppColors.kHostAccentColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Get Rewarded for Sharing!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          kRewardText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.kProgressColor, // Use the rewards accent color
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share your unique code with friends and family to claim your bonus.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.kDullTextColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeDisplayCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kAccentWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kProgressColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.kProgressColor.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Referral Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.kDarkBackground,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Unique Code Text
              Expanded(
                child: Text(
                  kReferralCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.kDarkBackground,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Copy Button
              GestureDetector(
                onTap: _copyToClipboard,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCopied
                        ? AppColors.kProgressColor.withValues(alpha: 0.8)
                        : AppColors.kHostAccentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCopied ? Icons.check : Icons.copy,
                        color: AppColors.kAccentWhite,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCopied ? 'COPIED!' : 'COPY',
                        style: const TextStyle(
                          color: AppColors.kAccentWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _shareCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kDarkBackground, // Dark primary button
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        icon: const Icon(Icons.share_rounded, color: AppColors.kAccentWhite),
        label: const Text(
          'Share Link via WhatsApp, SMS, etc.',
          style: TextStyle(
            color: AppColors.kAccentWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How It Works',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkBackground,
          ),
        ),
        const SizedBox(height: 16),
        _buildStep(
          step: 1,
          title: 'Share Your Code',
          description:
              'Send your unique code $kReferralCode to a friend via any app.',
          icon: Icons.person_add_alt_1_rounded,
        ),
        _buildStep(
          step: 2,
          title: 'Friend Signs Up',
          description:
              'Your friend enters the code when they download and register for the app.',
          icon: Icons.app_registration_rounded,
        ),
        _buildStep(
          step: 3,
          title: 'You Both Get Rewarded',
          description:
              'Once your friend completes their first qualifying transaction, EGP 100 is credited to both your accounts!',
          icon: Icons.monetization_on_rounded,
        ),
      ],
    );
  }

  Widget _buildStep({
    required int step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number/Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kProgressColor.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.kProgressColor, width: 2),
            ),
            child: Icon(icon, color: AppColors.kProgressColor, size: 20),
          ),
          const SizedBox(width: 16),
          // Title and Description
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
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.kDullTextColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralHistoryLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Placeholder navigation for history
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Referral History',
                    style: TextStyle(color: AppColors.kDarkBackground)),
                backgroundColor: AppColors.kLightBackground,
              ),
              body: const Center(child: Text('Your referral history goes here.')),
            ),
          ),
        );
      },
      child: const Text(
        'View Referral History & Earnings >',
        style: TextStyle(
          color: AppColors.kDarkBackground,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}