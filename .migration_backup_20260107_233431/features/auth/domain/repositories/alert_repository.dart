import '../entities/security_alert.dart';

/// Repository interface for managing security alerts
abstract class AlertRepository {
  /// Send a security alert through configured channels
  Future<void> sendAlert(SecurityAlert alert);
}
