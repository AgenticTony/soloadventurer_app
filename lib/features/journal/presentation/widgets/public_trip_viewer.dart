import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import 'package:soloadventurer/features/journal/presentation/providers/shared_link_providers.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';

/// Screen for viewing a publicly shared trip
class PublicTripViewer extends ConsumerStatefulWidget {
  final String slug;

  const PublicTripViewer({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<PublicTripViewer> createState() => _PublicTripViewerState();
}

class _PublicTripViewerState extends ConsumerState<PublicTripViewer> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Automatically validate access on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAccess();
    });
  }

  Future<void> _validateAccess([String? password]) async {
    final notifier = ref.read(validateLinkNotifierProvider.notifier);
    await notifier.validateAccess(
      slug: widget.slug,
      password: password,
    );
  }

  void _submitPassword() {
    final password = _passwordController.text;
    if (password.isNotEmpty) {
      _validateAccess(password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validateState = ref.watch(validateLinkNotifierProvider);

    return Scaffold(
      body: validateState.when(
        data: (state) {
          // Validation in progress
          if (state.isValidating) {
            return _LoadingView();
          }

          // Requires password
          if (state.result != null &&
              state.result!.requiresPassword &&
              !state.result!.isAccessible) {
            return _PasswordView(
              onSubmit: _submitPassword,
              controller: _passwordController,
            );
          }

          // Error
          if (state.result != null && !state.result!.isAccessible) {
            return _ErrorView(result: state.result!);
          }

          // Success - load trip
          if (state.result != null && state.result!.isAccessible) {
            return _TripContentView(tripId: state.result!.tripId);
          }

          // Initial state
          return _LoadingView();
        },
        loading: () => _LoadingView(),
        error: (error, stack) => _ErrorView(
          result: SharedLinkAccessResult.notFound(),
          customError: error.toString(),
        ),
      ),
    );
  }
}

/// Loading view while validating
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading shared trip...'),
        ],
      ),
    );
  }
}

/// Password prompt view
class _PasswordView extends StatelessWidget {
  final VoidCallback onSubmit;
  final TextEditingController controller;

  const _PasswordView({
    required this.onSubmit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Password Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'This trip is protected with a password. '
                  'Enter the password to view it.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => onSubmit(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSubmit,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error view for expired/invalid links
class _ErrorView extends StatelessWidget {
  final SharedLinkAccessResult result;
  final String? customError;

  const _ErrorView({
    required this.result,
    this.customError,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;
    String message;

    if (result.isExpired) {
      icon = Icons.timer_off;
      title = 'Link Expired';
      message = result.errorMessage ?? 'This shared link has expired.';
    } else if (result.errorMessage?.contains('Invalid password') ?? false) {
      icon = Icons.error_outline;
      title = 'Invalid Password';
      message = 'The password you entered is incorrect. Please try again.';
    } else {
      icon = Icons.link_off;
      title = 'Link Not Found';
      message = customError ??
          result.errorMessage ??
          'This shared link is not valid or has been deactivated.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trip content view when access is granted
class _TripContentView extends ConsumerWidget {
  final String tripId;

  const _TripContentView({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Trip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _TripInfoDialog(tripId: tripId),
              );
            },
          ),
        ],
      ),
      body: tripAsync.when(
        data: (trip) {
          return CustomScrollView(
            slivers: [
              // Cover image
              if (trip.coverImageUrl != null)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 250,
                    child: Image.network(
                      trip.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.travel_explore, size: 64),
                        );
                      },
                    ),
                  ),
                ),

              // Trip details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (trip.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          trip.description!,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        children: [
                          if (trip.destination != null)
                            _InfoChip(
                              icon: Icons.location_on,
                              label: trip.destination!,
                            ),
                          _InfoChip(
                            icon: Icons.calendar_today,
                            label:
                                _formatDateRange(trip.startDate, trip.endDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Journal Entries',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),

              // Journal entries
              // In a real implementation, this would load and display journal entries
              // For now, show a placeholder
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Journal entries will be displayed here',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error loading trip: $error'),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    String format(DateTime date) => '${date.month}/${date.day}/${date.year}';
    if (end == null) {
      return '${format(start)} - Present';
    }
    return '${format(start)} - ${format(end)}';
  }
}

/// Dialog showing trip sharing info
class _TripInfoDialog extends StatelessWidget {
  final String tripId;

  const _TripInfoDialog({required this.tripId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Shared Trip'),
      content: const Text(
        'You are viewing a trip that has been shared with you via a public link. '
        'You can view all journal entries and media for this trip.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Simple info chip
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Provider for trip details
final tripDetailProvider =
    Provider.family<Future<Trip>, String>((ref, tripId) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTrip(tripId);
});

/// Provider for trip repository (placeholder - should be in trip_providers.dart)
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  throw UnimplementedError(
      'tripRepositoryProvider should be in trip_providers.dart');
});

/// TripRepository placeholder
class TripRepository {
  Future<Trip> getTrip(String tripId) {
    throw UnimplementedError();
  }
}
