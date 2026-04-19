import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/verification_providers.dart';

/// Screen for uploading government ID document images
class IdUploadScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/verification/id/upload';

  /// Creates a new [IdUploadScreen]
  const IdUploadScreen({super.key});

  @override
  ConsumerState<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends ConsumerState<IdUploadScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _frontImagePath;
  String? _backImagePath;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(verificationFlowProvider);
    final documentType = GoRouterState.of(context).extra as String? ?? 'passport';

    // Listen for errors
    ref.listen<VerificationFlowState>(verificationFlowProvider, (prev, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(verificationFlowProvider.notifier).clearError();
      }
    });

    // Navigate to result on success
    if (!state.isInProgress && _frontImagePath != null && _isUploading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/verification/result', extra: {
            'type': 'id',
            'success': true,
          });
        }
      });
    }

    final requiresBack = documentType != 'passport';

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload ${_documentLabel(documentType)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Text(
              'Take a clear photo of your document',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure all text is readable and the photo is well-lit.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Front of ID
            _buildUploadSection(
              context,
              label: 'Front of ${_documentLabel(documentType)}',
              imagePath: _frontImagePath,
              onTap: () => _captureImage(isFront: true),
              isRequired: true,
            ),

            // Back of ID (for license and national ID)
            if (requiresBack) ...[
              const SizedBox(height: 20),
              _buildUploadSection(
                context,
                label: 'Back of ${_documentLabel(documentType)}',
                imagePath: _backImagePath,
                onTap: () => _captureImage(isFront: false),
                isRequired: true,
              ),
            ],

            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _canSubmit(requiresBack) && !state.isInProgress
                  ? _submitVerification
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: state.isInProgress
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit for Verification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(
    BuildContext context, {
    required String label,
    required String? imagePath,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: imagePath != null
                    ? Colors.green
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
                width: imagePath != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.2),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 48, color: Colors.green),
                                const SizedBox(height: 8),
                                Text(
                                  'Photo captured',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to capture',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _captureImage({required bool isFront}) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (image != null) {
        setState(() {
          if (isFront) {
            _frontImagePath = image.path;
          } else {
            _backImagePath = image.path;
          }
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        _handleImagePickerError(e);
      }
    }
  }

  void _handleImagePickerError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('permission') || msg.contains('denied') || msg.contains('not granted')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required. Please enable it in Settings.'),
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access camera: $e')),
      );
    }
  }

  bool _canSubmit(bool requiresBack) {
    if (_frontImagePath == null) return false;
    if (requiresBack && _backImagePath == null) return false;
    return true;
  }

  void _submitVerification() {
    if (_frontImagePath == null) return;
    setState(() => _isUploading = true);

    ref.read(verificationFlowProvider.notifier).submitIdVerification(
          frontImagePath: _frontImagePath!,
          backImagePath: _backImagePath,
        );
  }

  String _documentLabel(String type) {
    switch (type) {
      case 'passport':
        return 'Passport';
      case 'license':
        return 'Driver\'s License';
      case 'national_id':
        return 'National ID';
      default:
        return 'Document';
    }
  }
}
