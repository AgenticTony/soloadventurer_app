import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';
import '../widgets/contact_picker_widget.dart';

/// Screen for adding or editing a trusted contact
/// When [contact] is provided, screen is in edit mode
/// When [contact] is null, screen is in add mode
class AddEditTrustedContactScreen extends ConsumerStatefulWidget {
  final TrustedContact? contact;

  const AddEditTrustedContactScreen({
    super.key,
    this.contact,
  });

  @override
  ConsumerState<AddEditTrustedContactScreen> createState() =>
      _AddEditTrustedContactScreenState();
}

class _AddEditTrustedContactScreenState
    extends ConsumerState<AddEditTrustedContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  ContactSource _selectedSource = ContactSource.phone;
  ContactPermission _selectedPermission = ContactPermission.checkIns;
  bool _locationSharingEnabled = false;
  bool _receivesEmergencyAlerts = true;
  bool _receivesCheckIns = true;

  @override
  void initState() {
    super.initState();

    // Initialize fields if editing existing contact
    if (widget.contact != null) {
      final contact = widget.contact!;
      _nameController.text = contact.name;
      _phoneController.text = contact.phoneNumber;
      _emailController.text = contact.email ?? '';
      _notesController.text = contact.notes ?? '';
      _selectedSource = contact.source;
      _selectedPermission = contact.permission;
      _locationSharingEnabled = contact.locationSharingEnabled;
      _receivesEmergencyAlerts = contact.receivesEmergencyAlerts;
      _receivesCheckIns = contact.receivesCheckIns;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.contact != null;

  void _openContactPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactPickerWidget(
          onContactSelected: ({required name, required phoneNumber, email}) {
            setState(() {
              _nameController.text = name;
              _phoneController.text = phoneNumber;
              if (email != null) {
                _emailController.text = email;
              }
              // Automatically set source to phone when selecting from phone
              _selectedSource = ContactSource.phone;
            });
          },
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(authProvider).value?.user;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to add trusted contacts'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final notifier = ref.read(trustedContactsProvider.notifier);

    try {
      if (_isEditMode) {
        // Update existing contact
        final updatedContact = widget.contact!.copyWith(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          source: _selectedSource,
          permission: _selectedPermission,
          locationSharingEnabled: _locationSharingEnabled,
          receivesCheckIns: _receivesCheckIns,
          receivesEmergencyAlerts: _receivesEmergencyAlerts,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await notifier.updateContact(updatedContact);

        if (mounted) {
          Navigator.of(context).pop(updatedContact);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${updatedContact.name} updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new contact
        final newContact = TrustedContact(
          id: const Uuid().v4(),
          userId: user.id,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          source: _selectedSource,
          permission: _selectedPermission,
          locationSharingEnabled: _locationSharingEnabled,
          receivesCheckIns: _receivesCheckIns,
          receivesEmergencyAlerts: _receivesEmergencyAlerts,
          addedAt: DateTime.now(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        await notifier.addContact(newContact);

        if (mounted) {
          Navigator.of(context).pop(newContact);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newContact.name} added to trusted contacts'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to ${_isEditMode ? 'update' : 'add'} contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsProvider);
    final isSaving = contactsAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEditMode ? 'Edit Trusted Contact' : 'Add Trusted Contact'),
        actions: [
          if (isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: isSaving ? null : _saveContact,
              icon: const Icon(Icons.save, color: Colors.white),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact picker button
              if (!_isEditMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isSaving ? null : _openContactPicker,
                      icon: const Icon(Icons.contacts),
                      label: const Text('Select from Phone Contacts'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter contact name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                enabled: !isSaving,
              ),
              const SizedBox(height: 16),

              // Phone number field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  // Basic phone validation
                  final phoneRegex = RegExp(r'^[\d\s\+\-\(\)]+$');
                  if (!phoneRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                enabled: !isSaving,
              ),
              const SizedBox(height: 16),

              // Email field (optional)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    // Email validation
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
                enabled: !isSaving,
              ),
              const SizedBox(height: 24),

              // Source & Permission Section
              _buildSectionHeader('Source & Permissions'),
              const SizedBox(height: 16),

              // Contact source dropdown
              DropdownButtonFormField<ContactSource>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Contact Source *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.source),
                ),
                items: const [
                  DropdownMenuItem(
                    value: ContactSource.phone,
                    child: Row(
                      children: [
                        Icon(Icons.phone_iphone),
                        SizedBox(width: 12),
                        Text('Phone Contact'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContactSource.community,
                    child: Row(
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 12),
                        Text('Community Member'),
                      ],
                    ),
                  ),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSource = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Permission level dropdown
              DropdownButtonFormField<ContactPermission>(
                initialValue: _selectedPermission,
                decoration: const InputDecoration(
                  labelText: 'Permission Level *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                  helperText: 'What information can this contact see?',
                ),
                items: const [
                  DropdownMenuItem(
                    value: ContactPermission.emergencyOnly,
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Emergency Only',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContactPermission.checkIns,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Check-ins & Emergencies',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContactPermission.fullAccess,
                    child: Row(
                      children: [
                        Icon(Icons.all_inclusive, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Full Access',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPermission = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 8),

              // Permission description
              _buildPermissionDescription(_selectedPermission),
              const SizedBox(height: 24),

              // Settings Section
              _buildSectionHeader('Notification Settings'),
              const SizedBox(height: 16),

              // Location sharing toggle
              SwitchListTile(
                title: const Text('Share Location'),
                subtitle: const Text(
                  'Allow this contact to see your location',
                ),
                value: _locationSharingEnabled,
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _locationSharingEnabled = value;
                        });
                      },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              const SizedBox(height: 8),

              // Emergency alerts toggle
              SwitchListTile(
                title: const Text('Emergency Alerts'),
                subtitle: const Text(
                  'Notify this contact during emergencies',
                ),
                value: _receivesEmergencyAlerts,
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _receivesEmergencyAlerts = value;
                        });
                      },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              const SizedBox(height: 8),

              // Check-in notifications toggle
              SwitchListTile(
                title: const Text('Check-in Notifications'),
                subtitle: const Text(
                  'Notify this contact when you check in',
                ),
                value: _receivesCheckIns,
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _receivesCheckIns = value;
                        });
                      },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              const SizedBox(height: 24),

              // Notes Section
              _buildSectionHeader('Notes (Optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any notes about this contact',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                enabled: !isSaving,
              ),
              const SizedBox(height: 32),

              // Save button at bottom for convenience
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _saveContact,
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isSaving
                        ? 'Saving...'
                        : (_isEditMode ? 'Update Contact' : 'Add Contact'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildPermissionDescription(ContactPermission permission) {
    String description;
    IconData icon;
    Color color;

    switch (permission) {
      case ContactPermission.emergencyOnly:
        description = 'This contact will only be notified during emergencies. '
            'They will not receive check-in updates or location sharing.';
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case ContactPermission.checkIns:
        description =
            'This contact will receive check-in notifications and emergency alerts. '
            'Location sharing can be enabled separately.';
        icon = Icons.check_circle;
        color = Colors.blue;
        break;
      case ContactPermission.fullAccess:
        description =
            'This contact has full access to your check-ins, emergency alerts, '
            'and location sharing when enabled.';
        icon = Icons.all_inclusive;
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.87),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
