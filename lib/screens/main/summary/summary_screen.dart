import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:maxim___frontend/screens/group_pay_screen.dart';
import 'package:maxim___frontend/screens/pay_bill_screen.dart';
import 'package:maxim___frontend/screens/send_money_screen.dart';
import 'package:maxim___frontend/screens/shared/appbar_expanded.dart';
import 'package:maxim___frontend/screens/shared/blank_screen.dart';
import 'package:maxim___frontend/theme/app_theme.dart';
import 'package:maxim___frontend/screens/main/rewards/financial_insight_page.dart';
import 'package:maxim___frontend/screens/refer_a_friend_screen.dart';
import 'package:maxim___frontend/screens/progress_screen.dart';

// ✅ Logic & Model Imports for Dynamic Changes
import 'package:maxim___frontend/providers/auth_provider.dart';
import 'package:maxim___frontend/services/card_service.dart';
import 'package:maxim___frontend/models/card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Method to trigger refresh of all dashboard data
  void _refreshData() {
    final keycloakId = Provider.of<AuthProvider>(context, listen: false).userId;
    setState(() {
      _dashboardData = _fetchDashboardInfo(keycloakId);
    });
  }

  // Logic to fetch user cards (for total balance) and transactions
  Future<Map<String, dynamic>> _fetchDashboardInfo(String keycloakId) async {
    try {
      // Parallel fetch for cards and transactions for speed
      final results = await Future.wait([
        CardService().fetchUserCards(keycloakId),
        http.get(Uri.parse("http://10.0.2.2:3000/api/transactions/$keycloakId")),
      ]);

      final List<CardData> cards = results[0] as List<CardData>;
      final http.Response txResponse = results[1] as http.Response;

      // ✅ CHANGE: Calculate Total Balance dynamically across all cards
      final double totalBalance = cards.fold(0.0, (sum, card) => sum + card.balance);

      // ✅ CHANGE: Parse Recent Transactions (Preview top 4) from real data
      List<Map<String, dynamic>> recentTransactions = [];
      if (txResponse.statusCode == 200) {
        final data = jsonDecode(txResponse.body);
        final List rawTx = data['transactions'] ?? [];
        
        recentTransactions = rawTx.take(4).map((t) {
          final bool isReceived = t['type'] == 'p2p_received' || t['type'] == 'cashback';
          return {
            'icon': isReceived ? Icons.arrow_downward : Icons.arrow_upward,
            'title': t['provider_name'] ?? (isReceived ? 'Received Money' : 'Payment'),
            'date': t['created_at'].toString().split('T')[0],
            'amount': t['amount'].toString(),
            'type': isReceived ? 'Received' : 'Paid',
          };
        }).toList();
      }

      return {
        'totalBalance': totalBalance.toStringAsFixed(2),
        'transactions': recentTransactions,
      };
    } catch (e) {
      print("❌ Dashboard Fetch Error: $e");
      return {
        'totalBalance': "0.00",
        'transactions': [],
      };
    }
  }

  void _navigateToBlankPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlankPage(title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // ✅ UPDATED NAME LOGIC: Priority on actual First and Last names from Keycloak
    final String firstName = auth.userData['given_name'] ?? "";
    final String lastName = auth.userData['family_name'] ?? "";
    final String fullName = "$firstName $lastName".trim();
    
    // Fallback logic: Use Full Name -> Email prefix -> "User"
    final String displayName = fullName.isNotEmpty 
        ? fullName 
        : (auth.userData['email']?.split('@')[0] ?? "User");

    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.kLightBackground,
        body: Column(
          children: [
            AppBarExpanded("Summary"),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _dashboardData,
                builder: (context, snapshot) {
                  final String balance = snapshot.data?['totalBalance'] ?? "0.00";
                  final List<Map<String, dynamic>> txList = snapshot.data?['transactions'] ?? [];

                  return RefreshIndicator(
                    onRefresh: () async => _refreshData(),
                    color: AppColors.kDarkBackground,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.kDullTextColor,
                              ),
                            ),
                            Text(
                              displayName, // ✅ Now displays "layla ahmed"
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.kDarkBackground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Total Balance',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.kDullTextColor,
                              ),
                            ),
                            Text(
                              'EGP $balance', // ✅ Dynamic Balance
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kDarkBackground,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildActionButtons(context),
                            const SizedBox(height: 24),
                            _buildScrollableActivity(context),
                            const SizedBox(height: 24),
                            _buildRewardsSection(context),
                            const SizedBox(height: 24),
                            // ✅ Dynamic Recent Transactions Section
                            _buildRecentTransactionsSection(txList),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SleekActionButton(
          icon: Icons.credit_card,
          label: 'Pay Bill',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PayBillScreen()));
          },
        ),
        _SleekActionButton(
          icon: Icons.swap_horiz,
          label: 'Send Money',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SendMoneyScreen()));
          },
        ),
        _SleekActionButton(
          icon: Icons.group,
          label: 'Group Pay',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GroupPayScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildScrollableActivity(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ActivityBox(
            title: 'Daily Activity',
            subtitle: 'Continue your streak!',
            icon: Icons.local_fire_department,
            color: AppColors.kAccentWhite,
            textColor: AppColors.kDarkBackground,
            iconColor: AppColors.kDarkBackground,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FinancialInsightPage()));
            },
          ),
          const SizedBox(width: 16),
          _ActivityBox(
            title: 'Progress',
            subtitle: '80% complete',
            color: AppColors.kAccentWhite,
            textColor: AppColors.kDarkBackground,
            iconColor: AppColors.kDarkBackground,
            progressIndicator: const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: 0.8,
                strokeWidth: 4,
                backgroundColor: Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.kDarkBackground),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FinancialGoalsScreen()));
            },
          ),
          const SizedBox(width: 16),
          _ActivityBox(
            title: 'Refer a Friend',
            subtitle: 'Get Bonus XP!',
            icon: Icons.card_giftcard,
            color: AppColors.kAccentWhite,
            textColor: AppColors.kDarkBackground,
            iconColor: AppColors.kDarkBackground,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReferAFriendScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    double rewardProgress = 0.65;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rewards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground),
            ),
            GestureDetector(
              onTap: () => _navigateToBlankPage(context, 'Rewards Detail'),
              child: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.kDullTextColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: rewardProgress,
          backgroundColor: const Color(0xFFBDBDBD),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kDarkBackground),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(List<Map<String, dynamic>> txList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground),
        ),
        const SizedBox(height: 12),
        if (txList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No recent activity.", style: TextStyle(color: AppColors.kDullTextColor)),
          )
        else
          _TransactionGroup(date: 'Latest Activity', transactions: txList),
      ],
    );
  }
}

// --- HELPER WIDGETS ---

class _SleekActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SleekActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.kAccentWhite,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(icon, color: AppColors.kDarkBackground, size: 22),
                Text(label, style: const TextStyle(color: AppColors.kDarkBackground, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityBox extends StatelessWidget {
  final String title, subtitle;
  final IconData? icon;
  final Color color, textColor, iconColor;
  final Widget? progressIndicator;
  final VoidCallback onTap;

  const _ActivityBox({
    required this.title,
    required this.subtitle,
    this.icon,
    required this.color,
    required this.textColor,
    required this.iconColor,
    this.progressIndicator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            Text(subtitle, style: const TextStyle(fontSize: 11.0, color: AppColors.kDullTextColor, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            if (progressIndicator != null) progressIndicator! else if (icon != null) Icon(icon, color: iconColor, size: 24),
          ],
        ),
      ),
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  final String date;
  final List<Map<String, dynamic>> transactions;

  const _TransactionGroup({required this.date, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.kDullTextColor)),
        const SizedBox(height: 8),
        ...transactions.map((tx) => _TransactionTile(tx)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionTile(this.transaction);

  @override
  Widget build(BuildContext context) {
    Color amountColor = transaction['type'] == 'Paid' ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20);
    IconData typeIcon = transaction['icon'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.kDarkBackground, borderRadius: BorderRadius.circular(10)),
            child: Icon(typeIcon, color: AppColors.kAccentWhite, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.kDarkBackground)),
                Text('${transaction['type']} • ${transaction['date']}', style: const TextStyle(color: AppColors.kDullTextColor, fontSize: 13)),
              ],
            ),
          ),
          Text('EGP ${transaction['amount']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: amountColor)),
        ],
      ),
    );
  }
}