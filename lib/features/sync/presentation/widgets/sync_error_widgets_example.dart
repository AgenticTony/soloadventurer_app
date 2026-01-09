import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_error_banner.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_error_card.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_error_dialog.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_error_list_view.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_error_toast.dart';

/// Example demonstrating all sync error widgets
///
/// This widget shows various ways to display sync errors
/// with different configurations and use cases.
class SyncErrorWidgetsExample extends StatefulWidget {
  const SyncErrorWidgetsExample({super.key});

  @override
  State<SyncErrorWidgetsExample> createState() => _SyncErrorWidgetsExampleState();
}

class _SyncErrorWidgetsExampleState extends State<SyncErrorWidgetsExample> {
  final List<SyncError> _errors = [];
  bool _showToastExample = false;

  @override
  void initState() {
    super.initState();
    _generateSampleErrors();
  }

  void _generateSampleErrors() {
    final now = DateTime.now();
    _errors.addAll([
      SyncError(
        errorId: 'error_001',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Failed to connect to server: Connection timed out',
        userMessage: 'Network connection issue. Please check your internet connection.',
        suggestion: 'Check your WiFi or mobile data connection and try again.',
        statusCode: 503,
        entityType: 'trip',
        entityId: 'trip_123',
        operationType: 'sync',
        retryCount: 2,
        isRetryable: true,
        occurredAt: now.subtract(const Duration(minutes: 5)),
      ),
      SyncError(
        errorId: 'error_002',
        type: SyncErrorType.authentication,
        severity: SyncErrorSeverity.high,
        technicalMessage: 'Authentication token expired',
        userMessage: 'Authentication failed. Please sign in again.',
        suggestion: 'Your session may have expired. Please sign out and sign back in.',
        statusCode: 401,
        entityType: 'profile',
        operationType: 'update',
        retryCount: 0,
        isRetryable: false,
        occurredAt: now.subtract(const Duration(minutes: 10)),
      ),
      SyncError(
        errorId: 'error_003',
        type: SyncErrorType.validation,
        severity: SyncErrorSeverity.high,
        code: 'INVALID_DATE',
        technicalMessage: 'End date is before start date',
        userMessage: 'Invalid trip dates. End date cannot be before start date.',
        suggestion: 'Please check your trip dates and ensure they are correct.',
        entityType: 'trip',
        entityId: 'trip_456',
        operationType: 'create',
        retryCount: 0,
        isRetryable: false,
        occurredAt: now.subtract(const Duration(minutes: 15)),
      ),
      SyncError(
        errorId: 'error_004',
        type: SyncErrorType.timeout,
        severity: SyncErrorSeverity.low,
        technicalMessage: 'Request timed out after 30 seconds',
        userMessage: 'Request timed out. The server took too long to respond.',
        suggestion: 'The server may be busy. Your request will be retried automatically.',
        entityType: 'location',
        operationType: 'update',
        retryCount: 1,
        isRetryable: true,
        occurredAt: now.subtract(const Duration(minutes: 20)),
      ),
      SyncError(
        errorId: 'error_005',
        type: SyncErrorType.server,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Internal server error',
        userMessage: 'Server error. Our team has been notified.',
        suggestion: 'This is usually temporary. Please try again in a few minutes.',
        statusCode: 500,
        entityType: 'travelNote',
        operationType: 'sync',
        retryCount: 3,
        isRetryable: true,
        occurredAt: now.subtract(const Duration(hours: 1)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sync Error Widgets'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Banners'),
              Tab(text: 'Cards'),
              Tab(text: 'List'),
              Tab(text: 'Dialog'),
              Tab(text: 'Toasts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBannersExample(),
            _buildCardsExample(),
            _buildListExample(),
            _buildDialogExample(),
            _buildToastsExample(),
          ],
        ),
      ),
    );
  }

  /// Builds the banners example tab
  Widget _buildBannersExample() {
    if (_errors.isEmpty) {
      return const Center(child: Text('No errors to display'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Single error banner
          SyncErrorBanner(
            error: _errors.first,
            onRetry: () => _showMessage('Retrying error: ${_errors.first.errorId}'),
            onDismiss: () => _showMessage('Banner dismissed'),
            onViewDetails: () => _showErrorDetails(_errors.first),
          ),

          // Multiple errors banner
          if (_errors.length > 1)
            MultipleSyncErrorsBanner(
              errors: _errors,
              onViewAll: () => _showMessage('Viewing all errors'),
              onDismiss: () => _showMessage('Multiple errors banner dismissed'),
            ),
        ],
      ),
    );
  }

  /// Builds the cards example tab
  Widget _buildCardsExample() {
    if (_errors.isEmpty) {
      return const Center(child: Text('No errors to display'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _errors.length,
      itemBuilder: (context, index) {
        final error = _errors[index];
        return SyncErrorCard(
          error: error,
          initiallyExpanded: index == 0,
          onRetry: () => _showMessage('Retrying error: ${error.errorId}'),
          onDismiss: () => _dismissError(error),
          onHelp: () => _showHelp(error),
        );
      },
    );
  }

  /// Builds the list example tab
  Widget _buildListExample() {
    return SyncErrorListView(
      errors: _errors,
      isDismissible: true,
      showFilters: true,
      onRetryError: (error) => _showMessage('Retrying error: ${error.errorId}'),
      onDismissError: (error) => _dismissError(error),
      onHelpError: (error) => _showHelp(error),
      onRetryAll: () => _showMessage('Retrying all retryable errors'),
      onDismissAll: () => _showMessage('Dismissing all errors'),
    );
  }

  /// Builds the dialog example tab
  Widget _buildDialogExample() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tap a button below to show an error dialog',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Show different error types
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showErrorDialog(_errors[0]),
                icon: const Icon(Icons.wifi_off),
                label: const Text('Network Error'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showErrorDialog(_errors[1]),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Auth Error'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showErrorDialog(_errors[2]),
                icon: const Icon(Icons.error_outline),
                label: const Text('Validation Error'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showErrorDialog(_errors[3]),
                icon: const Icon(Icons.access_time),
                label: const Text('Timeout Error'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the toasts example tab
  Widget _buildToastsExample() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Toast Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Simple error
            ElevatedButton(
              onPressed: () {
                SyncErrorToast.showError(
                  context: context,
                  message: 'An error occurred while syncing your data',
                  actionLabel: 'RETRY',
                  onAction: () => _showMessage('Retrying...'),
                );
              },
              child: const Text('Show Simple Error'),
            ),

            const SizedBox(height: 12),

            // Sync error toast
            ElevatedButton(
              onPressed: () {
                SyncErrorToast.showSyncError(
                  context: context,
                  error: _errors[0],
                  onRetry: () => _showMessage('Retrying...'),
                );
              },
              child: const Text('Show Sync Error Toast'),
            ),

            const SizedBox(height: 12),

            // Warning toast
            ElevatedButton(
              onPressed: () {
                SyncErrorToast.showWarning(
                  context: context,
                  message: 'Your sync is taking longer than usual',
                  actionLabel: 'CANCEL',
                  onAction: () => _showMessage('Cancelled'),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
              ),
              child: const Text('Show Warning'),
            ),

            const SizedBox(height: 12),

            // Info toast
            ElevatedButton(
              onPressed: () {
                SyncErrorToast.showInfo(
                  context: context,
                  message: 'Syncing your data in the background...',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
              ),
              child: const Text('Show Info'),
            ),

            const SizedBox(height: 12),

            // Success toast
            ElevatedButton(
              onPressed: () {
                SyncErrorToast.showSuccess(
                  context: context,
                  message: 'Sync completed successfully!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
              ),
              child: const Text('Show Success'),
            ),

            const SizedBox(height: 12),

            // Multiple errors toast
            ElevatedButton(
              onPressed: () {
                SyncErrorToast.showMultipleErrors(
                  context: context,
                  errors: _errors,
                  onViewAll: () => _showMessage('Viewing all errors'),
                );
              },
              child: const Text('Show Multiple Errors'),
            ),

            const SizedBox(height: 12),

            // Clear all
            OutlinedButton(
              onPressed: () {
                SyncErrorToast.clear(context);
                _showMessage('Cleared all toasts');
              },
              child: const Text('Clear All Toasts'),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows an error dialog
  void _showErrorDialog(SyncError error) {
    SyncErrorDialog.show(
      context: context,
      error: error,
      onRetry: () => _showMessage('Retrying error: ${error.errorId}'),
      onHelp: () => _showHelp(error),
    );
  }

  /// Shows error details in a dialog
  void _showErrorDetails(SyncError error) {
    SyncErrorDialog.show(
      context: context,
      error: error,
      onRetry: () => _showMessage('Retrying error: ${error.errorId}'),
    );
  }

  /// Dismisses an error
  void _dismissError(SyncError error) {
    setState(() {
      _errors.remove(error);
    });
    _showMessage('Dismissed error: ${error.errorId}');
  }

  /// Shows help for an error
  void _showHelp(SyncError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Error Type: ${error.type.name}'),
            const SizedBox(height: 8),
            Text('Error Code: ${error.code ?? "N/A"}'),
            const SizedBox(height: 16),
            const Text('For assistance:'),
            const SizedBox(height: 8),
            const Text('• Check our documentation'),
            const Text('• Contact support'),
            const Text('• Visit our community forum'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showMessage('Opening help documentation...');
            },
            child: const Text('View Docs'),
          ),
        ],
      ),
    );
  }

  /// Shows a message in a snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
