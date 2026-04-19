import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/verification_providers.dart';

/// Screen for capturing a selfie for photo verification
class PhotoCaptureScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/verification/photo';

  /// Creates a new [PhotoCaptureScreen]
  const PhotoCaptureScreen({super.key});

  @override
  ConsumerState<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends ConsumerState<PhotoCaptureScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _capturedImagePath;
  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(verificationFlowProvider);

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

    // If verification completed successfully, navigate to result
    if (!state.isInProgress && _capturedImagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/verification/result', extra: {
            'type': 'photo',
            'success': true,
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for a great selfie',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Face the camera directly\n'
                    '• Good lighting (no heavy shadows)\n'
                    '• No sunglasses or hats\n'
                    '• Natural expression',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Photo preview or placeholder
            Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : _capturePhoto,
                child: Container(
                  width: 240,
                  height: 320,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _capturedImagePath != null
                          ? Colors.green
                          : theme.colorScheme.outline.withValues(alpha: 0.5),
                      width: _capturedImagePath != null ? 3 : 1,
                    ),
                  ),
                  child: _isCapturing
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              Text(
                                'Processing...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _capturedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(_capturedImagePath!),
                                fit: BoxFit.cover,
                                width: 236,
                                height: 316,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 64, color: Colors.green),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Photo captured',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap to take selfie',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            if (_capturedImagePath != null) ...[
              ElevatedButton(
                onPressed: state.isInProgress ? null : _submitVerification,
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
                    : const Text('Submit Verification'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.isInProgress ? null : _retakePhoto,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Retake Photo'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _isCapturing ? null : _capturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Selfie'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isCapturing ? null : _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            // Privacy note
            const SizedBox(height: 24),
            Text(
              'Your photo is encrypted and used only for verification. '
              'It will never be shared publicly.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    setState(() => _isCapturing = true);
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _capturedImagePath = image.path);
      }
    } on Exception catch (e) {
      if (mounted) {
        _handleImagePickerError(e);
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _capturedImagePath = image.path);
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

  void _retakePhoto() {
    setState(() => _capturedImagePath = null);
  }

  void _submitVerification() {
    if (_capturedImagePath == null) return;
    ref.read(verificationFlowProvider.notifier).submitPhotoVerification(
          _capturedImagePath!,
        );
  }
}
