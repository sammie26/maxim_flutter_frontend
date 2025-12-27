import 'package:flutter/material.dart';
import 'package:maxim___frontend/stores/service_provider_store.dart';
import 'package:maxim___frontend/theme/app_theme.dart';
import '../models/service_provider.dart' show ServiceProvider;

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  // State Variables
  ServiceProvider? _selectedProvider;
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _refError = '';
  String _amountError = '';
  double _currentAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Default to the first provider
    _selectedProvider = availableProviders.first;
    _amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _refController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _navigateToBlankPage(BuildContext context, String title) {
    // Utility function for navigation used in the header (Profile)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(color: AppColors.kDarkBackground),
            ),
            backgroundColor: AppColors.kLightBackground,
            iconTheme: const IconThemeData(color: AppColors.kDarkBackground),
            elevation: 0,
          ),
          body: Center(child: Text('You navigated to $title')),
        ),
      ),
    );
  }

  void _validateAmount() {
    setState(() {
      final text = _amountController.text.replaceAll(',', '');
      _currentAmount = double.tryParse(text) ?? 0.0;

      // Basic amount validation
      if (_currentAmount <= 0) {
        _amountError =
            ''; // Error will be handled by the button check unless it's a typing error
      } else if (_currentAmount < 5.0) {
        _amountError = 'Minimum bill payment is EGP 5.00';
      } else if (_currentAmount > 10000.0) {
        _amountError = 'Maximum bill payment is EGP 10,000.00';
      } else {
        _amountError = '';
      }
    });
  }

  void _handlePay() {
    _validateAmount();

    setState(() {
      // Basic reference number validation
      if (_refController.text.isEmpty) {
        _refError = 'Please enter a valid reference number.';
      } else {
        _refError = '';
      }
    });

    if (_amountError.isEmpty && _refError.isEmpty && _currentAmount > 0) {
      // Successful Transaction Logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Paying EGP ${_currentAmount.toStringAsFixed(2)} for ${_selectedProvider!.name} (Ref: ${_refController.text})',
          ),
          backgroundColor: AppColors.kDarkBackground,
          duration: const Duration(seconds: 3),
        ),
      );
      // In a real app, you would navigate to a confirmation or receipt screen here.
      // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentReceiptScreen(...)));
    } else if (_currentAmount == 0) {
      setState(() {
        _amountError = 'Please enter an amount.';
      });
    }
  }

  // ----------------------------------------------------------------------
  // BUILD METHODS
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dark Header (Signature Style)
          _buildHeader(context),

          // 2. Main Title
          _buildTitle(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // 3. Service Provider Selection
                  _buildProviderDropdown(),
                  const SizedBox(height: 32),

                  // 4. Reference/Account Input
                  _buildReferenceInput(),
                  const SizedBox(height: 32),

                  // 5. Amount Input (Sleek, Large Font)
                  _buildAmountInput(),
                ],
              ),
            ),
          ),

          // 6. Pay Button
          _buildPayButton(context),
        ],
      ),
    );
  }

  // ------------------- WIDGETS -------------------

  Widget _buildHeader(BuildContext context) {
    // Signature dark header with back and profile icons
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.kAccentWhite,
              size: 24,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToBlankPage(context, 'Profile'),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.kAccentWhite,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 8.0),
      child: Text(
        'Pay Bill',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.kDarkBackground,
        ),
      ),
    );
  }

  Widget _buildProviderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service Provider',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.kDullTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.kAccentWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.kDullTextColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ServiceProvider>(
              value: _selectedProvider,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.kDarkBackground,
              ),
              onChanged: (ServiceProvider? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedProvider = newValue;
                  });
                }
              },
              items: availableProviders.map<DropdownMenuItem<ServiceProvider>>((
                ServiceProvider provider,
              ) {
                return DropdownMenuItem<ServiceProvider>(
                  value: provider,
                  child: Row(
                    children: [
                      Icon(
                        provider.icon,
                        color: AppColors.kDarkBackground,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.kDarkBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reference / Account Number',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.kDullTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _refController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.kDarkBackground,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., 10-digit customer ID',
            hintStyle: TextStyle(
              color: AppColors.kDullTextColor.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.kAccentWhite,
            errorText: _refError.isNotEmpty ? _refError : null,
            errorStyle: TextStyle(
              color: AppColors.kErrorRed,
              fontWeight: FontWeight.w600,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.kDullTextColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.kDullTextColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.kDarkBackground,
                width: 2,
              ), // Focus border
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    // Large, prominent amount input similar to the previous screen
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount to Pay',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.kDullTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkBackground,
          ),
          decoration: InputDecoration(
            prefixText: 'EGP ', // Currency prefix
            prefixStyle: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.kDarkBackground,
            ),
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.kDullTextColor.withValues(alpha: 0.3),
            ),
            // Hide all borders for clean design
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorText: _amountError.isNotEmpty ? _amountError : null,
            errorStyle: TextStyle(
              color: AppColors.kErrorRed,
              fontWeight: FontWeight.w600,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        // Divider line below the input
        Divider(
          color: AppColors.kDullTextColor.withValues(alpha: 0.5),
          height: 1,
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    // Button is disabled if any required fields are missing or there are errors
    final bool isDisabled =
        _amountError.isNotEmpty ||
        _currentAmount <= 0 ||
        _refController.text.isEmpty ||
        _selectedProvider == null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: GestureDetector(
        onTap: isDisabled ? null : _handlePay,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.kDarkBackground.withValues(alpha: 0.5)
                : AppColors.kDarkBackground,
            borderRadius: BorderRadius.circular(14),
            // Adding a subtle shadow for depth
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.kDarkBackground.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              'Pay Bill',
              style: TextStyle(
                color: isDisabled
                    ? AppColors.kAccentGrey.withValues(alpha: .7)
                    : AppColors.kAccentWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
