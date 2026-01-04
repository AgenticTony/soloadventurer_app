# Verification Guide: Subtask 2.4 - Token Refresh Notifications

## Implementation Summary

This subtask implements user-facing notifications for token refresh events with the following features:

### What Was Implemented

1. **TokenRefreshNotificationHandler** (`lib/features/auth/presentation/notifiers/token_refresh_notification_handler.dart`)
   - Listens to TokenRefreshService status stream
   - Converts refresh events to user-facing notifications
   - Silent on success (no notification)
   - Shows user-friendly error messages on failure

2. **Token Refresh Providers** (`lib/features/auth/presentation/providers/token_refresh_providers.dart`)
   - Provider for TokenRefreshService
   - Integrates with service locator

3. **TokenRefreshNotificationListener** (`lib/features/auth/presentation/widgets/token_refresh_notification_listener.dart`)
   - Widget that displays notifications via SnackBars and Dialogs
   - Shows appropriate messages based on error type
   - Provides Retry/Re-authenticate buttons based on error

4. **Integration** (`lib/app/app.dart`)
   - Notification listener wrapped around entire app
   - Ensures notifications are shown on any screen

## Acceptance Criteria Status

- ✅ **Silent refresh (no notification) on success**: Successful token refreshes do not trigger any UI notification
- ✅ **User-friendly error message on refresh failure**: Different messages for different error types (network, credentials, expired, etc.)
- ✅ **Option to retry or re-authenticate on failure**: Dialog buttons shown based on error type
- ⚠️ **Respects user notification preferences**: Not implemented - no user preferences system exists yet (future enhancement)

## Manual Verification Steps

### Test Case 1: Successful Token Refresh (Silent)

**Expected Behavior:**
- User stays logged in
- No notification or interruption
- App continues normally

**How to Test:**
1. Log in to the app
2. Wait for token to approach expiration (75% of lifetime)
3. Token should refresh automatically in background
4. Verify no SnackBar or dialog appears
5. Verify app remains functional

### Test Case 2: Network Error During Refresh

**Expected Behavior:**
- Shows SnackBar: "Unable to refresh your session due to network issues. The app will retry automatically."
- Auto-retry happens in background
- No manual intervention needed

**How to Test:**
1. Log in to the app
2. Wait for token to approach expiration
3. Turn off internet connection
4. Wait for refresh attempt
5. Verify warning SnackBar appears
6. Turn internet back on
7. Verify refresh succeeds on next attempt

### Test Case 3: Refresh Token Expired

**Expected Behavior:**
- Shows dialog: "Session Refresh Failed - Your session has expired. Please sign in again to continue."
- Shows "Sign In" button
- No "Retry" button (since retry won't work)

**How to Test:**
1. This requires the refresh token to be expired on the backend
2. Log in and wait for access token to expire
3. Attempt to use the app
4. Verify dialog appears with "Sign In" button
5. Click "Sign In" - should navigate to login screen

### Test Case 4: Max Retries Exceeded

**Expected Behavior:**
- Shows dialog: "Session Refresh Failed - Unable to refresh your session after multiple attempts. Please check your connection and sign in again."
- Shows both "Retry" and "Sign In" buttons

**How to Test:**
1. Log in to the app
2. Turn off internet connection
3. Wait for multiple refresh attempts (3 retries with exponential backoff)
4. Verify error dialog appears with both buttons
5. Test "Retry" button - should trigger new refresh attempt
6. Test "Sign In" button - should navigate to login

### Test Case 5: Unknown Error

**Expected Behavior:**
- Shows dialog with error message from exception
- Shows both "Retry" and "Sign In" buttons

**How to Test:**
- This requires triggering an unexpected error
- Difficult to test manually without backend manipulation

## Error Type Matrix

| Error Code | Message Type | UI Element | Retry Button | Re-Auth Button |
|------------|--------------|------------|--------------|----------------|
| None (success) | Silent | None | No | No |
| NETWORK_ERROR | SnackBar | Warning | No (auto) | No |
| network_connectivity | SnackBar | Warning | No (auto) | No |
| network_timeout | SnackBar | Warning | No (auto) | No |
| INVALID_CREDENTIALS | Dialog | Error | No | Yes |
| USER_NOT_FOUND | Dialog | Error | No | Yes |
| REFRESH_TOKEN_EXPIRED | Dialog | Error | No | Yes |
| MAX_RETRIES_EXCEEDED | Dialog | Error | Yes | Yes |
| Other | Dialog | Error | Yes | Yes |

## Integration Notes

The notification handler integrates with existing infrastructure:

- **TokenRefreshService**: Already emits status events via Stream
- **TokenRefreshScheduler**: Triggers refresh automatically
- **TokenRefreshOverlay**: Existing overlay for critical auth states
- **AuthNotifier**: Manages overall auth state

The new `TokenRefreshNotificationListener` wraps the entire app in `app.dart`, ensuring notifications are visible from any screen.

## Future Enhancements

1. **User Notification Preferences**: Add settings to control notification verbosity
   - Option to disable refresh failure notifications
   - Option to show detailed technical error messages
   - Notification sound/vibration preferences

2. **Notification History**: Log of recent refresh events for debugging

3. **Advanced Retry Controls**: User-configurable retry count and backoff settings

## Files Modified/Created

### Created:
- `lib/features/auth/presentation/notifiers/token_refresh_notification_handler.dart`
- `lib/features/auth/presentation/notifiers/token_refresh_notification_handler.g.dart`
- `lib/features/auth/presentation/providers/token_refresh_providers.dart`
- `lib/features/auth/presentation/providers/token_refresh_providers.g.dart`
- `lib/features/auth/presentation/widgets/token_refresh_notification_listener.dart`

### Modified:
- `lib/app/app.dart` - Added TokenRefreshNotificationListener wrapper
- `lib/app/di/modules/auth_module.dart` - Added missing import

## Verification Checklist

- [ ] No console errors during app startup
- [ ] Successful login works
- [ ] App remains responsive during token refresh
- [ ] Error messages appear for different failure scenarios
- [ ] Dialog buttons work correctly
- [ ] Navigation to login screen works on re-auth
- [ ] Notifications don't interfere with normal app usage
- [ ] Multiple refresh failures don't create multiple overlapping dialogs

## Known Limitations

1. User notification preferences not implemented (no preferences system exists)
2. No notification history or logging
3. Retry options are limited to the current session
