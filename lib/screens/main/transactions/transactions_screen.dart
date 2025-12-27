import 'package:flutter/material.dart';
import 'package:maxim___frontend/models/transaction.dart';
import 'package:maxim___frontend/screens/shared/appbar_expanded.dart';
import 'package:maxim___frontend/services/transaction_service.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';// Add this to your pubspec.yaml for date grouping
import 'package:maxim___frontend/providers/auth_provider.dart';


class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  List<TransactionModel>? _allTransactions; // Cache the full list
  late Future<Map<String, dynamic>> _fetchFuture;

  @override
  void initState() {
    super.initState();
    // Initialize future here so it doesn't re-run on every build
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fetchFuture = TransactionService().fetchTransactions(authProvider.userId);
  }

  // Pure logic: Groups whatever list is passed to it
  Map<String, List<TransactionModel>> _groupTransactions(List<TransactionModel> list) {
    Map<String, List<TransactionModel>> grouped = {};
    
    // Efficiently filter using a single pass
    final filtered = list.where((tx) =>
        tx.providerName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    for (var tx in filtered) {
      String dateKey = DateFormat('EEEE, MMM d').format(tx.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    return grouped;
  }

  void _openFilter(BuildContext context) {
    _navigateToBlankPage(context, 'Filter Transactions');
  }

  void _navigateToBlankPage(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(color: kDarkBackground)),
            backgroundColor: kLightBackground,
            iconTheme: const IconThemeData(color: kDarkBackground),
            elevation: 0,
          ),
          body: Center(child: Text('You navigated to $title')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 THE DYNAMIC FIX: Get the ID of WHOEVER is logged in from global state
    // final String currentUserId = Provider.of<AuthProvider>(context).userId;

    return Scaffold(
      backgroundColor: kLightBackground,
      body: Column(
        children: [
          AppBarExpanded("Transactions"),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              // ✅ Pass the actual dynamic ID to your backend service
              future: _fetchFuture, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("❌ Connection Error: ${snapshot.error}"));
                }

                // Update cache once data arrives
                if (snapshot.hasData && _allTransactions == null) {
                  _allTransactions = snapshot.data!['transactions'] as List<TransactionModel>;
                }

                final currentTransactions = _groupTransactions(_allTransactions ?? []);


                return CustomScrollView(
                  slivers: [
                    // SEARCH AND FILTER HEADER
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const Text(
                            'Transactions',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kDarkBackground),
                          ),
                          const SizedBox(height: 16),
                          _buildSearchAndFilter(context),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),

                    // TRANSACTION LIST GROUPED BY DATE
                    ...currentTransactions.entries.map((entry) {
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kDullTextColor),
                            ),
                          ),
                          ...entry.value.map((t) => _TransactionTile(transaction: t)),
                          const SizedBox(height: 10),
                        ]),
                      );
                    }),

                    if (currentTransactions.isEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Text('No transactions found.', style: TextStyle(color: kDullTextColor)),
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: kAccentWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: kDullTextColor, size: 20),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _openFilter(context),
          child: Container(
            height: 40, width: 40,
            decoration: BoxDecoration(
              color: kAccentWhite, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Icon(Icons.filter_list, color: kDarkBackground),
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Matches your backend logic for 'incoming' vs 'outgoing'
    final bool isIncoming = transaction.type == TransactionType.p2p_received || 
                             transaction.type == TransactionType.cashback;
    
    final Color amountColor = isIncoming ? Colors.green.shade600 : kDarkBackground;
    final String sign = isIncoming ? '+' : '-';
    final IconData icon = isIncoming ? Icons.arrow_downward : Icons.arrow_upward;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kAccentWhite, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Icon(icon, color: kDarkBackground, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.providerName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: kDarkBackground),
                ),
                Text(
                  transaction.type.name.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 13, color: kDullTextColor),
                ),
              ],
            ),
          ),
          Text(
            '$sign EGP ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: amountColor),
          ),
        ],
      ),
    );
  }
}