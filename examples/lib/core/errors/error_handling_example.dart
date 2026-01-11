import 'package:flutter/material.dart';
import 'package:soloadventurer/core/errors/app_error.dart';
import 'package:soloadventurer/core/errors/error_handler.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/presentation/widgets/error_dialog.dart';
import 'package:soloadventurer/core/presentation/widgets/error_display_widget.dart';

/// Example 1: Basic error handling with try-catch
class Example1_BasicErrorHandling extends StatelessWidget {
  const Example1_BasicErrorHandling({super.key});

  Future<void> _performOperation(BuildContext context) async {
    try {
      // Simulate an operation that might fail
      throw const NetworkTimeoutException(
        message: 'Connection timed out after 30 seconds',
      );
    } catch (e, stackTrace) {
      // Handle exception and convert to AppError
      final error = ErrorHandler().handleException(
        e,
        stackTrace: stackTrace,
        context: {'operation': 'fetchJournalEntries'},
      );

      // Show error dialog
      if (context.mounted) {
        await ErrorDialog.show(
          context,
          error,
          onAction: (action) {
            print('User selected action: $action');
            if (action == ErrorAction.retry) {
              _performOperation(context);
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Error Handling')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _performOperation(context),
          child: const Text('Trigger Error'),
        ),
      ),
    );
  }
}

/// Example 2: Creating custom AppError instances
class Example2_CustomErrors extends StatelessWidget {
  const Example2_CustomErrors({super.key});

  void _showNetworkError(BuildContext context) {
    final error = AppError.network(
      message: 'Unable to connect to server',
      exception: const SocketException('Connection refused'),
      context: {'url': 'https://api.example.com/data'},
    );

    ErrorDialog.show(context, error);
  }

  void _showValidationError(BuildContext context) {
    final error = AppError.validation(
      message: 'Please fix the following issues',
      errors: {
        'title': ['Title is required', 'Title must be at least 3 characters'],
        'content': ['Content cannot be empty'],
      },
      context: {'field': 'title'},
    );

    ErrorDialog.show(context, error);
  }

  void _showAuthError(BuildContext context) {
    final error = AppError.auth(
      message: 'Your session has expired',
      exception: const UnauthorizedException('Invalid token'),
    );

    ErrorDialog.show(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Errors')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => _showNetworkError(context),
            child: const Text('Network Error'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showValidationError(context),
            child: const Text('Validation Error'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showAuthError(context),
            child: const Text('Auth Error'),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Error display widgets
class Example3_ErrorDisplayWidgets extends StatelessWidget {
  const Example3_ErrorDisplayWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final errors = [
      AppError.network(
        message: 'No internet connection',
        context: {'timestamp': DateTime.now().toIso8601String()},
      ),
      AppError.mediaCompression(
        message: 'Failed to compress image',
        context: {'fileName': 'photo.jpg', 'fileSize': '5.2MB'},
      ),
      AppError.location(
        message: 'Location permissions denied',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Error Display Widgets')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: errors.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ErrorDisplayWidget(
              error: errors[index],
              onAction: (action) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action: ${action.name}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Example 4: Error cards in a list
class Example4_ErrorCards extends StatefulWidget {
  const Example4_ErrorCards({super.key});

  @override
  State<Example4_ErrorCards> createState() => _Example4_ErrorCardsState();
}

class _Example4_ErrorCardsState extends State<Example4_ErrorCards> {
  final List<AppError> _errors = [];

  void _addError() {
    setState(() {
      _errors.add(AppError.server(
        message: 'Server error occurred',
        context: {'timestamp': DateTime.now().toIso8601String()},
      ));
    });
  }

  void _clearErrors() {
    setState(() {
      _errors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Cards'),
        actions: [
          IconButton(
            onPressed: _addError,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _clearErrors,
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: _errors.isEmpty
          ? const Center(
              child: Text('No errors. Tap + to add one.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _errors.length,
              itemBuilder: (context, index) {
                return ErrorCardWidget(
                  error: _errors[index],
                  onTap: () {
                    ErrorDialog.show(context, _errors[index]);
                  },
                  onAction: (action) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Action: ${action.name}')),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// Example 5: Error statistics and history
class Example5_ErrorStatistics extends StatefulWidget {
  const Example5_ErrorStatistics({super.key});

  @override
  State<Example5_ErrorStatistics> createState() =>
      _Example5_ErrorStatisticsState();
}

class _Example5_ErrorStatisticsState extends State<Example5_ErrorStatistics> {
  @override
  Widget build(BuildContext context) {
    final stats = ErrorHandler().getStatistics();
    final history = ErrorHandler().history;

    return Scaffold(
      appBar: AppBar(title: const Text('Error Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _StatCard(
            label: 'Total Errors',
            value: '${stats['total']}',
          ),
          _StatCard(
            label: 'Recoverable',
            value: '${stats['recoverable']}',
          ),
          _StatCard(
            label: 'Non-Recoverable',
            value: '${stats['nonRecoverable']}',
          ),
          const Divider(height: 32),
          Text(
            'By Severity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (final severity in ErrorSeverity.values)
            _StatCard(
              label: severity.name,
              value: '${stats[severity.name]}',
              color: _getSeverityColor(severity),
            ),
          const Divider(height: 32),
          Text(
            'Recent Errors (${history.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Text('No errors recorded yet.')
          else
            ...history.take(5).map((error) {
              return ListTile(
                leading: Icon(_getSeverityIcon(error.severity)),
                title: Text(error.message),
                subtitle: Text(error.code ?? 'unknown'),
                onTap: () => ErrorDialog.show(context, error),
              );
            }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ErrorHandler().clearHistory();
              setState(() {});
            },
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatCard({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

/// Example 6: Error bottom sheet
class Example6_ErrorBottomSheet extends StatelessWidget {
  const Example6_ErrorBottomSheet({super.key});

  void _showErrorBottomSheet(BuildContext context) {
    final error = AppError.storage(
      message: 'Not enough storage space',
      context: {
        'requiredSpace': '50MB',
        'availableSpace': '10MB',
      },
    );

    ErrorBottomSheet.show(
      context,
      error,
      onAction: (action) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action: ${action.name}')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Bottom Sheet')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showErrorBottomSheet(context),
          child: const Text('Show Error Bottom Sheet'),
        ),
      ),
    );
  }
}

/// Example 7: Custom error handler configuration
class Example7_ErrorHandlerConfig extends StatefulWidget {
  const Example7_ErrorHandlerConfig({super.key});

  @override
  State<Example7_ErrorHandlerConfig> createState() =>
      _Example7_ErrorHandlerConfigState();
}

class _Example7_ErrorHandlerConfigState
    extends State<Example7_ErrorHandlerConfig> {
  bool _loggingEnabled = true;
  int _maxHistorySize = 100;

  void _updateConfig() {
    ErrorHandler().initialize(
      ErrorHandlerConfig(
        enableLogging: _loggingEnabled,
        maxHistorySize: _maxHistorySize,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handler Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable Logging'),
            subtitle: const Text('Log errors to console'),
            value: _loggingEnabled,
            onChanged: (value) {
              setState(() {
                _loggingEnabled = value;
              });
              _updateConfig();
            },
          ),
          ListTile(
            title: const Text('Max History Size'),
            subtitle: Text('$_maxHistorySize errors'),
            trailing: DropdownButton<int>(
              value: _maxHistorySize,
              items: [50, 100, 200, 500].map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('$size'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _maxHistorySize = value;
                  });
                  _updateConfig();
                }
              },
            ),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () {
              // Trigger a test error
              ErrorHandler().handleException(
                Exception('Test error'),
                context: {'test': true},
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test error logged')),
              );
            },
            child: const Text('Test Error Logging'),
          ),
        ],
      ),
    );
  }
}

/// Example 8: Error action callbacks
class Example8_ErrorActions extends StatefulWidget {
  const Example8_ErrorActions({super.key});

  @override
  State<Example8_ErrorActions> createState() => _Example8_ErrorActionsState();
}

class _Example8_ErrorActionsState extends State<Example8_ErrorActions> {
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();

    // Register custom action callbacks
    ErrorHandler().registerActionCallback(
      ErrorAction.retry,
      (action) async {
        setState(() {
          _retryCount++;
        });
        print('Retrying operation (attempt $_retryCount)');
        // Simulate retry logic
        await Future.delayed(const Duration(seconds: 1));
      },
    );

    ErrorHandler().registerActionCallback(
      ErrorAction.report,
      (action) async {
        print('Reporting error to support...');
        // Simulate report submission
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error report submitted')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Actions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Retry count: $_retryCount'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final error = AppError.network(
                  message: 'Connection failed',
                  context: {'retryCount': _retryCount},
                );
                ErrorDialog.show(context, error);
              },
              child: const Text('Trigger Network Error'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 9: Error stream listener
class Example9_ErrorStream extends StatefulWidget {
  const Example9_ErrorStream({super.key});

  @override
  State<Example9_ErrorStream> createState() => _Example9_ErrorStreamState();
}

class _Example9_ErrorStreamState extends State<Example9_ErrorStream> {
  final List<AppError> _recentErrors = [];
  StreamSubscription<AppError>? _subscription;

  @override
  void initState() {
    super.initState();

    // Listen to error stream
    _subscription = ErrorHandler().errorStream.listen((error) {
      setState(() {
        _recentErrors.add(error);
        // Keep only last 10 errors
        if (_recentErrors.length > 10) {
          _recentErrors.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _triggerError() {
    ErrorHandler().handleException(
      Exception('Stream test error'),
      context: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Stream Listener')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _triggerError,
            child: const Text('Trigger Error'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _recentErrors.isEmpty
                ? const Center(child: Text('No errors yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _recentErrors.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_recentErrors[index].message),
                        subtitle: Text(
                          _recentErrors[index].timestamp.toString(),
                        ),
                        leading: Icon(
                          _getSeverityIcon(_recentErrors[index].severity),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }
}

/// Example 10: Error export and reporting
class Example10_ErrorExport extends StatelessWidget {
  const Example10_ErrorExport({super.key});

  void _exportErrorReport(BuildContext context) {
    final report = ErrorHandler().createErrorReport();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Report'),
        content: SingleChildScrollView(
          child: Text(report),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy to clipboard
              // Clipboard.setData(ClipboardData(text: report));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportAsJson(BuildContext context) {
    final json = ErrorHandler().exportErrorsAsJson();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error JSON'),
        content: SingleChildScrollView(
          child: Text(json),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => _exportErrorReport(context),
            child: const Text('Export Error Report'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _exportAsJson(context),
            child: const Text('Export as JSON'),
          ),
        ],
      ),
    );
  }
}

/// Main menu for all error handling examples
class ErrorHandlingExamplesMenu extends StatelessWidget {
  const ErrorHandlingExamplesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      ('Basic Error Handling', const Example1_BasicErrorHandling()),
      ('Custom Errors', const Example2_CustomErrors()),
      ('Error Display Widgets', const Example3_ErrorDisplayWidgets()),
      ('Error Cards', const Example4_ErrorCards()),
      ('Error Statistics', const Example5_ErrorStatistics()),
      ('Error Bottom Sheet', const Example6_ErrorBottomSheet()),
      ('Error Handler Config', const Example7_ErrorHandlerConfig()),
      ('Error Actions', const Example8_ErrorActions()),
      ('Error Stream', const Example9_ErrorStream()),
      ('Error Export', const Example10_ErrorExport()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Error Handling Examples')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: examples.length,
        itemBuilder: (context, index) {
          final (title, widget) = examples[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(title),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => widget),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
