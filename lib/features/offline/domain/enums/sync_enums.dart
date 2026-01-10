enum SyncStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
  conflict,
}

enum SyncErrorType {
  network,
  authentication,
  authorization,
  validation,
  conflict,
  server,
  timeout,
  unknown,
}

enum SyncErrorSeverity {
  low,
  medium,
  high,
  critical,
}

enum SyncOperationStatus {
  queued,
  processing,
  completed,
  failed,
  retrying,
  cancelled,
}
