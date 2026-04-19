import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';

/// Provider for the AnalyticsService
///
/// Defaults to DebugAnalyticsService in debug mode.
/// Override in bootstrap with a real implementation (PostHog, Firebase) for production.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return DebugAnalyticsService();
});
