import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_session.dart';

part 'token_blacklist_manager.g.dart';

/// Manages token blacklisting and rotation according to AWS Cognito best practices
@Riverpod(keepAlive: false)
class TokenBlacklistManager extends _$TokenBlacklistManager {
  static const Duration _blacklistDuration = Duration(hours: 24);
  final Map<String, DateTime> _blacklistedTokens = {};
  Timer? _cleanupTimer;

  @override
  void build() {
    ref.onDispose(() {
      _cleanupTimer?.cancel();
    });
    _startCleanupTimer();
  }

  /// Add a token to the blacklist
  void blacklistToken(String token) {
    debugPrint('TokenBlacklistManager: Blacklisting token');
    _blacklistedTokens[token] = DateTime.now().add(_blacklistDuration);
  }

  /// Check if a token is blacklisted
  bool isTokenBlacklisted(String token) {
    final expiryTime = _blacklistedTokens[token];
    if (expiryTime == null) return false;

    if (DateTime.now().isAfter(expiryTime)) {
      _blacklistedTokens.remove(token);
      return false;
    }
    return true;
  }

  /// Clean up expired blacklisted tokens
  void _cleanupBlacklist() {
    debugPrint('TokenBlacklistManager: Running blacklist cleanup');
    final now = DateTime.now();
    _blacklistedTokens.removeWhere((_, expiry) => now.isAfter(expiry));
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupBlacklist(),
    );
  }

  /// Handle token rotation
  Future<void> handleTokenRotation(
      AuthSession oldSession, AuthSession newSession) async {
    if (oldSession.accessToken != newSession.accessToken) {
      blacklistToken(oldSession.accessToken);
    }
    if (oldSession.refreshToken != newSession.refreshToken) {
      blacklistToken(oldSession.refreshToken);
    }
  }

  /// Get the number of blacklisted tokens (for monitoring)
  int get blacklistedTokenCount => _blacklistedTokens.length;
}
