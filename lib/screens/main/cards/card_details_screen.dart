import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maxim___frontend/models/card.dart';
import 'package:maxim___frontend/screens/shared/appbar_expanded.dart';
import 'package:maxim___frontend/theme/app_theme.dart';
import 'package:maxim___frontend/providers/auth_provider.dart';
import 'package:maxim___frontend/services/card_service.dart';

import 'card_management_actions_screens.dart'; 

class CardDetailsScreen extends StatefulWidget {
  final CardData card;

  const CardDetailsScreen({super.key, required this.card});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  late CardData _currentCard; 
  int _selectedContentIndex = 0;
  bool _showCvv = false; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card; 
  }

  Future<void> _refreshCardData() async {
    setState(() => _isLoading = true);
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final cards = await CardService().fetchUserCards(userId);
      
      // Find the updated version of this specific card
      final updatedCard = cards.firstWhere((c) => c.id == _currentCard.id);
      
      setState(() {
        _currentCard = updatedCard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              AppBarExpanded("Cards"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context, true), 
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.kDarkBackground,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentCard.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kDarkBackground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCardImage(),
                      const SizedBox(height: 24),
                      const Text(
                        'Card Balance',
                        style: TextStyle(fontSize: 16, color: AppColors.kDullTextColor),
                      ),
                      Text(
                        'EGP ${_currentCard.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kDarkBackground,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 24),
                      _buildContentBox(),
                      const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildCardImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(_currentCard.imagePath),
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SleekButton(
          label: 'Details',
          icon: Icons.credit_card,
          isSelected: _selectedContentIndex == 0,
          onTap: () => setState(() => _selectedContentIndex = 0),
        ),
        _SleekButton(
          label: 'Settings',
          icon: Icons.settings,
          isSelected: _selectedContentIndex == 1,
          onTap: () => setState(() => _selectedContentIndex = 1),
        ),
      ],
    );
  }

  Widget _buildContentBox() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.kAccentWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedContentIndex == 0) ..._buildCardDetails(),
          if (_selectedContentIndex == 1) ..._buildSettings(),
        ],
      ),
    );
  }

  List<Widget> _buildCardDetails() {
    final formattedNumber = _currentCard.number.replaceAllMapped(
        RegExp(r".{4}"), (match) => "${match.group(0)} ");

    return [
      _DetailRow(
        label: 'Card Number',
        value: formattedNumber.trim(),
        trailingIcon: Icons.copy,
      ),
      const SizedBox(height: 16),
      _DetailRow(
        label: 'Expiry Date',
        value: _currentCard.expiry,
        trailingIcon: Icons.calendar_month_outlined,
      ),
      const SizedBox(height: 16),
      _DetailRow(
        label: 'CVV',
        value: _showCvv ? _currentCard.cvv : '***',
        trailingIcon: _showCvv ? Icons.visibility : Icons.visibility_off,
        onIconTap: () => setState(() => _showCvv = !_showCvv), 
      ),
    ];
  }

  List<Widget> _buildSettings() {
    final statusColor = _currentCard.status == CardStatus.active ? Colors.green : Colors.red;
    
    return [
      Row(
        children: [
          const Text('Card Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            _currentCard.status.name.toUpperCase(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const Divider(height: 32),
      _SettingsTile(
        icon: Icons.lock_outline,
        label: 'Change Card PIN',
        onTap: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => ChangePinScreen(card: _currentCard))
          );
          if (result == true) _refreshCardData();
        },
      ),
      _SettingsTile(
        icon: _currentCard.status == CardStatus.frozen ? Icons.lock_open : Icons.ac_unit,
        label: _currentCard.status == CardStatus.frozen ? 'Unfreeze Card' : 'Freeze Card Temporarily',
        onTap: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => FreezeCardScreen(card: _currentCard))
          );
          if (result == true) _refreshCardData(); 
        },
      ),
      _SettingsTile(
        icon: Icons.delete_forever_outlined,
        label: 'Terminate Card',
        onTap: () async {
          // ✅ Calling the class TerminateCardScreen from the other file
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => TerminateCardScreen(card: _currentCard))
          );
          if (result == true) Navigator.pop(context, true); 
        },
      ),
    ];
  }
}

class _SleekButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SleekButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.kDarkBackground : AppColors.kAccentWhite,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? AppColors.kDarkBackground : const Color(0xFFE0E0E0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.kAccentWhite : AppColors.kDarkBackground,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.kAccentWhite : AppColors.kDarkBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? trailingIcon;
  final VoidCallback? onIconTap;

  const _DetailRow({required this.label, required this.value, this.trailingIcon, this.onIconTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.kDullTextColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground),
            ),
            if (trailingIcon != null)
              GestureDetector(
                onTap: onIconTap,
                child: Icon(trailingIcon, size: 18, color: AppColors.kDullTextColor),
              ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.kDarkBackground, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: AppColors.kDarkBackground, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.kDullTextColor),
          ],
        ),
      ),
    );
  }
}