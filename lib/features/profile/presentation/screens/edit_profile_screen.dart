import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/providers/analytics_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../auth/presentation/providers/auth_navigation_provider.dart';
import '../providers/test_profile_provider.dart';
import '../notifiers/profile_notifier.dart';

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
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();

    final profileState = ref.read(testProfileProvider);
    final profile = profileState.profile;

    if (profile != null) {
      _displayNameController.text = profile.displayName;
      _emailController.text = profile.email;
      _bioController.text = profile.bio ?? '';
      _isPublic = profile.isPublic;
      _avatarUrl = profile.avatarUrl;
    } else {
      // Fallback: populate from Supabase auth user
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _emailController.text = user.email ?? '';
        _displayNameController.text =
            user.userMetadata?['full_name'] as String? ??
                user.userMetadata?['name'] as String? ??
                user.email?.split('@').first ??
                '';
        _avatarUrl = user.userMetadata?['avatar_url'] as String?;
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingAvatar = true);

    try {
      await ref.read(profileProvider.notifier).uploadAvatar(pickedFile.path);

      ref.read(analyticsServiceProvider).track(AnalyticsEvents.uploadPhoto);

      // Refresh profile to get updated avatar URL
      ref.invalidate(testProfileProvider);
      final updatedProfile = ref.read(testProfileProvider).profile;
      if (updatedProfile?.avatarUrl != null) {
        setState(() => _avatarUrl = updatedProfile!.avatarUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final user = Supabase.instance.client.auth.currentUser;
      final displayName = _displayNameController.text.trim();
      final bio = _bioController.text.trim();

      try {
        // Update display name and bio in Supabase auth user metadata
        if (user != null) {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(
              data: {
                'full_name': displayName,
                'bio': bio,
              },
            ),
          );
        }

        ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.editProfile,
          properties: {'displayName': displayName, 'hasBio': bio.isNotEmpty},
        );

        // Invalidate the test profile provider so it rebuilds with new data
        ref.invalidate(testProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
          if (widget.isInitialSetup) {
            ref.read(authNavigationProvider.notifier).navigateToHome();
          } else {
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: _isUploadingAvatar
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                onPressed: _pickAndUploadAvatar,
                                icon: const Icon(Icons.camera_alt,
                                    size: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name *',
                  border: OutlineInputBorder(),
                  helperText: 'Required',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  helperText: 'Tell other travelers about yourself',
                ),
                maxLines: 3,
                maxLength: 280,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Public Profile'),
                subtitle: const Text(
                  'When enabled, your profile will be visible to other users',
                ),
                value: _isPublic,
                onChanged: (value) {
                  setState(() => _isPublic = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
