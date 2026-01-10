import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

/// Provider for managing authentication tokens
final tokenNotifierProvider =
    Provider<TokenNotifier>((ref) => TokenNotifierImpl());

/// Abstract class for managing authentication tokens
abstract class TokenNotifier {
  /// Get the current authentication session
  AuthSession? get currentSession;

  /// Set the current authentication session
  void setSession(AuthSession session);

  /// Clear the current authentication session
  void clearSession();
}

/// Implementation of TokenNotifier
class TokenNotifierImpl implements TokenNotifier {
  AuthSession? _currentSession;

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  void setSession(AuthSession session) {
    _currentSession = session;
  }

  @override
  void clearSession() {
    _currentSession = null;
  }
}
