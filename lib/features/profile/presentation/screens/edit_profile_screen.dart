import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/loading_view.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/profile/edit';

  /// Creates a new [EditProfileScreen]
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load the profile first
      ref.read(profileProvider.notifier).loadProfile();

      // Then set the form values
      final profile = ref.read(profileProvider).profile;
      if (profile != null) {
        _displayNameController.text = profile.displayName;
        _bioController.text = profile.bio ?? '';
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        ref.read(profileProvider.notifier).uploadAvatar(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _saveChanges() async {
    print('EditProfileScreen: Starting save changes');
    if (!_formKey.currentState!.validate()) {
      print('EditProfileScreen: Form validation failed');
      return;
    }
    print('EditProfileScreen: Form validation passed');

    final changes = {
      'displayName': _displayNameController.text.trim(),
      'bio': _bioController.text.trim(),
    };
    print('EditProfileScreen: Changes to save: $changes');

    await ref.read(profileProvider.notifier).updateProfile(changes);
    print('EditProfileScreen: Profile update completed');

    if (mounted) {
      print('EditProfileScreen: Navigating to home screen');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print('EditProfileScreen: Widget not mounted, skipping navigation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final theme = Theme.of(context);

    if (state.isProcessing) {
      return const LoadingView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: state.canSave ? _saveChanges : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ProfileAvatar(
                    avatarUrl: state.profile?.avatarUrl,
                    size: 120,
                    initials: state.profile?.displayName
                        .split(' ')
                        .take(2)
                        .map((e) => e[0])
                        .join(),
                  ),
                  FloatingActionButton.small(
                    onPressed: _pickImage,
                    child: const Icon(Icons.camera_alt),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name is required';
                  }
                  if (value.length > 50) {
                    return 'Display name cannot exceed 50 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  ref
                      .read(profileProvider.notifier)
                      .setField('displayName', value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                ),
                maxLines: 3,
                maxLength: 500,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Bio cannot exceed 500 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  ref.read(profileProvider.notifier).setField('bio', value);
                },
              ),
              if (state.hasError) ...[
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
