import 'package:flutter/material.dart';
import '../features/travel/domain/repositories/trip_repository.dart';
import '../features/travel/domain/repositories/activity_repository.dart';
import '../core/models/paginated_data.dart';
import '../features/travel/domain/models/trip.dart';
import '../features/travel/domain/models/activity.dart';
import 'debounce.dart';
import 'query_batcher.dart';

/// Example 1: Basic search debouncing
///
/// Demonstrates how to debounce search queries to avoid excessive API calls
class Example1BasicSearchDebouncing extends StatefulWidget {
  final TripRepository tripRepository;

  const Example1BasicSearchDebouncing({
    super.key,
    required this.tripRepository,
  });

  @override
  State<Example1BasicSearchDebouncing> createState() =>
      _Example1BasicSearchDebouncingState();
}

class _Example1BasicSearchDebouncingState
    extends State<Example1BasicSearchDebouncing> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer<PaginatedData<Trip>>(
    duration: const Duration(milliseconds: 500),
  );

  List<Trip> _searchResults = [];
  bool _isSearching = false;
  String? _lastExecutedQuery;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _lastExecutedQuery = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debouncer.debounce(
      input: query,
      action: () async {
        return await widget.tripRepository.searchTrips(
          userId: 'user123',
          query: query,
          pageSize: 20,
        );
      },
      onCompleteOverride: (result) {
        if (mounted && result.executed) {
          setState(() {
            _searchResults = result.value?.items ?? [];
            _lastExecutedResult = result.input;
            _isSearching = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Debouncing Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Search trips',
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
                hintText: 'Enter destination or trip name...',
              ),
            ),
          ),
          if (_lastExecutedResult != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Results for: "$_lastExecutedResult"',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final trip = _searchResults[index];
                return ListTile(
                  title: Text(trip.title),
                  subtitle: Text(trip.destination),
                  leading: const Icon(Icons.flight),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 2: Filter debouncing
///
/// Demonstrates how to debounce multiple filter changes
class Example2FilterDebouncing extends StatefulWidget {
  final ActivityRepository activityRepository;

  const Example2FilterDebouncing({
    super.key,
    required this.activityRepository,
  });

  @override
  State<Example2FilterDebouncing> createState() =>
      _Example2FilterDebouncingState();
}

class _Example2FilterDebouncingState extends State<Example2FilterDebouncing> {
  final _debouncer = Debouncer<PaginatedData<Activity>>(
    duration: const Duration(milliseconds: 300),
    debug: false,
  );

  List<Activity> _activities = [];
  bool _isLoading = false;

  // Filter state
  String? _selectedCategory;
  String? _selectedPriority;
  bool _showCompletedOnly = false;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    // Build unique filter key
    final filterKey = '${_selectedCategory ?? 'all'}-'
        '${_selectedPriority ?? 'all'}-'
        '${_showCompletedOnly ? 'completed' : 'all'}';

    _debouncer.debounce(
      input: filterKey,
      action: () async {
        // Build filter map
        final filters = <String, dynamic>{};
        if (_selectedCategory != null) {
          filters['category'] = _selectedCategory;
        }
        if (_selectedPriority != null) {
          filters['priority'] = _selectedPriority;
        }
        if (_showCompletedOnly) {
          filters['isCompleted'] = true;
        }

        return await widget.activityRepository.getActivitiesCursor(
          tripId: 'trip123',
          filters: filters.isNotEmpty ? filters : null,
          pageSize: 50,
        );
      },
      onCompleteOverride: (result) {
        if (mounted && result.executed) {
          setState(() {
            _activities = result.value?.items ?? [];
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Debouncing Example')),
      body: Column(
        children: [
          // Category filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Categories')),
                DropdownMenuItem(value: 'food', child: Text('Food')),
                DropdownMenuItem(value: 'transport', child: Text('Transport')),
                DropdownMenuItem(
                    value: 'accommodation', child: Text('Accommodation')),
                DropdownMenuItem(value: 'activity', child: Text('Activity')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                _applyFilters();
              },
            ),
          ),

          // Priority filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Priorities')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
                _applyFilters();
              },
            ),
          ),

          // Completed filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CheckboxListTile(
              title: const Text('Show completed only'),
              value: _showCompletedOnly,
              onChanged: (value) {
                setState(() {
                  _showCompletedOnly = value ?? false;
                });
                _applyFilters();
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          // Results
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  title: Text(activity.title),
                  subtitle: Text(activity.category.name),
                  trailing: activity.isCompleted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.circle_outlined),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Basic query batching
///
/// Demonstrates how to batch multiple queries together
class Example3BasicBatching extends StatefulWidget {
  final TripRepository tripRepository;
  final ActivityRepository activityRepository;

  const Example3BasicBatching({
    super.key,
    required this.tripRepository,
    required this.activityRepository,
  });

  @override
  State<Example3BasicBatching> createState() =>
      _Example3BasicBatchingState();
}

class _Example3BasicBatchingState extends State<Example3BasicBatching> {
  final _batcher = QueryBatcher(
    config: BatchConfig.defaultConfig,
    debug: false,
  );

  List<Trip> _trips = [];
  List<Activity> _activities = [];
  bool _isLoading = false;
  BatchStatistics? _stats;

  @override
  void dispose() {
    _batcher.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _stats = null;
    });

    try {
      // Add multiple queries to the batch
      final tripsFuture = _batcher.add<List<Trip>>(
        key: 'trips',
        query: () async {
          final result = await widget.tripRepository.getTripsCursor(
            userId: 'user123',
            pageSize: 10,
          );
          return result.items;
        },
      );

      final activitiesFuture = _batcher.add<List<Activity>>(
        key: 'activities',
        query: () async {
          final result = await widget.activityRepository.getActivitiesCursor(
            tripId: 'trip123',
            pageSize: 10,
          );
          return result.items;
        },
      );

      // Execute all queries in the batch
      final results = await _batcher.execute();

      setState(() {
        _trips = results['trips']?.data as List<Trip>? ?? [];
        _activities = results['activities']?.data as List<Activity>? ?? [];
        _isLoading = false;
        _stats = _batcher.statistics;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Query Batching Example')),
      body: Column(
        children: [
          if (_stats != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch Statistics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Total queries: ${_stats!.totalQueries}'),
                      Text('Successful: ${_stats!.successfulQueries}'),
                      Text('Failed: ${_stats!.failedQueries}'),
                      Text('Success rate: ${(_stats!.successRate * 100).toStringAsFixed(1)}%'),
                      Text('Total time: ${_stats!.totalExecutionTime.inMilliseconds}ms'),
                    ],
                  ),
                ),
              ),
            ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _loadDashboardData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Load Dashboard Data'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('Trips (${_trips.length})'),
                    subtitle: _trips.isEmpty
                        ? const Text('No trips')
                        : Text(_trips.take(3).map((t) => t.title).join(', ')),
                  ),
                  ListTile(
                    title: Text('Activities (${_activities.length})'),
                    subtitle: _activities.isEmpty
                        ? const Text('No activities')
                        : Text(_activities.take(3).map((a) => a.title).join(', ')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Example 4: Aggressive batching for dashboard
///
/// Demonstrates aggressive batching configuration for optimal performance
class Example4AggressiveBatching extends StatefulWidget {
  final TripRepository tripRepository;
  final ActivityRepository activityRepository;

  const Example4AggressiveBatching({
    super.key,
    required this.tripRepository,
    required this.activityRepository,
  });

  @override
  State<Example4AggressiveBatching> createState() =>
      _Example4AggressiveBatchingState();
}

class _Example4AggressiveBatchingState
    extends State<Example4AggressiveBatching> {
  late final QueryBatcher _batcher;

  bool _isLoading = false;

  // Dashboard data
  List<Trip> _upcomingTrips = [];
  List<Trip> _pastTrips = [];
  List<Activity> _upcomingActivities = [];
  int _totalTripCount = 0;
  int _totalActivityCount = 0;

  @override
  void initState() {
    super.initState();

    // Use aggressive batching for dashboard
    _batcher = QueryBatcher(
      config: BatchConfig.aggressive,
      debug: false,
      onBatchExecuted: (stats) {
        // Log analytics or update UI with stats
        print('Batch executed: ${stats.totalQueries} queries in '
            '${stats.totalExecutionTime.inMilliseconds}ms');
      },
    );

    _loadDashboard();
  }

  @override
  void dispose() {
    _batcher.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      // Batch multiple queries for dashboard
      final upcomingTripsFuture = _batcher.add<List<Trip>>(
        key: 'upcoming-trips',
        query: () async {
          final result = await widget.tripRepository.getTripsInDateRange(
            userId: 'user123',
            startDate: now,
            endDate: now.add(const Duration(days: 365)),
            pageSize: 5,
          );
          return result.items;
        },
      );

      final pastTripsFuture = _batcher.add<List<Trip>>(
        key: 'past-trips',
        query: () async {
          final result = await widget.tripRepository.getTripsCursor(
            userId: 'user123',
            sortBy: 'startDate',
            sortOrder: SortOrder.descending,
            filters: {'endDate': now.toIso8601String()},
            pageSize: 5,
          );
          return result.items;
        },
      );

      final upcomingActivitiesFuture = _batcher.add<List<Activity>>(
        key: 'upcoming-activities',
        query: () async {
          final result = await widget.activityRepository.getUpcomingActivities(
            tripId: 'trip123',
            pageSize: 5,
          );
          return result.items;
        },
      );

      final tripCountFuture = _batcher.add<int>(
        key: 'trip-count',
        query: () async {
          return await widget.tripRepository.countTrips(
            userId: 'user123',
          );
        },
      );

      final activityCountFuture = _batcher.add<int>(
        key: 'activity-count',
        query: () async {
          return await widget.activityRepository.countActivities(
            tripId: 'trip123',
          );
        },
      );

      // Execute all queries in parallel
      final results = await _batcher.execute();

      setState(() {
        _upcomingTrips = results['upcoming-trips']?.data as List<Trip>? ?? [];
        _pastTrips = results['past-trips']?.data as List<Trip>? ?? [];
        _upcomingActivities =
            results['upcoming-activities']?.data as List<Activity>? ?? [];
        _totalTripCount = results['trip-count']?.data as int? ?? 0;
        _totalActivityCount = results['activity-count']?.data as int? ?? 0;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aggressive Batching Dashboard')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Stats cards
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Trips',
                          value: _totalTripCount.toString(),
                          icon: Icons.flight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Activities',
                          value: _totalActivityCount.toString(),
                          icon: Icons.activity,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Upcoming trips
                _Section(
                  title: 'Upcoming Trips',
                  items: _upcomingTrips
                      .map((trip) => trip.title)
                      .toList(),
                  icon: Icons.upcoming,
                ),

                // Past trips
                _Section(
                  title: 'Recent Trips',
                  items: _pastTrips
                      .map((trip) => trip.title)
                      .toList(),
                  icon: Icons.history,
                ),

                // Upcoming activities
                _Section(
                  title: 'Upcoming Activities',
                  items: _upcomingActivities
                      .map((activity) => activity.title)
                      .toList(),
                  icon: Icons.event,
                ),
              ],
            ),
    );
  }
}

/// Example 5: Combining debouncing and batching
///
/// Demonstrates using both debouncing and batching together
class Example5CombinedDebounceAndBatch extends StatefulWidget {
  final TripRepository tripRepository;
  final ActivityRepository activityRepository;

  const Example5CombinedDebounceAndBatch({
    super.key,
    required this.tripRepository,
    required this.activityRepository,
  });

  @override
  State<Example5CombinedDebounceAndBatch> createState() =>
      _Example5CombinedDebounceAndBatchState();
}

class _Example5CombinedDebounceAndBatchState
    extends State<Example5CombinedDebounceAndBatch> {
  final _debouncer = Debouncer<Map<String, dynamic>>(
    duration: const Duration(milliseconds: 600),
  );

  final _searchController = TextEditingController();

  List<Trip> _trips = [];
  List<Activity> _activities = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _trips = [];
        _activities = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Debounce the search, then batch the queries
    _debouncer.debounce(
      input: query,
      action: () async {
        // Use a temporary batcher for this search
        final batcher = QueryBatcher(
          config: BatchConfig.immediate,
          debug: false,
        );

        // Batch trips and activities search
        final tripsFuture = batcher.add<List<Trip>>(
          key: 'trips-$query',
          query: () async {
            final result = await widget.tripRepository.searchTrips(
              userId: 'user123',
              query: query,
              pageSize: 10,
            );
            return result.items;
          },
        );

        final activitiesFuture = batcher.add<List<Activity>>(
          key: 'activities-$query',
          query: () async {
            final result = await widget.activityRepository.searchActivities(
              tripId: 'trip123',
              query: query,
              pageSize: 10,
            );
            return result.items;
          },
        );

        // Execute batch
        final results = await batcher.execute();

        return {
          'trips': results['trips-$query']?.data as List<Trip>? ?? [],
          'activities': results['activities-$query']?.data as List<Activity>? ?? [],
        };
      },
      onCompleteOverride: (result) {
        if (mounted && result.executed) {
          setState(() {
            _trips = result.value?['trips'] as List<Trip>? ?? [];
            _activities = result.value?['activities'] as List<Activity>? ?? [];
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Combined Debounce + Batch')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'Search everything',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: ListView(
              children: [
                if (_trips.isNotEmpty) ...[
                  const ListTile(
                    title: Text('Trips',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ..._trips.map((trip) => ListTile(
                        title: Text(trip.title),
                        subtitle: Text(trip.destination),
                        leading: const Icon(Icons.flight),
                      )),
                ],
                if (_activities.isNotEmpty) ...[
                  const ListTile(
                    title: Text('Activities',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ..._activities.map((activity) => ListTile(
                        title: Text(activity.title),
                        subtitle: Text(activity.category.name),
                        leading: const Icon(Icons.event),
                      )),
                ],
                if (_trips.isEmpty && _activities.isEmpty && !_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Search for trips or activities...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widgets

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;

  const _Section({
    required this.title,
    required this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('No items', style: TextStyle(color: Colors.grey)),
          )
        else
          ...items.map((item) => ListTile(
                title: Text(item),
                contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              )),
      ],
    );
  }
}
