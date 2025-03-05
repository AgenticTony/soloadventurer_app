import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_providers.dart';
import '../routes/profile_routes.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'package:flutter/foundation.dart';

/// Screen for editing user profile information
class EditProfileScreen extends ConsumerStatefulWidget {
  static const routeName = '/edit-profile';

  /// Creates a new [EditProfileScreen]
  final bool isInitialSetup;

  const EditProfileScreen({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();

    final profileState = ref.read(profileUIProvider('current'));
    final profile = profileState.profile;

    if (profile != null) {
      _displayNameController.text = profile.displayName;
      _emailController.text = profile.email;
      _bioController.text = profile.bio ?? '';
      _isPublic = profile.isPublic;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final currentState = ref.read(profileUIProvider('current'));
      final notifier = ref.read(profileUIProvider('current').notifier);

      final profile = currentState.profile?.copyWith(
            displayName: _displayNameController.text,
            email: _emailController.text,
            bio: _bioController.text,
            isPublic: _isPublic,
          ) ??
          Profile(
            id: '',
            userId: '',
            username: '',
            email: _emailController.text,
            displayName: _displayNameController.text,
            bio: _bioController.text,
            isPublic: _isPublic,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      await notifier.updateProfile({
        'displayName': _displayNameController.text,
        'email': _emailController.text,
        'bio': _bioController.text,
        'isPublic': _isPublic
      });

      if (widget.isInitialSetup && mounted) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name *',
                border: OutlineInputBorder(),
                helperText: 'Required',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                helperText: 'Required',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                helperText: 'Optional',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public Profile'),
              subtitle: const Text(
                'When enabled, your profile will be visible to other users',
              ),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
