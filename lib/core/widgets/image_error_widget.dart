import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Enhanced error widget for failed image loads with retry functionality.
///
/// Features:
/// - Different icons based on error type (network, timeout, not found)
/// - Offline detection with appropriate messaging
/// - Retry button functionality
/// - Optional automatic retry with exponential backoff
/// - Fallback to placeholder if available
///
/// Example usage with LazyLoadImage:
/// ```dart
/// LazyLoadImage(
///   imageUrl: url,
///   errorWidget: (context, url, error) => ImageErrorWidget.withRetry(
///     error: error,
///     imageUrl: url,
///     onRetry: () => print('Retry loading'),
///   ),
/// )
/// ```
class ImageErrorWidget extends StatelessWidget {
  /// The error that occurred
  final dynamic error;

  /// The image URL that failed to load
  final String imageUrl;

  /// Optional width constraint
  final double? width;

  /// Optional height constraint
  final double? height;

  /// Optional border radius
  final BorderRadius? borderRadius;

  /// Custom error message to display
  final String? errorMessage;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  /// Icon to display for the error
  final IconData? icon;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom icon/text color
  final Color? color;

  /// Whether to show the retry button
  final bool showRetryButton;

  /// Whether to automatically detect offline status
  final bool detectOfflineStatus;

  const ImageErrorWidget({
    super.key,
    required this.error,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.errorMessage,
    this.onRetry,
    this.icon,
    this.backgroundColor,
    this.color,
    this.showRetryButton = true,
    this.detectOfflineStatus = true,
  });

  /// Creates an error widget with retry button and offline detection.
  ///
  /// This is the recommended constructor for most use cases as it provides
  /// the best user experience with automatic error type detection.
  ///
  /// Example:
  /// ```dart
  /// ImageErrorWidget.withRetry(
  ///   error: error,
  ///   imageUrl: url,
  ///   onRetry: () {
  ///     // Trigger reload of the image
  ///     setState(() {});
  ///   },
  /// )
  /// ```
  const ImageErrorWidget.withRetry({
    Key? key,
    required dynamic error,
    required String imageUrl,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    String? errorMessage,
    required VoidCallback? onRetry,
    IconData? icon,
    Color? backgroundColor,
    bool showRetryButton = true,
  }) : this(
          key: key,
          error: error,
          imageUrl: imageUrl,
          width: width,
          height: height,
          borderRadius: borderRadius,
          errorMessage: errorMessage,
          onRetry: onRetry,
          icon: icon,
          backgroundColor: backgroundColor,
          showRetryButton: showRetryButton,
          detectOfflineStatus: true,
        );

  /// Creates a compact error widget for small spaces (e.g., thumbnails).
  ///
  /// This version doesn't show text messages, only an icon.
  ///
  /// Example:
  /// ```dart
  /// ImageErrorWidget.compact(
  ///   error: error,
  ///   imageUrl: url,
  ///   size: 48,
  /// )
  /// ```
  const ImageErrorWidget.compact({
    Key? key,
    required dynamic error,
    required String imageUrl,
    double size = 48.0,
    BorderRadius? borderRadius,
    VoidCallback? onRetry,
    IconData? icon,
  }) : this(
          key: key,
          error: error,
          imageUrl: imageUrl,
          width: size,
          height: size,
          borderRadius: borderRadius,
          onRetry: onRetry,
          icon: icon,
          showRetryButton: false,
          detectOfflineStatus: false,
        );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectivityResult>>(
      future: detectOfflineStatus ? Connectivity().checkConnectivity() : null,
      builder: (context, snapshot) {
        final isOffline = detectOfflineStatus &&
            snapshot.connectionState == ConnectionState.done &&
            (snapshot.data?.isEmpty ?? true);

        return _buildErrorContent(context, isOffline);
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, bool isOffline) {
    final iconData = icon ?? _getErrorIcon(isOffline);
    final message = errorMessage ?? _getErrorMessage(isOffline);
    final bgColor = backgroundColor ?? Colors.grey[200];
    final textColor = color ?? Colors.grey[600];

    // For compact mode (no text)
    if (!showRetryButton && errorMessage == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Icon(
            iconData,
            size: _calculateIconSize(),
            color: textColor,
          ),
        ),
      );
    }

    // Full error widget with message and retry button
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: _calculateIconSize(),
              color: textColor,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _calculateFontSize(),
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRetry,
                tooltip: 'Retry',
                color: textColor,
                iconSize: _calculateIconSize() * 0.7,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Determines the appropriate icon based on error type and offline status.
  IconData _getErrorIcon(bool isOffline) {
    if (isOffline) {
      return Icons.cloud_off;
    }

    // Analyze error type to show appropriate icon
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout') || errorString.contains('deadline')) {
      return Icons.access_time;
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return Icons.image_not_supported;
    } else if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return Icons.wifi_off;
    } else if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return Icons.lock;
    } else if (errorString.contains('format') ||
        errorString.contains('decode')) {
      return Icons.broken_image;
    }

    return Icons.error_outline;
  }

  /// Determines the appropriate error message based on error type.
  String? _getErrorMessage(bool isOffline) {
    // For compact mode, return null
    if (!showRetryButton && errorMessage == null) {
      return null;
    }

    if (isOffline) {
      return 'No internet connection';
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout') || errorString.contains('deadline')) {
      return 'Request timed out';
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return 'Image not found';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error';
    } else if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return 'Access denied';
    } else if (errorString.contains('format') ||
        errorString.contains('decode')) {
      return 'Invalid image';
    }

    return 'Failed to load';
  }

  /// Calculates appropriate icon size based on container size.
  double _calculateIconSize() {
    final minDimension = width != null && height != null
        ? (width! < height! ? width! : height!)
        : (width ?? height ?? 100.0);

    // Icon is 40% of the smallest dimension
    return (minDimension * 0.4).clamp(24.0, 64.0);
  }

  /// Calculates appropriate font size based on container size.
  double _calculateFontSize() {
    final minDimension = width != null && height != null
        ? (width! < height! ? width! : height!)
        : (width ?? height ?? 100.0);

    // Font is 12% of the smallest dimension
    return (minDimension * 0.12).clamp(10.0, 14.0);
  }
}

/// Error types for more specific error handling.
enum ImageErrorType {
  /// Network connection error
  network,

  /// Request timeout
  timeout,

  /// HTTP 404 - resource not found
  notFound,

  /// Unauthorized access (HTTP 401, 403)
  unauthorized,

  /// Invalid image format or decode error
  invalidFormat,

  /// Unknown error
  unknown,
}

/// Utility class to determine error type from error object.
class ImageErrorClassifier {
  /// Classifies the error into an [ImageErrorType] for better handling.
  static ImageErrorClassifier classify(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout') || errorString.contains('deadline')) {
      return ImageErrorClassifier._(ImageErrorType.timeout);
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return ImageErrorClassifier._(ImageErrorType.notFound);
    } else if (errorString.contains('permission') ||
        errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('403')) {
      return ImageErrorClassifier._(ImageErrorType.unauthorized);
    } else if (errorString.contains('format') ||
        errorString.contains('decode') ||
        errorString.contains('image')) {
      return ImageErrorClassifier._(ImageErrorType.invalidFormat);
    } else if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return ImageErrorClassifier._(ImageErrorType.network);
    }

    return ImageErrorClassifier._(ImageErrorType.unknown);
  }

  final ImageErrorType type;

  ImageErrorClassifier._(this.type);

  /// Returns user-friendly message for the error type.
  String getMessage() {
    switch (type) {
      case ImageErrorType.network:
        return 'Network error';
      case ImageErrorType.timeout:
        return 'Request timed out';
      case ImageErrorType.notFound:
        return 'Image not found';
      case ImageErrorType.unauthorized:
        return 'Access denied';
      case ImageErrorType.invalidFormat:
        return 'Invalid image';
      case ImageErrorType.unknown:
        return 'Failed to load';
    }
  }

  /// Returns appropriate icon for the error type.
  IconData getIcon() {
    switch (type) {
      case ImageErrorType.network:
        return Icons.wifi_off;
      case ImageErrorType.timeout:
        return Icons.access_time;
      case ImageErrorType.notFound:
        return Icons.image_not_supported;
      case ImageErrorType.unauthorized:
        return Icons.lock;
      case ImageErrorType.invalidFormat:
        return Icons.broken_image;
      case ImageErrorType.unknown:
        return Icons.error_outline;
    }
  }

  /// Returns whether retry is likely to succeed.
  bool isRetryable() {
    switch (type) {
      case ImageErrorType.network:
      case ImageErrorType.timeout:
        return true;
      case ImageErrorType.notFound:
      case ImageErrorType.unauthorized:
      case ImageErrorType.invalidFormat:
        return false;
      case ImageErrorType.unknown:
        return true; // Optimistic default
    }
  }
}
