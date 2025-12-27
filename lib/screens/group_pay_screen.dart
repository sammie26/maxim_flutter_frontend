// group_pay_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- COLOR AND STYLE CONSTANTS (Consistent) ---
const Color kDarkBackground = Color(0xFF222222);
const Color kDeepestDark = Color(0xFF111111);
const Color kLightBackground = Color(0xFFF0F0F0);
const Color kAccentWhite = Colors.white;
const Color kAccentGrey = Colors.white70;
const Color kDullTextColor = Colors.black54;
const Color kAccentBlue = Color(0xFF007AFF);
const Color kErrorRed = Color(0xFFE57373);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kHostAccentColor = Color(0xFF555555);

// --- ENUM FOR SPLITTING MODE ---
enum SplitMode { even, custom }

// --- MOCK DATA ---
class GroupMember {
  final int id;
  final String name;
  double share;
  final bool isHost;

  GroupMember({
    required this.id,
    required this.name,
    this.share = 0.0,
    this.isHost = false,
  });
}

// Global mock list of contacts (initial pool)
final List<GroupMember> mockContacts = [
  GroupMember(id: 0, name: 'You (Host)', isHost: true),
  GroupMember(id: 1, name: 'Ahmad Hassan'),
  GroupMember(id: 2, name: 'Laila Sameh'),
  GroupMember(id: 3, name: 'Omar Gaber'),
  GroupMember(id: 4, name: 'Sara Emad'),
  GroupMember(id: 5, name: 'Khaled Fathi'),
];

class GroupPayScreen extends StatefulWidget {
  const GroupPayScreen({super.key});

  @override
  State<GroupPayScreen> createState() => _GroupPayScreenState();
}

class _GroupPayScreenState extends State<GroupPayScreen> {
  List<GroupMember> _selectedMembers = [];
  final TextEditingController _amountController = TextEditingController();
  double _totalAmount = 0.0;
  String _amountError = '';
  SplitMode _splitMode = SplitMode.even;

  final Map<int, TextEditingController> _customControllers = {};

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateSplit);

    // Fix 1: Only the Host is added on initialization.
    _selectedMembers.add(mockContacts.firstWhere((m) => m.isHost));
    // The line below, which previously added Ahmad, is now removed:
    // _selectedMembers.add(mockContacts[1]);

    _calculateSplit();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  double _getSumOfShares() {
    return _selectedMembers.fold(0.0, (sum, member) => sum + member.share);
  }

  void _calculateSplit() {
    setState(() {
      final text = _amountController.text.replaceAll(',', '');
      _totalAmount = double.tryParse(text) ?? 0.0;
      _amountError = '';

      if (_totalAmount < 0) {
        _amountError = 'Amount cannot be negative.';
        _totalAmount = 0.0;
      }

      if (_totalAmount <= 0) {
        for (var member in _selectedMembers) {
          member.share = 0.0;
        }
        return;
      }

      if (_splitMode == SplitMode.even) {
        if (_selectedMembers.isEmpty) {
          _amountError = 'Select members to split the bill.';
          return;
        }
        final double share = _totalAmount / _selectedMembers.length;
        for (var member in _selectedMembers) {
          member.share = share;
          if (_customControllers.containsKey(member.id) &&
              _splitMode == SplitMode.even) {
            _customControllers[member.id]!.text = share.toStringAsFixed(2);
          }
        }
      }
    });
  }

  void _updateMemberShare(GroupMember member, String text) {
    double newShare = double.tryParse(text) ?? 0.0;

    if (newShare < 0) {
      newShare = 0.0;
    }

    setState(() {
      member.share = newShare;
    });
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

  void _handleSplitAndPay() {
    _calculateSplit();
    final double sumOfShares = _getSumOfShares();

    if (_amountError.isNotEmpty ||
        _totalAmount <= 0 ||
        _selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount and select members.'),
          backgroundColor: kErrorRed,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_splitMode == SplitMode.custom &&
        sumOfShares.toStringAsFixed(2) != _totalAmount.toStringAsFixed(2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: Total shares (EGP ${sumOfShares.toStringAsFixed(2)}) must exactly match the Total Bill (EGP ${_totalAmount.toStringAsFixed(2)}).',
          ),
          backgroundColor: kErrorRed,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully requested payment of EGP ${_totalAmount.toStringAsFixed(2)} split among ${_selectedMembers.length} people.',
        ),
        backgroundColor: kDarkBackground,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // BUILD METHODS
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double sumOfShares = _getSumOfShares();
    final bool isBalanced =
        sumOfShares.toStringAsFixed(2) == _totalAmount.toStringAsFixed(2);
    final Color balanceColor = isBalanced ? kSuccessGreen : kErrorRed;

    return Scaffold(
      backgroundColor: kLightBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildTitle(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  _buildAmountInput(),
                  const SizedBox(height: 40),

                  _buildMemberSelector(),
                  const SizedBox(height: 32),

                  _buildSplitModeSelector(),
                  const SizedBox(height: 20),

                  if (_totalAmount > 0 && _selectedMembers.isNotEmpty)
                    _buildInteractiveSplitSummary(
                      balanceColor,
                      sumOfShares,
                      isBalanced,
                    ),
                ],
              ),
            ),
          ),

          _buildSplitAndPayButton(context, isBalanced),
        ],
      ),
    );
  }

  // ------------------- WIDGETS -------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: kDarkBackground,
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
              color: kAccentWhite,
              size: 24,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToBlankPage(context, 'Profile'),
            child: const Icon(
              Icons.person_outline,
              color: kAccentWhite,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    // Fix 2: Changed text to "Group Pay" and increased font size
    return const Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 8.0),
      child: Text(
        'Group Pay',
        style: TextStyle(
          fontSize: 34, // Slightly larger for prominence
          fontWeight: FontWeight.bold,
          color: kDarkBackground,
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Bill Amount',
          style: TextStyle(
            fontSize: 14,
            color: kDullTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: kDarkBackground,
          ),
          decoration: InputDecoration(
            prefixText: 'EGP ',
            prefixStyle: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: kDarkBackground,
            ),
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: kDullTextColor.withValues(alpha: .3),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorText: _amountError.isNotEmpty ? _amountError : null,
            errorStyle: TextStyle(
              color: kErrorRed,
              fontWeight: FontWeight.w600,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Divider(color: kDullTextColor.withValues(alpha: .5), height: 1),
      ],
    );
  }

  Widget _buildMemberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members (${_selectedMembers.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkBackground,
              ),
            ),
            GestureDetector(
              onTap: _showAddMemberModal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kDarkBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: kAccentWhite, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: kAccentWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedMembers.length,
            itemBuilder: (context, index) {
              final member = _selectedMembers[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildMemberChip(member),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberChip(GroupMember member) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Host color remains the subtle dark gray for cohesion (kHostAccentColor)
                color: member.isHost
                    ? kHostAccentColor
                    : kDarkBackground.withValues(alpha: .8),
              ),
              child: const Center(
                child: Icon(Icons.person, color: kAccentWhite, size: 32),
              ),
            ),
            if (!member.isHost)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMembers.removeWhere((m) => m.id == member.id);
                      _calculateSplit();
                    });
                  },
                  child: const CircleAvatar(
                    radius: 8,
                    backgroundColor: kErrorRed,
                    child: Icon(Icons.close, color: kAccentWhite, size: 8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          member.name.split(' ').first,
          style: const TextStyle(fontSize: 12, color: kDullTextColor),
        ),
      ],
    );
  }

  void _showAddMemberModal() {
    List<GroupMember> tempSelectedMembers = List.from(_selectedMembers);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: kAccentWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Contacts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kDarkBackground,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedMembers = tempSelectedMembers;
                              _selectedMembers.sort(
                                (a, b) => (b.isHost ? 1 : 0).compareTo(
                                  a.isHost ? 1 : 0,
                                ),
                              );
                              _calculateSplit();
                            });
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: kAccentBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: mockContacts.length,
                      itemBuilder: (context, index) {
                        final contact = mockContacts[index];
                        if (contact.isHost) return const SizedBox.shrink();

                        final isSelected = tempSelectedMembers.any(
                          (m) => m.id == contact.id,
                        );
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kDarkBackground.withValues(alpha: .8),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: kAccentWhite,
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(color: kDarkBackground),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            activeColor: kDarkBackground,
                            onChanged: (bool? value) {
                              modalSetState(() {
                                if (value == true && !isSelected) {
                                  tempSelectedMembers.add(contact);
                                } else if (value == false && isSelected) {
                                  tempSelectedMembers.removeWhere(
                                    (m) => m.id == contact.id,
                                  );
                                }
                              });
                            },
                          ),
                          onTap: () {
                            modalSetState(() {
                              if (!isSelected) {
                                tempSelectedMembers.add(contact);
                              } else {
                                tempSelectedMembers.removeWhere(
                                  (m) => m.id == contact.id,
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSplitModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Splitting Method',
          style: TextStyle(
            fontSize: 14,
            color: kDullTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: SplitMode.values.map((mode) {
            bool isSelected = mode == _splitMode;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _splitMode = mode;
                    _calculateSplit();
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: mode == SplitMode.even ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? kDarkBackground : kAccentWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? kDarkBackground
                          : kDullTextColor.withValues(alpha: .2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mode == SplitMode.even ? 'Even Split' : 'Custom Amount',
                      style: TextStyle(
                        color: isSelected ? kAccentWhite : kDarkBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInteractiveSplitSummary(
    Color balanceColor,
    double sumOfShares,
    bool isBalanced,
  ) {
    bool isCustom = _splitMode == SplitMode.custom;
    final double difference = _totalAmount - sumOfShares;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isCustom ? 'Custom Split Breakdown' : 'Even Split Breakdown',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkBackground,
              ),
            ),
            Text(
              'Total Split: EGP ${sumOfShares.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kDarkBackground.withValues(alpha: .7),
              ),
            ),
          ],
        ),

        if (isCustom && !isBalanced)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: balanceColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: balanceColor, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    difference > 0 ? 'Remaining Balance:' : 'Overpaid Balance:',
                    style: TextStyle(
                      fontSize: 16,
                      color: balanceColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'EGP ${difference.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kAccentWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kDullTextColor.withValues(alpha: .2),
              width: 1,
            ),
          ),
          child: Column(
            children: _selectedMembers.map((member) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildMemberShareRow(member, isCustom),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberShareRow(GroupMember member, bool isCustom) {
    if (!_customControllers.containsKey(member.id)) {
      _customControllers[member.id] = TextEditingController();
    }
    final TextEditingController shareController =
        _customControllers[member.id]!;

    String initialText = '';
    if (isCustom) {
      if (member.share > 0) {
        initialText = member.share.toStringAsFixed(2);
      } else {
        initialText = '';
      }
    } else {
      initialText = member.share.toStringAsFixed(2);
    }

    // Update the controller text if the mode is 'Even Split' or if we are setting a non-zero value
    if (_splitMode == SplitMode.even ||
        (initialText.isNotEmpty && shareController.text.isEmpty)) {
      // Use post-frame callback for safety
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only update if the text actually differs to avoid resetting cursor for custom input
        if (shareController.text != initialText) {
          shareController.text = initialText;
        }
      });
    }

    // Explicitly set text for non-custom mode
    if (_splitMode != SplitMode.custom) {
      shareController.text = member.share.toStringAsFixed(2);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Member Info
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: member.isHost
                      ? kHostAccentColor
                      : kDarkBackground.withValues(alpha: .8),
                ),
                child: const Icon(Icons.person, color: kAccentWhite, size: 16),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  member.name,
                  style: const TextStyle(
                    color: kDarkBackground,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Amount Input or Display
        Expanded(
          flex: isCustom ? 3 : 2,
          child: isCustom
              ? Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    key: ValueKey('custom_${member.id}'),
                    controller: shareController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: kDarkBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'EGP ',
                      prefixStyle: const TextStyle(
                        color: kDarkBackground,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: kDullTextColor.withValues(alpha: .4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    onChanged: (text) => _updateMemberShare(member, text),
                    onTap: () {
                      if (shareController.text.isNotEmpty) {
                        shareController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: shareController.text.length,
                        );
                      }
                    },
                  ),
                )
              : Text(
                  'EGP ${member.share.toStringAsFixed(2)}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: kDarkBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSplitAndPayButton(BuildContext context, bool isBalanced) {
    final bool isDisabled =
        _amountError.isNotEmpty ||
        _totalAmount <= 0 ||
        _selectedMembers.isEmpty ||
        (_splitMode == SplitMode.custom && !isBalanced);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: GestureDetector(
        onTap: isDisabled ? null : _handleSplitAndPay,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDisabled
                ? kDarkBackground.withValues(alpha: .5)
                : kDarkBackground,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: kDarkBackground.withValues(alpha: .4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              'Request Payment EGP ${_totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isDisabled
                    ? kAccentGrey.withValues(alpha: .7)
                    : kAccentWhite,
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
