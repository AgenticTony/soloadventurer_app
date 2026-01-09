import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Callback type for when a contact is selected
typedef ContactSelectedCallback = void Function({
  required String name,
  required String phoneNumber,
  String? email,
});

/// Widget for selecting contacts from phone or community
///
/// Displays a tabbed interface allowing users to:
/// - Select from phone contacts (requires contact permission)
/// - Select from community members (future feature)
class ContactPickerWidget extends ConsumerStatefulWidget {
  /// Callback when a contact is selected
  final ContactSelectedCallback onContactSelected;

  /// Optional initial search query
  final String? initialSearchQuery;

  const ContactPickerWidget({
    super.key,
    required this.onContactSelected,
    this.initialSearchQuery,
  });

  @override
  ConsumerState<ContactPickerWidget> createState() =>
      _ContactPickerWidgetState();
}

class _ContactPickerWidgetState extends ConsumerState<ContactPickerWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<Contact> _phoneContacts = [];
  final List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.text = widget.initialSearchQuery ?? '';
    _checkPermissionAndLoadContacts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionAndLoadContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if we have permission
      final permission = await FlutterContacts.requestPermission();
      if (!permission) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _error =
              'Contact permission is required to select from phone contacts';
        });
        return;
      }

      setState(() {
        _hasPermission = true;
      });

      // Load contacts with properties we need
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have at least a phone number
      final validContacts = contacts
          .where((contact) =>
              contact.phones.isNotEmpty && contact.displayName.isNotEmpty)
          .toList();

      // Sort by name
      validContacts.sort((a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

      setState(() {
        _phoneContacts.addAll(validContacts);
        _filteredContacts.addAll(validContacts);
        _isLoading = false;
      });

      // Apply initial search if provided
      if (_searchController.text.isNotEmpty) {
        _filterContacts(_searchController.text);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load contacts: $e';
      });
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts.clear();
        _filteredContacts.addAll(_phoneContacts);
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredContacts.clear();
        _filteredContacts.addAll(_phoneContacts.where((contact) =>
            contact.displayName.toLowerCase().contains(lowerQuery) ||
            contact.phones.any(
                (phone) => phone.number.toLowerCase().contains(lowerQuery))));
      }
    });
  }

  void _selectPhoneContact(Contact contact) {
    // Get the first phone number (or primary if available)
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';

    // Get the first email (or primary if available)
    final email =
        contact.emails.isNotEmpty ? contact.emails.first.address : null;

    widget.onContactSelected(
      name: contact.displayName,
      phoneNumber: phone,
      email: email,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Phone Contacts', icon: Icon(Icons.contacts)),
            Tab(text: 'Community', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhoneContactsTab(context),
          _buildCommunityTab(context),
        ],
      ),
    );
  }

  Widget _buildPhoneContactsTab(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionRequestView(context);
    }

    if (_error != null) {
      return _buildErrorView(context, _error!);
    }

    if (_phoneContacts.isEmpty) {
      return _buildEmptyState(
        context,
        'No contacts found',
        'Your phone contacts list appears to be empty',
        Icons.contacts,
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterContacts('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            onChanged: _filterContacts,
          ),
        ),

        // Contacts list
        Expanded(
          child: _filteredContacts.isEmpty
              ? _buildEmptyState(
                  context,
                  'No matches found',
                  'Try a different search term',
                  Icons.search_off,
                )
              : ListView.separated(
                  itemCount: _filteredContacts.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    return _buildContactTile(context, contact);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildContactTile(BuildContext context, Contact contact) {
    final theme = Theme.of(context);

    // Get phone number to display
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : 'No phone number';

    // Check if has email
    final hasEmail = contact.emails.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '?',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        contact.displayName,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phone),
          if (hasEmail)
            Text(
              contact.emails.first.address,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => _selectPhoneContact(contact),
    );
  }

  Widget _buildCommunityTab(BuildContext context) {
    return _buildEmptyState(
      context,
      'Coming Soon',
      'Community member selection will be available in a future update.\n\nFor now, please use phone contacts.',
      Icons.upcoming,
    );
  }

  Widget _buildPermissionRequestView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_phone,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Contact Permission Required',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'To select from your phone contacts, please grant contact permission',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkPermissionAndLoadContacts,
              icon: const Icon(Icons.refresh),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Contacts',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkPermissionAndLoadContacts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
