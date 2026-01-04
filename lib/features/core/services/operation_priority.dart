import 'dart:math';

/// Operation priority levels for queue processing.
///
/// Operations with higher priority values are processed before operations with
/// lower priority values. Priority levels are designed to ensure critical
/// operations (like SOS) execute immediately, while less important operations
/// (like location updates) are processed when there's no critical work.
///
/// Priority values use exponential spacing (1000, 100, 10, 1) to allow for
/// dynamic priority adjustment and intermediate priorities if needed.
///
/// Example usage:
/// ```dart
/// class EmergencyOperation implements QueueableOperation {
///   @override
///   int get priority => OperationPriority.critical.value;
/// }
///
/// class TripUpdateOperation implements QueueableOperation {
///   @override
///   int get priority => OperationPriority.normal.value;
/// }
/// ```
enum OperationPriority {
  /// Critical priority (1000) - Emergency operations that must execute immediately
  ///
  /// Use for:
  /// - SOS/emergency alerts
  /// - Safety-critical operations
  /// - Time-sensitive security operations
  ///
  /// Critical operations will always be processed before any other priority level.
  critical(value: 1000),

  /// High priority (100) - Important operations that should execute soon
  ///
  /// Use for:
  /// - Authentication operations (login, logout)
  /// - Payment transactions
  /// - User-initiated actions that block other work
  /// - Data synchronization requested by user
  ///
  /// High priority operations are processed after critical but before normal/low.
  high(value: 100),

  /// Normal priority (10) - Standard operations that are important but not urgent
  ///
  /// Use for:
  /// - Trip planning updates
  /// - Travel note creation/updates
  /// - Data synchronization (automatic)
  /// - Content uploads
  ///
  /// Normal priority is the default for most user operations.
  normal(value: 10),

  /// Low priority (1) - Background operations that can be delayed
  ///
  /// Use for:
  /// - Location updates (high frequency, low urgency)
  /// - Analytics tracking
  /// - Background data refresh
  /// - Logging/metrics uploads
  ///
  /// Low priority operations are processed only when no higher priority work exists.
  low(value: 1);

  /// The numeric priority value (higher = more important)
  final int value;

  /// Private constructor for enum values
  const OperationPriority({required this.value});

  /// Get a human-readable description of this priority level
  String get description {
    switch (this) {
      case OperationPriority.critical:
        return 'Critical - Emergency operations';
      case OperationPriority.high:
        return 'High - Important operations';
      case OperationPriority.normal:
        return 'Normal - Standard operations';
      case OperationPriority.low:
        return 'Low - Background operations';
    }
  }

  /// Check if this priority is higher than another
  bool isHigherThan(OperationPriority other) {
    return value > other.value;
  }

  /// Check if this priority is lower than another
  bool isLowerThan(OperationPriority other) {
    return value < other.value;
  }

  /// Check if this is critical priority
  bool get isCritical => this == OperationPriority.critical;

  /// Check if this is high priority or above
  bool get isHighOrAbove => value >= OperationPriority.high.value;

  /// Check if this is normal priority or above
  bool get isNormalOrAbove => value >= OperationPriority.normal.value;

  /// Create a custom priority value for dynamic priority adjustment
  ///
  /// This allows operations to temporarily increase or decrease their priority
  /// based on age or other factors. For example, an old operation might get
  /// a priority boost to prevent starvation.
  ///
  /// Example:
  /// ```dart
  /// int boostedPriority = OperationPriority.normal.boost(by: 5);
  /// // Returns 15 (10 + 5)
  /// ```
  int boost({int by = 1}) {
    return value + by;
  }

  /// Reduce priority value for dynamic priority adjustment
  ///
  /// Example:
  /// ```dart
  /// int reducedPriority = OperationPriority.high.reduce(by: 50);
  /// // Returns 50 (100 - 50)
  /// ```
  int reduce({int by = 1}) {
    return max(1, value - by);
  }
}
