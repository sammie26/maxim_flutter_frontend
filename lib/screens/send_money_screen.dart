import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maxim___frontend/providers/auth_provider.dart';
import 'package:maxim___frontend/services/contacts_service.dart';
import 'enter_amount_screen.dart';

// --- COLOR AND STYLE CONSTANTS ---
const Color kDarkBackground = Color(0xFF222222);
const Color kDeepestDark = Color(0xFF111111);
const Color kLightBackground = Color(0xFFF0F0F0);
const Color kAccentWhite = Colors.white;
const Color kAccentGrey = Colors.white70;
const Color kDullTextColor = Colors.black54;

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  Contact? _selectedContact;
  String _searchQuery = '';
  late Future<List<Contact>> _contactsFuture;
  final TextEditingController _addContactController = TextEditingController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  // ✅ Fetch contacts from the database
  void _refreshContacts() {
    final keycloakId = Provider.of<AuthProvider>(context, listen: false).userId;
    setState(() {
      _contactsFuture = ContactsService().fetchContacts(keycloakId);
    });
  }

  // ✅ Add Contact Bottom Sheet Logic
  void _showAddContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: kLightBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Contact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDarkBackground,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the email or phone number associated with a Maxim account.',
                  style: TextStyle(color: kDullTextColor),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _addContactController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Email or Phone Number',
                    filled: true,
                    fillColor: kAccentWhite,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isAdding ? null : () async {
                      setModalState(() => _isAdding = true);
                      final keycloakId = Provider.of<AuthProvider>(context, listen: false).userId;
                      
                      try {
                        await ContactsService().addContact(
                          keycloakId: keycloakId,
                          contactIdentifier: _addContactController.text,
                        );
                        _addContactController.clear();
                        if (mounted) Navigator.pop(context);
                        _refreshContacts();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      } finally {
                        setModalState(() => _isAdding = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isAdding 
                      ? const CircularProgressIndicator(color: kAccentWhite)
                      : const Text('Add Contact', style: TextStyle(color: kAccentWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
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
    return Scaffold(
      backgroundColor: kLightBackground,
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          final contacts = snapshot.data ?? [];
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildTitle(),
              _buildSuggestedContacts(context, contacts),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        _buildSegmentedTabs(),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            children: [
                              const SizedBox(), // Spacer for alignment
                              _buildContactList(contacts, 'All'),
                              _buildContactList(contacts.where((c) => c.isFriend).toList(), 'Friends'),
                              _buildContactList(contacts.where((c) => c.isFavorite).toList(), 'Favourites'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildContinueButton(context),
            ],
          );
        }
      ),
    );
  }

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
            child: const Icon(Icons.arrow_back_ios_new, color: kAccentWhite, size: 24),
          ),
          GestureDetector(
            onTap: () => _navigateToBlankPage(context, 'Profile'),
            child: const Icon(Icons.person_outline, color: kAccentWhite, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        'Send Money',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kDarkBackground),
      ),
    );
  }

  Widget _buildSuggestedContacts(BuildContext context, List<Contact> contacts) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSpecialPill('QR', Icons.qr_code_2_rounded, () => _navigateToBlankPage(context, 'QR Scan')),
          _buildSpecialPill('Add', Icons.person_add_alt_1, _showAddContactSheet),
          ...contacts.take(10).map((contact) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedContact = (_selectedContact?.contactUuid == contact.contactUuid) ? null : contact;
              });
            },
            child: _buildContactPill(contact),
          )),
        ],
      ),
    );
  }

  Widget _buildSpecialPill(String name, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 58, height: 58,
              decoration: const BoxDecoration(color: kDarkBackground, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: kAccentWhite),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, color: kDarkBackground, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildContactPill(Contact contact) {
    final bool isSelected = _selectedContact?.contactUuid == contact.contactUuid;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: isSelected ? kDarkBackground : kAccentWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? kDarkBackground : kDullTextColor.withOpacity(0.3),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Icon(Icons.person, size: 28, color: isSelected ? kAccentWhite : kDullTextColor),
          ),
          const SizedBox(height: 8),
          Text(
            contact.email.split('@')[0],
            style: TextStyle(fontSize: 12, color: kDarkBackground, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(borderSide: BorderSide(color: kDarkBackground, width: 3)),
        labelColor: kDarkBackground,
        unselectedLabelColor: kDullTextColor,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: const [
          Tab(child: SizedBox(width: 0)),
          Tab(text: 'All'),
          Tab(text: 'Friends'),
          Tab(text: 'Favourites'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kAccentWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDullTextColor.withOpacity(0.2)),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        decoration: const InputDecoration(
          hintText: 'Search Contacts',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: kDullTextColor),
        ),
      ),
    );
  }

  Widget _buildContactList(List<Contact> contacts, String listName) {
    final filtered = contacts.where((c) => c.email.toLowerCase().contains(_searchQuery)).toList();

    if (filtered.isEmpty) {
      return Center(child: Text('No $listName contacts found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final contact = filtered[index];
        final bool isSelected = contact.contactUuid == _selectedContact?.contactUuid;

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: kDarkBackground,
            child: Icon(Icons.person, color: kAccentWhite),
          ),
          title: Text(contact.email),
          subtitle: Text(contact.phoneNumber),
          trailing: isSelected 
              ? const Icon(Icons.check_circle, color: kDarkBackground) 
              : const Icon(Icons.arrow_forward_ios, size: 16, color: kDullTextColor),
          onTap: () => setState(() => _selectedContact = isSelected ? null : contact),
        );
      },
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final bool isDisabled = _selectedContact == null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: isDisabled ? null : () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EnterAmountScreen(
                recipientUuid: _selectedContact!.contactUuid,
                recipientName: _selectedContact!.email.split('@')[0],
              ),
            ),
          );
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDisabled ? kDarkBackground.withOpacity(0.5) : kDarkBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text('Continue', style: TextStyle(color: kAccentWhite, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}