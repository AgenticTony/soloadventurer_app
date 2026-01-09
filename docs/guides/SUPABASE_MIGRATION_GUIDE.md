# Supabase Migration Guide
## SoloAdventurer - AWS Cognito to Supabase

**Migration Date:** 2026-01-06
**Estimated Time:** 2-3 weeks
**Complexity:** Medium (Clean Architecture makes this easier)

---

## Overview

This guide will walk you through migrating from AWS Cognito to Supabase for authentication and database. Your existing Clean Architecture with abstract interfaces means minimal changes to your business logic.

---

## Why This Migration Will Be Smoother Than You Think

### Your Architecture Helps You

You already have:
```
Domain Layer (Interfaces) ← No changes needed
    ↓
Data Layer (Implementations) ← We'll create new implementations
    ↓
Presentation Layer (Providers) ← Minimal changes
```

**Existing Interface:**
```dart
// lib/features/auth/data/datasources/auth_remote_data_source.dart
abstract class AuthRemoteDataSource {
  Future<(UserModel, bool)> register({required String email, required String password, required String name});
  Future<(UserModel, String)> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isSignedIn();
  Future<AuthSession> refreshToken();
  Future<void> verifyEmail(String code, String email);
  Future<void> resendVerificationEmail();
  Future<void> forgotPassword(String email);
  Future<void> confirmForgotPassword(String email, String code, String newPassword);
  Future<AuthTokens> refreshTokenWithString(String refreshToken);
  Future<AuthTokens> reauthenticate(Credentials credentials);
}
```

**We'll create:**
```dart
// New file: supabase_auth_remote_data_source.dart
class SupabaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Supabase implementation
}
```

---

## Phase 1: Supabase Project Setup (Day 1)

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign in with GitHub (recommended)
4. Create new organization: `SoloAdventurer`
5. Create new project:
   - **Name**: `soloadventurer-prod` (or `soloadventurer-dev` for testing)
   - **Database Password**: Generate and save securely
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Start with Free (upgrade to Pro $25/month when ready)

### Step 2: Get Your Credentials

From Supabase Dashboard:
```
Settings → API → Project URL
Settings → API → anon/public key
```

### Step 3: Update `.env.example`

```bash
# .env.example

# ❌ REMOVE (if exists)
# AWS_ACCESS_KEY_ID=your_access_key_id
# AWS_SECRET_ACCESS_KEY=your_secret_access_key
# AWS_USER_POOL_ID=us-east-1_XXXXXXXX
# AWS_CLIENT_ID=XXXXXXXXXXXXXXXXXXXXXXXX
# AWS_IDENTITY_POOL_ID=us-east-1:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

# ✅ ADD SUPABASE CONFIG
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_ENV=dev

# Keep your existing config
API_BASE_URL_DEV=https://api.soloadventurer.com/dev
API_BASE_URL_STAGING=https://api.soloadventurer.com/staging
API_BASE_URL_PROD=https://api.soloadventurer.com/prod

# ... rest of your existing config
```

---

## Phase 2: Add Supabase Dependencies (Day 1)

### Update `pubspec.yaml`

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter

  # ❌ REMOVE (when ready)
  # amazon_cognito_identity_dart_2: ^3.6.0
  # aws_cloudwatch: ^1.0.1
  # aws_request: ^1.0.1
  # aws_cloudwatch_api: ^2.0.0

  # ✅ ADD SUPABASE
  supabase_flutter: ^2.0.0

  # Keep your existing dependencies
  flutter_riverpod: ^3.1.0
  riverpod_annotation: ^4.0.0
  go_router: ^14.6.2
  # ... rest of your dependencies
```

### Install Dependencies

```bash
flutter pub get
```

---

## Phase 3: Create Supabase Auth Data Source (Day 2-3)

### Create New File: `lib/features/auth/data/datasources/supabase_auth_remote_data_source.dart`

```dart
// lib/features/auth/data/datasources/supabase_auth_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/auth/data/models/auth_tokens.dart';
import 'package:soloadventurer/features/auth/data/models/credentials.dart';

/// Supabase implementation of [AuthRemoteDataSource]
class SupabaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;
  final http.Client _httpClient;

  SupabaseAuthRemoteDataSourceImpl({
    required SupabaseClient client,
    required http.Client httpClient,
  })  : _client = client,
        _httpClient = httpClient;

  // Helper: Convert Supabase User to UserModel
  UserModel _mapToModel(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? '',
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  // Helper: Convert Supabase Session to AuthSession
  AuthSession _mapSessionToAuthSession(Session session) {
    return AuthSession(
      accessToken: session.accessToken,
      idToken: session.user?.identities?.first?.identityData?.['sub'] ?? session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: session.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
    );
  }

  /// Register a new user
  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
        emailRedirectTo: null, // Add your custom scheme if needed: 'soloadventurer://callback'
      );

      if (response.user == null) {
        throw AuthException(
          message: 'Registration failed',
          type: AuthErrorType.unknown,
        );
      }

      final user = _mapToModel(response.user!);
      // Supabase requires email verification by default
      final needsVerification = !response.user!.emailConfirmedAt.isNotNull;

      return (user, needsVerification);
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw AuthException(
          message: 'An account with this email already exists',
          type: AuthErrorType.emailAlreadyExists,
        );
      }
      if (e.message.contains('Password should be')) {
        throw AuthException(
          message: 'Password does not meet requirements',
          type: AuthErrorType.invalidPassword,
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Supabase registration error: $e');
      throw AuthException(
        message: 'Registration failed: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Sign in with email and password
  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw AuthException(
          message: 'Authentication failed',
          type: AuthErrorType.invalidCredentials,
        );
      }

      // Check if email is verified
      if (!response.user!.emailConfirmedAt.isNotNull) {
        throw AuthException(
          message: 'Please verify your email before signing in',
          type: AuthErrorType.emailNotVerified,
        );
      }

      final user = _mapToModel(response.user!);
      final accessToken = response.session!.accessToken;

      return (user, accessToken);
    } on AuthException catch (e) {
      final errorMessage = e.message.toLowerCase();

      if (errorMessage.contains('invalid') || errorMessage.contains('not found')) {
        throw AuthException(
          message: 'Invalid email or password',
          type: AuthErrorType.invalidCredentials,
        );
      }
      if (errorMessage.contains('email not confirmed')) {
        throw AuthException(
          message: 'Please verify your email before signing in',
          type: AuthErrorType.emailNotVerified,
        );
      }
      throw AuthException(
        message: 'Authentication failed: ${e.message}',
        type: AuthErrorType.unknown,
      );
    } catch (e) {
      debugPrint('Supabase sign in error: $e');
      throw AuthException(
        message: 'Authentication failed',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Sign out the current user
  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Supabase sign out error: $e');
      // Always clear local state even if remote sign out fails
    }
  }

  /// Get the current user
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _client.auth.currentUser;

      if (response == null) {
        return null;
      }

      return _mapToModel(response);
    } catch (e) {
      debugPrint('Supabase get current user error: $e');
      return null;
    }
  }

  /// Check if a user is signed in
  @override
  Future<bool> isSignedIn() async {
    try {
      final response = await _client.auth.currentUser;
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Refresh the authentication token
  @override
  Future<AuthSession> refreshToken() async {
    try {
      final response = await _client.auth.refreshSession();

      if (response.session == null) {
        throw AuthException(
          message: 'Failed to refresh token',
          type: AuthErrorType.tokenExpired,
        );
      }

      return _mapSessionToAuthSession(response.session!);
    } catch (e) {
      debugPrint('Supabase token refresh error: $e');
      throw AuthException(
        message: 'Failed to refresh token: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Verify email with confirmation code
  @override
  Future<void> verifyEmail(String code, String email) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );
    } on AuthException catch (e) {
      final errorMessage = e.message.toLowerCase();

      if (errorMessage.contains('expired') || errorMessage.contains('invalid')) {
        throw AuthException(
          message: 'Invalid or expired verification code',
          type: AuthErrorType.invalidCode,
        );
      }
      if (errorMessage.contains('already confirmed')) {
        throw AuthException(
          message: 'Email already verified',
          type: AuthErrorType.notAuthorized,
        );
      }
      throw AuthException(
        message: 'Verification failed: ${e.message}',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Resend verification email
  @override
  Future<void> resendVerificationEmail() async {
    try {
      await _client.auth.refreshSession();
      // Supabase automatically sends verification email on sign up
      // This method is a no-op for Supabase but kept for interface compatibility
    } catch (e) {
      debugPrint('Supabase resend verification error: $e');
      throw AuthException(
        message: 'Failed to resend verification email',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Request a password reset for a user
  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'soloadventurer://password-reset',
      );
    } catch (e) {
      debugPrint('Supabase forgot password error: $e');
      throw AuthException(
        message: 'Failed to initiate password reset',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Complete the password reset process
  @override
  Future<void> confirmForgotPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );

      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      final errorMessage = e.message.toLowerCase();

      if (errorMessage.contains('invalid') || errorMessage.contains('expired')) {
        throw AuthException(
          message: 'Invalid or expired reset code',
          type: AuthErrorType.invalidCode,
        );
      }
      if (errorMessage.contains('password')) {
        throw AuthException(
          message: 'Password does not meet requirements',
          type: AuthErrorType.invalidPassword,
        );
      }
      throw AuthException(
        message: 'Password reset failed: ${e.message}',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Admin API to set a user's password
  @override
  Future<void> adminSetUserPassword(
    String email,
    String newPassword, {
    bool permanent = false,
  }) async {
    // Supabase doesn't have direct admin password reset
    // This would require a Supabase Edge Function or server-side call
    // For now, we'll use the user context
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to update password',
        type: AuthErrorType.adminSetPasswordError,
      );
    }
  }

  /// Admin API to initiate password reset
  @override
  Future<void> adminResetUserPassword(String email) async {
    // Use forgotPassword for now
    // True admin reset would require Edge Function
    await forgotPassword(email);
  }

  /// Send password reset email
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await forgotPassword(email);
  }

  /// Refresh tokens with refresh token string
  @override
  Future<AuthTokens> refreshTokenWithString(String refreshToken) async {
    try {
      final response = await _client.auth.refreshSession();

      if (response.session == null) {
        throw ServerException(
          message: 'Failed to refresh token',
          statusCode: 401,
        );
      }

      return AuthTokens(
        accessToken: response.session!.accessToken,
        idToken: response.session!.user?.identities?.first?.identityData?.['sub'] ?? response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: response.session!.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to refresh token',
        statusCode: 500,
      );
    }
  }

  /// Re-authenticate user
  @override
  Future<AuthTokens> reauthenticate(Credentials credentials) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      if (response.session == null) {
        throw ServerException(
          message: 'Re-authentication failed',
          statusCode: 401,
        );
      }

      return AuthTokens(
        accessToken: response.session!.accessToken,
        idToken: response.session!.user?.identities?.first?.identityData?.['sub'] ?? response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: response.session!.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      );
    } catch (e) {
      throw ServerException(
        message: 'Re-authentication failed',
        statusCode: 500,
      );
    }
  }
}
```

---

## Phase 4: Update Bootstrap Configuration (Day 3)

### Update `lib/app/bootstrap.dart`

```dart
// lib/app/bootstrap.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/monitoring/app_start_tracker.dart';

Future<void> main() async {
  // Track app start time
  final startTracker = AppStartTracker();

  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // ✅ INITIALIZE SUPABASE (Replace Amplify/Cognito)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: dotenv.env['SUPABASE_ENV'] != 'production',
  );

  debugPrint('✅ Supabase initialized successfully');

  // Track bootstrap complete
  await startTracker.completeBootstrap();

  runApp(const SoloAdventurerApp());
}
```

---

## Phase 5: Update Providers (Day 4)

### Update Auth Data Provider

```dart
// lib/features/auth/data/providers/auth_data_providers.dart

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final client = ref.watch(supabaseClientProvider);

  return SupabaseAuthRemoteDataSourceImpl(
    client: client,
    httpClient: http.Client(),
  );
}
```

---

## Phase 6: Database Schema Setup (Day 5-6)

### Option A: Use Supabase Dashboard (Recommended for Initial Setup)

1. Go to your Supabase project
2. Click "Table Editor" → "New Table"
3. Create tables matching your Drift schema

### Option B: Use SQL Editor (Faster)

Go to Supabase Dashboard → SQL Editor and run:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users profile table (extends auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  username TEXT UNIQUE,
  avatar_url TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Travel preferences
  travel_preferences JSONB DEFAULT '{}',
  home_location JSONB,

  -- Safety settings
  emergency_contact JSONB,
  medical_info JSONB
);

-- Trips table
CREATE TABLE public.trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  destination TEXT,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  status TEXT DEFAULT 'planned', -- planned, active, completed
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Itinerary items
CREATE TABLE public.itinerary_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  location JSONB, -- {lat, lng, name, address}
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  type TEXT, -- accommodation, transportation, activity, dining, other
  order_index INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Journals
CREATE TABLE public.journals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
  title TEXT,
  content TEXT,
  mood TEXT,
  tags TEXT[],
  location JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trusted contacts
CREATE TABLE public.trusted_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  relationship TEXT,
  is_verified BOOLEAN DEFAULT false,
  location_sharing_enabled BOOLEAN DEFAULT false,
  sos_notifications_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Check-ins
CREATE TABLE public.check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
  location JSONB,
  status TEXT DEFAULT 'safe', -- safe, emergency, need_help
  note TEXT,
  scheduled_for TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Location updates (for real-time sharing)
CREATE TABLE public.location_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  accuracy FLOAT,
  altitude FLOAT,
  speed FLOAT,
  bearing FLOAT,
  recorded_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '1 hour'
);

-- Create indexes
CREATE INDEX idx_trips_user_id ON public.trips(user_id);
CREATE INDEX idx_trips_dates ON public.trips(start_date, end_date);
CREATE INDEX idx_itinerary_items_trip_id ON public.itinerary_items(trip_id);
CREATE INDEX idx_journals_user_id ON public.journals(user_id);
CREATE INDEX idx_journals_trip_id ON public.journals(trip_id);
CREATE INDEX idx_trusted_contacts_user_id ON public.trusted_contacts(user_id);
CREATE INDEX idx_check_ins_user_id ON public.check_ins(user_id);
CREATE INDEX idx_location_updates_user_id ON public.location_updates(user_id);
CREATE INDEX idx_location_updates_recorded_at ON public.location_updates(recorded_at DESC);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itinerary_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trusted_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_updates ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Profiles: Users can read their own profile
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Trips: Users can CRUD their own trips
CREATE POLICY "Users can view own trips" ON public.trips
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own trips" ON public.trips
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own trips" ON public.trips
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own trips" ON public.trips
  FOR DELETE USING (auth.uid() = user_id);

-- Similar policies for other tables...
-- (Full policies would be added here)

-- Create a function to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, username)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## Phase 7: Testing (Day 7-8)

### Create Integration Tests

```dart
// integration_test/supabase_auth_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Supabase Authentication Flow', () {
    setUpAll(() async {
      await dotenv.load(fileName: '.env');
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
    });

    testWidgets('should register a new user', (tester) async {
      final email = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: 'TestPassword123!',
        data: {'name': 'Test User'},
      );

      expect(response.user, isNotNull);
      expect(response.user?.email, equals(email));
    });

    testWidgets('should sign in existing user', (tester) async {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: 'test@example.com',
        password: 'TestPassword123!',
      );

      expect(response.session, isNotNull);
      expect(response.user, isNotNull);
    });

    testWidgets('should sign out user', (tester) async {
      await Supabase.instance.client.auth.signOut();

      final user = await Supabase.instance.client.auth.currentUser;
      expect(user, isNull);
    });
  });
}
```

### Test Checklist

- [ ] Sign up new user
- [ ] Email verification
- [ ] Sign in with correct credentials
- [ ] Fail sign in with wrong credentials
- [ ] Sign out
- [ ] Token refresh
- [ ] Password reset flow
- [ ] Profile creation (automatic)
- [ ] Row Level Security (try accessing another user's data)

---

## Phase 8: Remove AWS Dependencies (Day 9)

### Update `pubspec.yaml`

```yaml
dependencies:
  # ❌ REMOVE THESE
  # amazon_cognito_identity_dart_2: ^3.6.0
  # aws_cloudwatch: ^1.0.1
  # aws_request: ^1.0.1
  # aws_cloudwatch_api: ^2.0.0

  # ✅ KEEP THIS
  supabase_flutter: ^2.0.0

  # ... rest of dependencies
```

### Run Clean Install

```bash
flutter clean
flutter pub get
flutter pub upgrade --major-versions
```

---

## Phase 9: Update Documentation (Day 10)

### Update `docs/@AWS_Cognito.md` → `docs/@SUPABASE.md`

### Update `CLAUDE.md`

```markdown
## Authentication Architecture

**Current Implementation**: Supabase Authentication

### Key Components
- **Supabase Client**: Managed via `supabase_flutter` package
- **Authentication**: Email/password with email verification
- **Session Management**: Automatic token refresh
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Real-time**: Built-in subscriptions for location sharing

### Migration Note
Previously used AWS Cognito. See `docs/SUPABASE_MIGRATION.md` for migration details.
```

---

## Phase 10: Production Deployment (Day 11-14)

### Pre-Deployment Checklist

1. **Enable Email Confirmations** in Supabase Dashboard
2. **Configure Custom Email Templates** (your branding)
3. **Set Up Password Reset** redirect URLs
4. **Enable Row Level Security** on all tables
5. **Create Database Backups** schedule
6. **Set Up Monitoring** (Supabase Dashboard)
7. **Configure Production Environment Variables**

### Environment-Specific Configuration

```bash
# .env.production
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY=your-prod-anon-key
SUPABASE_ENV=production
```

---

## Rollback Plan

If something goes wrong:

```bash
# 1. Revert pubspec.yaml
git checkout HEAD -- pubspec.yaml

# 2. Reinstall old dependencies
flutter pub get

# 3. Revert bootstrap.dart
git checkout HEAD -- lib/app/bootstrap.dart

# 4. Test and redeploy
```

---

## Common Issues & Solutions

### Issue 1: Email verification not working

**Solution**: Enable email confirmation in Supabase Dashboard
```
Authentication → Providers → Email → Enable Email Confirmations
```

### Issue 2: Row Level Security blocking everything

**Solution**: Add policies for inserts/updates
```sql
CREATE POLICY "Enable insert for authenticated users" ON table_name
FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### Issue 3: Real-time subscriptions not working

**Solution**: Enable Realtime for tables
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE table_name;
```

---

## Next Steps After Migration

1. **Replace Drift with Supabase queries** (optional)
2. **Add real-time location sharing** using Supabase Realtime
3. **Set up Supabase Edge Functions** for serverless logic
4. **Configure Supabase Storage** for photos/documents
5. **Enable Supabase Auth** social sign-in (Google, Apple)

---

## Support Resources

- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/flutter)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [Supabase Discord](https://discord.gg/supabase)
- [Migration Support](https://supabase.com/docs/guides/migrations)

---

**Last Updated**: 2026-01-06
**Migration Status**: Ready to Begin
