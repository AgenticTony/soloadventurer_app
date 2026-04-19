# Verification Flow: Women-Only Mode

**Version:** 1.0  
**Date:** 2026-04-01  
**Author:** Security Lead  
**Status:** Ready for Backend Review

---

## Overview

This document describes the complete user journey for ID verification when enabling women-only mode, including error states, retry logic, and timeout handling.

---

## 1. User Journey: Step-by-Step

### Phase 1: Trigger (User Initiates)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  User enables "Women-Only Mode" in settings                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  IF user.gender === 'female' AND NOT verified:                              │
│    → Show verification requirement dialog                                    │
│  ELSE IF user.gender !== 'female':                                          │
│    → Show error: "Women-only mode requires female gender on profile"        │
│  ELSE IF user.verified_gender === 'female':                                 │
│    → Enable immediately (already verified)                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase 2: Consent & Information

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  VERIFICATION REQUIREMENTS DIALOG                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  🛡️ Verify Your Identity for Women-Only Mode                               │
│                                                                             │
│  To protect our community, we require ID verification to access             │
│  women-only spaces.                                                         │
│                                                                             │
│  What you'll need:                                                          │
│  ✓ A valid passport (national ID not accepted)                              │
│  ✓ Access to your phone's camera                                            │
│  ✓ A well-lit environment                                                   │
│                                                                             │
│  What we verify:                                                            │
│  ✓ Your gender from passport                                                │
│  ✓ That you're a real person (liveness check)                              │
│                                                                             │
│  What we DON'T store:                                                       │
│  ✗ Your passport image                                                       │
│  ✗ Your passport number                                                      │
│  ✗ Your home address                                                         │
│                                                                             │
│  Your data is processed by Entrust (ISO 27001, SOC 2 Type II)               │
│  and deleted within 90 days.                                                │
│                                                                             │
│  [Learn More] [Cancel] [Continue to Verification]                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase 3: SDK Initialization

```
1. App calls POST /api/verification/start
   └── Backend creates Entrust applicant
   └── Backend creates workflow run
   └── Backend generates SDK token
   └── Returns: { sdk_token, workflow_run_id, expires_at }

2. App initializes Entrust SDK with token

3. SDK shows welcome screen (configurable)
```

### Phase 4: Document Capture (Passport Only)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ENTRUST SDK: DOCUMENT CAPTURE                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [Camera Preview with edge detection]                                       │
│                                                                             │
│  Position your passport photo page in the frame                             │
│                                                                             │
│  💡 Tips:                                                                   │
│  - Use good lighting                                                        │
│  - Avoid glare                                                              │
│  - Ensure all text is visible                                               │
│                                                                             │
│  Document type: PASSPORT ONLY (pre-selected, not changeable)               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**SDK Validations (Automatic):**
- Document type check (must be passport)
- Image quality (blur detection)
- Glare detection
- Edge detection (document fully in frame)
- MRZ (Machine Readable Zone) parsing

### Phase 5: Biometric Capture (Live Selfie + Liveness)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ENTRUST SDK: LIVENESS CHECK                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [Camera Preview - Front facing]                                            │
│                                                                             │
│  Position your face in the oval                                             │
│                                                                             │
│  ○ Follow the prompts:                                                      │
│     → Turn your head slowly to the left                                     │
│     → Turn your head slowly to the right                                    │
│     → Look straight at the camera                                           │
│                                                                             │
│  💡 This proves you're a real person, not a photo                           │
│                                                                             │
│  [Progress indicator showing head turn detection]                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Liveness Detection (Motion-based):**
- User performs 2 head turns (active liveness)
- AI verifies real-time video (not uploaded photo/video)
- Deepfake detection built-in
- Cannot be bypassed with photos or pre-recorded videos

### Phase 6: Submission & Processing

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SUBMISSION SCREEN                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ✓ Passport captured                                                        │
│  ✓ Selfie & liveness completed                                              │
│                                                                             │
│  [Submit Verification]                                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PROCESSING SCREEN                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  🔍 Verifying your identity...                                              │
│                                                                             │
│  This usually takes 10-30 seconds                                           │
│                                                                             │
│  [Loading spinner]                                                          │
│                                                                             │
│  We'll notify you when it's complete.                                       │
│  You can close this screen.                                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase 7: Result Delivery

#### Success (Gender = Female)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  VERIFICATION COMPLETE                                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ✅ You're verified!                                                        │
│                                                                             │
│  Women-Only Mode is now active.                                             │
│  You'll only see and be seen by other verified women.                       │
│                                                                             │
│  [Great, let's go!]                                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Failure (Gender ≠ Female)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  VERIFICATION ISSUE                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ⚠️ We couldn't verify your eligibility for women-only mode.               │
│                                                                             │
│  Your passport indicates a different gender than required for               │
│  this feature.                                                              │
│                                                                             │
│  Women-only mode remains disabled.                                          │
│                                                                             │
│  [Contact Support] [OK]                                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Error States and Handling

### Error State Matrix

| Error Code | User Message | Technical Cause | Resolution |
|------------|--------------|-----------------|------------|
| `DOCUMENT_BLURRY` | "Your passport image is too blurry. Please retake in better lighting." | Image quality below threshold | Auto-retry (max 3) |
| `DOCUMENT_GLARE` | "Glare detected on passport. Adjust lighting and try again." | Light reflection on document | Auto-retry (max 3) |
| `DOCUMENT_WRONG_TYPE` | "Please use a passport. National IDs are not accepted." | User tried to use ID card | Manual document selection |
| `DOCUMENT_EXPIRED` | "Your passport has expired. Please use a valid passport." | Expiry date check failed | Cannot proceed |
| `FACE_NOT_DETECTED` | "We couldn't detect your face. Please try again." | No face in selfie frame | Auto-retry (max 3) |
| `FACE_MULTIPLE` | "Multiple faces detected. Please be alone during verification." | >1 face in frame | Auto-retry (max 3) |
| `LIVENESS_FAILED` | "Liveness check failed. Ensure you're in a well-lit area." | AI detected spoof attempt | Manual review or retry |
| `NO_INTERNET` | "No internet connection. Please connect and try again." | Network error | Auto-retry on reconnect |
| `SDK_TOKEN_EXPIRED` | "Session expired. Please start over." | Token > 30 min old | Restart flow |
| `VERIFICATION_TIMEOUT` | "Verification is taking too long. We'll notify you when complete." | Backend timeout (>2 min) | Async notification |
| `API_ERROR` | "Something went wrong. Please try again later." | Entrust API error | Retry after delay |
| `GENDER_MISMATCH` | "Your passport indicates a different gender." | Gender ≠ female | Cannot proceed |
| `ALREADY_VERIFIED` | "You're already verified!" | Duplicate verification | Redirect to success |

### Retry Logic

#### Client-Side Retries (SDK Automatic)

```dart
// SDK configuration for retry limits
final config = EntrustConfig(
  sdkToken: sdkToken,
  workflowRunId: workflowRunId,
  captureOptions: CaptureOptions(
    maxDocumentRetries: 3,  // Per document capture
    maxFaceRetries: 3,       // Per face/liveness capture
    autoRetry: true,         // Automatic retry for quality issues
  ),
);
```

#### Server-Side Retry Logic

```typescript
// Edge Function: Handle verification start
export async function startVerification(userId: string) {
  // Check for existing pending verification
  const existing = await db.from('user_verifications')
    .select('*')
    .eq('user_id', userId)
    .eq('verification_status', 'pending')
    .single();
  
  if (existing) {
    // Check if workflow expired
    const workflowCreatedAt = new Date(existing.submitted_at);
    const hoursSinceCreation = (Date.now() - workflowCreatedAt.getTime()) / (1000 * 60 * 60);
    
    if (hoursSinceCreation < 24) {
      // Return existing workflow (allow user to continue)
      return {
        sdk_token: await regenerateSDKToken(existing.entrust_applicant_id),
        workflow_run_id: existing.entrust_workflow_run_id,
        is_resumption: true,
      };
    } else {
      // Mark as expired, create new
      await db.from('user_verifications')
        .update({ verification_status: 'expired' })
        .eq('id', existing.id);
    }
  }
  
  // Create new verification...
}
```

### Retry Limits

| Phase | Max Retries | Cooldown | After Limit |
|-------|-------------|----------|-------------|
| Document capture | 3 per session | None | Show help article |
| Liveness capture | 3 per session | None | Offer support contact |
| Full flow restart | 5 per 24h | None | 24h cooldown |
| API errors | 3 with exponential backoff | 1s, 2s, 4s | Show error, try later |

---

## 3. Timeout Handling

### Timeout Thresholds

| Stage | Timeout | Behavior |
|-------|---------|----------|
| SDK token generation | 10 seconds | Retry 3x, then error |
| Document upload | 60 seconds | Show progress, retry |
| Liveness capture | 120 seconds | Per session (user can retry) |
| Verification processing | 120 seconds | Move to async, notify later |
| Full session | 30 minutes | Token expires, restart required |
| Webhook delivery | 5 seconds (response) | Entrust retries up to 10x |

### Timeout User Experience

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TAKING LONGER THAN EXPECTED                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ⏳ Verification is still processing...                                     │
│                                                                             │
│  This can happen during high traffic. We'll send you a push                 │
│  notification as soon as it's complete.                                     │
│                                                                             │
│  You can safely close the app.                                              │
│                                                                             │
│  [Check Status Later] [Contact Support]                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Background Processing Flow

```
1. User closes app during processing
2. Webhook arrives (1-5 minutes later)
3. Push notification sent to user:
   ┌────────────────────────────────────┐
   │ SoloAdventurer                     │
   │ ✅ Your verification is complete!  │
   │    Tap to continue                 │
   └────────────────────────────────────┘
4. User taps notification
5. App opens to verification result screen
```

---

## 4. Edge Cases

### Edge Case: User Changes Gender Before Verification Completes

**Scenario:** User sets gender to "female", starts verification, then changes gender to "male" before webhook arrives.

**Handling:**
```typescript
// Webhook handler
if (result.verified_gender === 'female') {
  // Check current user gender
  const user = await db.from('users').select('gender').eq('id', userId).single();
  
  if (user.gender !== 'female') {
    // User changed gender mid-verification
    // Don't enable women-only mode, but mark as verified
    await db.from('user_verifications').update({
      verification_status: 'clear',
      verified_gender: 'female',
      completed_at: new Date(),
    }).eq('user_id', userId);
    
    // Don't auto-enable women-only mode
    // Log for audit
    await logAuditEvent({
      type: 'verification_gender_mismatch',
      user_id: userId,
      profile_gender: user.gender,
      verified_gender: 'female',
    });
    
    return;
  }
  
  // Proceed with enabling women-only mode
}
```

### Edge Case: Passport Shows "X" Gender

**Scenario:** User has passport with non-binary gender marker (X/Unspecified).

**Handling:**
- Entrust extracts gender as "unknown" or null
- Webhook handler: `verified_gender` = null
- User receives: "We couldn't verify female gender from your passport"
- Cannot enable women-only mode

### Edge Case: User Submits Same Passport Twice (Different Accounts)

**Scenario:** User creates second account, tries to verify with same passport.

**Handling:**
```sql
-- Add to user_verifications table
ALTER TABLE user_verifications ADD COLUMN passport_hash TEXT;

-- Create index for duplicate detection
CREATE INDEX idx_verifications_passport_hash ON user_verifications(passport_hash);

-- Webhook handler
const passportHash = hash(extractedData.passportNumber + extractedData.dateOfBirth);

const existingVerification = await db.from('user_verifications')
  .select('user_id')
  .eq('passport_hash', passportHash)
  .maybeSingle();

if (existingVerification && existingVerification.user_id !== userId) {
  // Same passport used by different account
  // Flag for review, don't auto-reject (could be legitimate re-verification)
  await db.from('verification_reviews').insert({
    user_id: userId,
    reason: 'duplicate_passport_hash',
    existing_user_id: existingVerification.user_id,
    created_at: new Date(),
  });
  
  // Still allow verification to complete
  // Review team will investigate
}
```

---

## 5. State Machine

```
                                    ┌─────────────────┐
                                    │     IDLE        │
                                    │  (not started)  │
                                    └────────┬────────┘
                                             │
                                    User enables women-only
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │    CONSENT      │
                                    │ (showing dialog)│
                                    └────────┬────────┘
                                             │
                                    User accepts
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │ SDK_INIT        │
                                    │ (loading token) │
                                    └────────┬────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │              │              │
                         Token error   Token success   Token timeout
                              │              │              │
                              ▼              ▼              ▼
                        ┌─────────┐   ┌─────────────┐  ┌─────────┐
                        │ ERROR   │   │ DOCUMENT    │  │ RETRY   │
                        │ (show)  │   │ CAPTURE     │  │ (delay) │
                        └─────────┘   └──────┬──────┘  └─────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │              │              │
                         Max retries     Capture OK     User cancel
                              │              │              │
                              ▼              ▼              ▼
                        ┌─────────┐   ┌─────────────┐  ┌─────────┐
                        │ ERROR   │   │ LIVENESS    │  │ CANCEL  │
                        │ (help)  │   │ CAPTURE     │  │ (idle)  │
                        └─────────┘   └──────┬──────┘  └─────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │              │              │
                         Liveness fail   Liveness OK    User cancel
                              │              │              │
                              ▼              ▼              ▼
                        ┌─────────┐   ┌─────────────┐  ┌─────────┐
                        │ RETRY   │   │ PROCESSING  │  │ CANCEL  │
                        │ (max 3) │   │ (waiting)   │  │ (idle)  │
                        └─────────┘   └──────┬──────┘  └─────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │              │              │
                           Timeout       Success        Failure
                              │              │              │
                              ▼              ▼              ▼
                        ┌─────────┐   ┌─────────────┐  ┌─────────┐
                        │ ASYNC   │   │ SUCCESS     │  │ FAILED  │
                        │ NOTIFY  │   │ (verified)  │  │ (reason)│
                        └─────────┘   └─────────────┘  └─────────┘
```

---

## 6. Push Notification Templates

### Verification Complete (Success)
```
Title: ✅ Verification Complete
Body: Your identity is verified! Women-only mode is now active.
Action: Open app to matches
```

### Verification Complete (Gender Mismatch)
```
Title: ⚠️ Verification Issue
Body: We couldn't verify your eligibility for women-only mode.
Action: Open app for details
```

### Verification Processing (Long Running)
```
Title: 🔍 Still Processing
Body: Your verification is taking longer than expected. We'll notify you when complete.
Action: None (informational)
```

---

## 7. Analytics Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `verification_started` | User clicks "Continue to Verification" | `user_id`, `has_previous_attempt` |
| `verification_document_captured` | Document capture complete | `document_type`, `retry_count` |
| `verification_liveness_completed` | Liveness check complete | `retry_count`, `duration_seconds` |
| `verification_submitted` | User submits for processing | `total_duration_seconds` |
| `verification_completed` | Webhook received with result | `status`, `verified_gender`, `processing_time_seconds` |
| `verification_failed` | Verification rejected | `failure_reason`, `retry_available` |
| `verification_cancelled` | User cancels mid-flow | `stage`, `duration_seconds` |

---

**Document Status:** ✅ Complete  
**Review Required By:** UX Lead, Mobile Team Lead  
**Dependencies:** Push notification infrastructure, Analytics setup
