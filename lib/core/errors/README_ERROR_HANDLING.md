# Enhanced Error Handling System

Comprehensive error handling system with user-friendly error messages, recovery options, and centralized error management for the SoloAdventurer travel journal app.

## Overview

This enhanced error handling system provides:

- **User-Friendly Error Messages**: Clear, actionable messages instead of technical jargon
- **Recovery Options**: Built-in actions for common error scenarios (retry, dismiss, report, etc.)
- **Centralized Error Handler**: Singleton service for managing all errors
- **Error History**: Track and analyze errors over time
- **UI Components**: Pre-built widgets and dialogs for displaying errors
- **Severity Levels**: Categorize errors by impact (info, warning, error, critical)
- **Contextual Information**: Attach relevant data to errors for debugging

## Architecture

### Core Components

1. **AppError** (`app_error.dart`): Rich error model with user messages and recovery actions
2. **ErrorHandler** (`error_handler.dart`): Centralized error management service
3. **ErrorDisplayWidget** (`error_display_widget.dart`): Reusable error display components
4. **ErrorDialog** (`error_dialog.dart`): Full-screen error dialogs and bottom sheets

### Error Types

The system categorizes errors by severity:

- **Info**: Informational messages (not errors)
- **Warning**: Warnings that something might be wrong
- **Error**: Errors that prevent an action
- **Critical**: Critical errors requiring immediate attention

## Installation

The error handling system is already integrated into the app. No additional dependencies required.

## Usage

### Basic Error Handling

```dart
import 'package:soloadventurer/core/errors/error_handler.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

try {
  await someOperation();
} catch (e, stackTrace) {
  final error = ErrorHandler().handleException(
    e,
    stackTrace: stackTrace,
    context: {'operation': 'someOperation'},
  );

  // Display error to user
  ErrorDialog.show(context, error);
}
```

### Creating AppError from Exception

```dart
import 'package:soloadventurer/core/errors/app_error.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

// From AppException
final authException = UnauthorizedException('Session expired');
final error = AppError.fromException(authException);

// From generic Exception
final genericError = AppError.fromGenericException(
  Exception('Something went wrong'),
  message: 'Custom user message',
);

// Using factory constructors
final networkError = AppError.network(
  message: 'Unable to connect',
  exception: e,
);

final timeoutError = AppError.timeout();
final authError = AppError.auth();
final storageError = AppError.storage();
```

### Using ErrorHandler Service

```dart
import 'package:soloadventurer/core/errors/error_handler.dart';

// Initialize (in main.dart)
ErrorHandler().initialize(
  const ErrorHandlerConfig(
    showAutoDialogs: true,
    enableLogging: true,
    maxHistorySize: 100,
  ),
);

// Register action callbacks
ErrorHandler().registerActionCallback(
  ErrorAction.retry,
  (action) async {
    // Retry logic
    await retryOperation();
  },
);

// Handle exceptions
try {
  await operation();
} catch (e, stackTrace) {
  ErrorHandler().handleException(
    e,
    stackTrace: stackTrace,
    context: {'userId': userId},
  );
}

// Get error statistics
final stats = ErrorHandler().getStatistics();
print('Total errors: ${stats['total']}');
print('By severity: ${stats['error']}');

// Export error report
final report = ErrorHandler().createErrorReport();
print(report);

// Clear history
ErrorHandler().clearHistory();
```

### Displaying Errors

#### Error Dialog

```dart
import 'package:soloadventurer/core/presentation/widgets/error_dialog.dart';

// Show dialog with action callbacks
await ErrorDialog.show(
  context,
  error,
  onAction: (action) {
    switch (action) {
      case ErrorAction.retry:
        // Retry operation
        break;
      case ErrorAction.dismiss:
        // Dismiss error
        break;
      case ErrorAction.report:
        // Report error
        break;
    }
  },
);

// With custom configuration
await ErrorDialog.show(
  context,
  error,
  config: const ErrorDisplayConfig(
    showIcon: true,
    showCode: true,
    showTechnicalDetails: true,
  ),
);
```

#### Error Bottom Sheet

```dart
import 'package:soloadventurer/core/presentation/widgets/error_dialog.dart';

await ErrorBottomSheet.show(
  context,
  error,
  onAction: (action) => handleAction(action),
);
```

#### Error Banner

```dart
import 'package:soloadventurer/core/presentation/widgets/error_display_widget.dart';

ScaffoldMessenger.of(context).showMaterialBanner(
  MaterialBanner(
    content: ErrorBannerWidget(
      error: error,
      onAction: (action) => handleAction(action),
      onDismiss: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
    ),
    actions: [],
  ),
);
```

#### Error Card (in lists)

```dart
import 'package:soloadventurer/core/presentation/widgets/error_display_widget.dart';

ListView.builder(
  itemCount: errors.length,
  itemBuilder: (context, index) {
    return ErrorCardWidget(
      error: errors[index],
      onTap: () => showErrorDetails(errors[index]),
      onAction: (action) => handleErrorAction(errors[index], action),
    );
  },
);
```

#### Custom Error Display

```dart
import 'package:soloadventurer/core/presentation/widgets/error_display_widget.dart';

ErrorDisplayWidget(
  error: error,
  config: const ErrorDisplayConfig(
    showIcon: true,
    showCode: false,
    showTechnicalDetails: true,
  ),
  onAction: (action) {
    print('User selected: $action');
  },
)
```

### Error Recovery Actions

The system provides built-in recovery actions:

- **retry**: Retry the failed operation
- **cancel**: Cancel the operation
- **dismiss**: Dismiss the error message
- **report**: Report the error to support
- **reauthenticate**: Log out and log back in
- **checkConnection**: Check network connection
- **freeStorage**: Free up storage space
- **updateApp**: Update the app
- **contactSupport**: Contact customer support
- **viewDetails**: View detailed error information
- **clearCache**: Clear app cache

### Error Context

Attach contextual information to errors for better debugging:

```dart
try {
  await uploadMedia(file);
} catch (e) {
  ErrorHandler().handleException(
    e,
    stackTrace: stackTrace,
    context: {
      'fileName': file.name,
      'fileSize': file.length,
      'uploadId': uploadId,
      'userId': userId,
    },
  );
}
```

### Error Streams

Listen to errors in real-time:

```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  void initState() {
    super.initState();

    // Listen to error stream
    ErrorHandler().errorStream.listen((error) {
      // React to errors
      if (error.severity == ErrorSeverity.critical) {
        showCriticalErrorNotification(error);
      }
    });
  }
}
```

## Error Messages by Type

The system provides user-friendly messages for common errors:

### Network Errors
- **NetworkTimeoutException**: "Request timed out. Please check your connection and try again."
- **NetworkConnectivityException**: "No internet connection. Please check your network settings."

### Authentication Errors
- **UnauthorizedException**: "Your session has expired. Please log in again."
- **ForbiddenException**: "You don't have permission to perform this action."

### Server Errors
- **ServerException**: "Server error. Please try again later."

### Storage Errors
- **MediaCompressionException**: "Failed to process media file. It may be corrupted or in an unsupported format."

### Location Errors
- **LocationException**: "Unable to get location. Please check your permissions."
- **GeocodingException**: "Unable to find location. Please try a different search."

## Error Severity Guide

### Info
- **Use Case**: Informational messages that are not errors
- **Actions**: Usually just dismiss
- **Icon**: Info icon (blue)

### Warning
- **Use Case**: Issues that might cause problems but don't prevent functionality
- **Actions**: Dismiss or optional action
- **Icon**: Warning icon (orange)
- **Examples**: Location permission denied, weak network

### Error
- **Use Case**: Errors that prevent an action but are recoverable
- **Actions**: Retry, dismiss, report
- **Icon**: Error icon (red)
- **Examples**: Network timeout, validation failed

### Critical
- **Use Case**: Severe errors that require immediate attention
- **Actions**: Contact support, report
- **Icon**: Dangerous icon (dark red)
- **Examples**: Database corruption, app crash

## Best Practices

### DO
-  Use specific exception types (e.g., `NetworkTimeoutException` instead of generic `Exception`)
-  Provide contextual information with every error
-  Offer recovery actions when possible
-  Log errors for debugging and analytics
-  Show user-friendly messages, not technical details
-  Use severity levels appropriately
-  Handle errors gracefully with fallback behavior
-  Test error scenarios in development

### DON'T
- L Expose stack traces to end users
- L Swallow errors without logging or handling
- L Show technical error codes to users (unless debugging)
- L Use critical severity for minor issues
- L Ignore error context
- L Block UI with non-dismissible error dialogs
- L Overwhelm users with too many recovery options
- L Repeat the same error multiple times

## Advanced Usage

### Custom Error Types

```dart
class CustomException extends AppException {
  final String customField;

  const CustomException({
    required super.message,
    required this.customField,
    super.code,
  });
}

// Custom error handler
final customError = AppError(
  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
  message: 'Custom error message',
  code: 'custom_error',
  severity: ErrorSeverity.error,
  availableActions: [ErrorAction.retry, ErrorAction.contactSupport],
  primaryAction: ErrorAction.contactSupport,
  context: {'customField': customField},
);
```

### Error Analytics

```dart
class ErrorAnalytics {
  void analyzeErrors() {
    final stats = ErrorHandler().getStatistics();

    // Most common errors
    final byCode = stats['byCode'] as Map<String, int>;
    final sortedErrors = byCode.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    print('Top 5 errors:');
    for (final entry in sortedErrors.take(5)) {
      print('  ${entry.key}: ${entry.value} occurrences');
    }

    // Error rate
    final totalErrors = stats['total'] as int;
    final recoverable = stats['recoverable'] as int;
    final recoverableRate = (recoverable / totalErrors * 100).toStringAsFixed(1);
    print('Recoverable error rate: $recoverableRate%');

    // Recent errors
    final recentErrors = ErrorHandler().getErrorsInTimeRange(
      DateTime.now().subtract(const Duration(hours: 24)),
      DateTime.now(),
    );
    print('Errors in last 24 hours: ${recentErrors.length}');
  }
}
```

### Integration with State Management

```dart
// Riverpod example
final errorProvider = StreamProvider<AppError>((ref) {
  return ErrorHandler().errorStream;
});

class ErrorListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorAsync = ref.watch(errorProvider);

    return errorAsync.when(
      data: (error) {
        // Show error dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ErrorDialog.show(context, error);
        });
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

## Troubleshooting

### Errors not displaying
- Ensure `ErrorHandler().initialize()` is called in `main.dart`
- Check that context is valid when showing dialogs
- Verify error stream listeners are properly set up

### Action callbacks not executing
- Ensure callbacks are registered before errors occur
- Check that callbacks are async if they perform async operations
- Verify callback registration uses correct `ErrorAction` enum values

### Error history growing too large
- Reduce `maxHistorySize` in `ErrorHandlerConfig`
- Call `ErrorHandler().clearHistory()` periodically
- Implement error history pruning based on time

## Testing

### Unit Testing Error Handling

```dart
test('should handle network error', () {
  final exception = NetworkTimeoutException(
    message: 'Connection timed out',
  );

  final error = AppError.fromException(exception);

  expect(error.severity, ErrorSeverity.warning);
  expect(error.code, 'network_timeout');
  expect(error.availableActions, contains(ErrorAction.retry));
});

test('should execute error action', () async {
  var actionExecuted = false;

  ErrorHandler().registerActionCallback(
    ErrorAction.retry,
    (action) async {
      actionExecuted = true;
    },
  );

  final result = await ErrorHandler().executeAction(ErrorAction.retry);

  expect(result.success, true);
  expect(actionExecuted, true);
});
```

## Migration from Old Error Handling

### Before
```dart
try {
  await operation();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.toString()}')),
  );
}
```

### After
```dart
try {
  await operation();
} catch (e, stackTrace) {
  final error = ErrorHandler().handleException(e, stackTrace: stackTrace);
  await ErrorDialog.show(context, error, onAction: (action) {
    if (action == ErrorAction.retry) {
      // Retry logic
    }
  });
}
```

## API Reference

### AppError
- `id`: Unique error identifier
- `message`: User-friendly error message
- `technicalMessage`: Technical details for debugging
- `code`: Error code for categorization
- `severity`: ErrorSeverity level
- `availableActions`: List of recovery options
- `primaryAction`: Recommended action
- `isRecoverable`: Whether error is recoverable
- `exception`: Underlying exception
- `context`: Additional contextual data

### ErrorHandler
- `initialize()`: Initialize error handler
- `handleException()`: Convert exception to AppError
- `handleError()`: Process AppError
- `registerActionCallback()`: Register action handler
- `executeAction()`: Execute recovery action
- `getStatistics()`: Get error statistics
- `createErrorReport()`: Generate error report
- `clearHistory()`: Clear error history

### ErrorAction
Enum of available recovery actions (retry, cancel, dismiss, report, etc.)

### ErrorSeverity
Enum of severity levels (info, warning, error, critical)

## Future Enhancements

- [ ] Integration with crash reporting services (Sentry, Firebase Crashlytics)
- [ ] Error grouping and deduplication
- [ ] Automated error reporting to support
- [ ] User feedback on errors
- [ ] Error recovery suggestions based on history
- [ ] Offline error caching and sync
- [ ] Error rate monitoring and alerts
- [ ] Custom error themes per severity
- [ ] Internationalization support for error messages

## Related Files

- `lib/core/errors/app_error.dart`: Core error model
- `lib/core/errors/error_handler.dart`: Error management service
- `lib/core/errors/exceptions.dart`: Exception definitions
- `lib/core/presentation/widgets/error_display_widget.dart`: UI components
- `lib/core/presentation/widgets/error_dialog.dart`: Dialog components

## Support

For questions or issues related to error handling, please contact the development team or create an issue in the project repository.
