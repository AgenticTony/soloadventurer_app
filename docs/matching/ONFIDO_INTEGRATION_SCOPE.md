# Onfido (Entrust) Integration Scope

**Version:** 1.0  
**Date:** 2026-04-01  
**Author:** Security Lead  
**Status:** Ready for Backend Review

---

## Executive Summary

Onfido was acquired by Entrust in April 2024 and operates as "Entrust Identity Services." For new integrations in 2026, we should use the **Entrust IDV SDK** which provides document verification, biometric matching, and liveness detection.

**Recommendation:** Use the Entrust IDV SDK with Flutter (available early 2026) or React Native SDK as interim solution.

---

## 1. API Endpoints Required

### Core REST API Endpoints (v3)

| Endpoint | Method | Purpose | When Used |
|----------|--------|---------|-----------|
| `/v3.6/applicants` | POST | Create applicant record | Before SDK initialization |
| `/v3.6/sdk_token` | POST | Generate SDK token | Before SDK initialization |
| `/v3.6/workflow_runs` | POST | Start verification workflow | After applicant created |
| `/v3.6/workflow_runs/{id}` | GET | Check workflow status | Polling (or use webhooks) |
| `/v3.6/applicants/{id}` | GET | Retrieve applicant details | Post-verification |

### Workflow Studio Approach (Recommended)

Instead of individual check endpoints, use **Workflow Studio** to orchestrate:

```
[Document Capture] → [Biometric Selfie + Liveness] → [Face Match] → [Result]
```

This provides:
- Single workflow ID to track
- Configurable rules without code changes
- Built-in retry logic
- Webhook notifications on completion

---

## 2. SDK Integration Points

### Option A: Flutter SDK (Recommended for Mobile)

**Status:** Planned for early 2026 (may be available now)

```yaml
# pubspec.yaml
dependencies:
  entrust_idv_sdk: ^1.0.0
```

**Integration:**
```dart
import 'package:entrust_idv_sdk/entrust_idv_sdk.dart';

// 1. Get SDK token from our backend
final sdkToken = await getSDKTokenFromBackend();

// 2. Initialize SDK with workflow
final config = EntrustConfig(
  sdkToken: sdkToken,
  workflowRunId: workflowRunId,
);

// 3. Start verification flow
final result = await EntrustIdvSdk.start(config);

// 4. Handle result
if (result.status == 'completed') {
  // Webhook will deliver final decision
  showPendingVerificationUI();
}
```

### Option B: React Native SDK (Interim)

**Status:** Available now (v0.79+)

Use if Flutter SDK is not yet released:
```bash
npm install @entrust.corporation/idvsdk-reactnative
```

### Option C: Web SDK (Fallback)

**Status:** Available now (v11.4+)

For users who can't complete mobile verification:
- Redirect to web flow
- Uses device camera via browser
- Same backend integration

---

## 3. Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           VERIFICATION FLOW                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Flutter    │     │   Supabase   │     │   Entrust    │     │   Supabase   │
│     App      │     │   Edge Fn    │     │    API       │     │    DB        │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │                    │
       │ 1. User requests   │                    │                    │
       │    verification    │                    │                    │
       │───────────────────>│                    │                    │
       │                    │                    │                    │
       │                    │ 2. Create applicant│                    │
       │                    │───────────────────>│                    │
       │                    │                    │                    │
       │                    │ 3. Return applicant_id                   │
       │                    │<───────────────────│                    │
       │                    │                    │                    │
       │                    │ 4. Create workflow │                    │
       │                    │───────────────────>│                    │
       │                    │                    │                    │
       │                    │ 5. Return workflow_run_id               │
       │                    │<───────────────────│                    │
       │                    │                    │                    │
       │                    │ 6. Generate SDK token                    │
       │                    │───────────────────>│                    │
       │                    │                    │                    │
       │                    │ 7. Return SDK token│                    │
       │                    │<───────────────────│                    │
       │                    │                    │                    │
       │ 8. Return SDK token + workflow_run_id  │                    │
       │<───────────────────│                    │                    │
       │                    │                    │                    │
       │ 9. Initialize SDK  │                    │                    │
       │    with token      │                    │                    │
       │                    │                    │                    │
       │ 10. User captures: │                    │                    │
       │     - Passport     │                    │                    │
       │     - Live selfie  │                    │                    │
       │     (liveness)     │                    │                    │
       │                    │                    │                    │
       │ 11. SDK uploads to │                    │                    │
       │     Entrust CDN    │───────────────────────────────────────>│
       │                    │                    │                    │
       │ 12. Verification   │                    │                    │
       │     complete       │                    │                    │
       │<───────────────────│                    │                    │
       │                    │                    │                    │
       │                    │ 13. WEBHOOK: Verification complete      │
       │                    │<───────────────────│                    │
       │                    │                    │                    │
       │                    │ 14. Verify webhook signature            │
       │                    │    Extract: result, gender              │
       │                    │                    │                    │
       │                    │ 15. Update user verification status     │
       │                    │────────────────────────────────────────>│
       │                    │                    │                    │
       │ 16. Realtime: Verification status updated                  │
       │<────────────────────────────────────────────────────────────│
       │                    │                    │                    │
```

---

## 4. Data Storage: What We Store vs. What Entrust Stores

### What WE Store (Supabase)

```sql
CREATE TABLE user_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Entrust references (for audit/support)
  entrust_applicant_id TEXT NOT NULL,
  entrust_workflow_run_id TEXT NOT NULL,
  
  -- Verification result (THE ONLY DATA WE KEEP)
  verification_status TEXT NOT NULL CHECK (verification_status IN 
    ('pending', 'in_progress', 'clear', 'consider', 'rejected')
  ),
  
  -- Gender extracted from passport (verified by Entrust)
  verified_gender TEXT CHECK (verified_gender IN ('male', 'female')),
  
  -- Timestamps
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  
  -- For audit trail
  failure_reason TEXT,
  
  CONSTRAINT unique_user_verification UNIQUE (user_id)
);
```

### What ENTRUST Stores (Their Infrastructure)

| Data | Retention | Location |
|------|-----------|----------|
| Passport/ID images | 90 days default (configurable) | EU or US datacenter |
| Selfie images | 90 days default | EU or US datacenter |
| Biometric vectors | Encrypted, retained | EU or US datacenter |
| Verification results | 7 years (regulatory) | EU or US datacenter |
| Audit logs | 7 years | EU or US datacenter |

### Data Minimization Strategy

1. **No passport images stored in our DB** - Only Entrust reference IDs
2. **No selfie images stored in our DB** - Entrust handles all biometric data
3. **Only verification result + verified_gender stored** - Minimum necessary
4. **Passport data retained by Entrust** - We can request deletion after verification

### Data Deletion Flow

When user requests account deletion:
1. Delete our `user_verifications` record
2. Call Entrust API to delete applicant data
3. Log deletion in audit trail

---

## 5. Webhook Requirements

### Webhook Endpoint

```
POST /api/webhooks/entrust/verification
```

### Webhook Payload Structure

```json
{
  "payload": {
    "resource_type": "workflow_run",
    "action": "completed",
    "object": {
      "id": "workflow_run_123",
      "status": "approved",
      "applicant_id": "applicant_456",
      "documents": [
        {
          "type": "passport",
          "extracted_data": {
            "gender": "female",
            "date_of_birth": "1990-01-15",
            "nationality": "US"
          }
        }
      ],
      "biometric_verification": {
        "status": "clear",
        "face_match_score": 0.98
      }
    },
    "completed_at": "2026-04-01T20:30:00Z"
  },
  "signature": "sha256=<hmac_signature>"
}
```

### Webhook Handler Requirements

1. **Signature Verification** (CRITICAL)
   ```typescript
   // Verify HMAC-SHA256 signature
   const expectedSignature = crypto
     .createHmac('sha256', ENTRUST_WEBHOOK_SECRET)
     .update(JSON.stringify(payload))
     .digest('hex');
   
   if (signature !== `sha256=${expectedSignature}`) {
     throw new Error('Invalid webhook signature');
   }
   ```

2. **Idempotency**
   - Store processed webhook IDs to prevent duplicates
   - Use workflow_run_id as idempotency key

3. **Immediate Response**
   - Return 200 OK within 5 seconds
   - Process asynchronously if needed

4. **Retry Handling**
   - Entrust retries failed webhooks (up to 10 times)
   - Handle duplicate deliveries gracefully

---

## 6. Integration Components Summary

| Component | Technology | Owner |
|-----------|------------|-------|
| Mobile SDK | Entrust IDV SDK (Flutter/React Native) | Mobile Team |
| Backend API | Supabase Edge Functions (Deno) | Backend Team |
| Webhook Handler | Supabase Edge Function | Backend Team |
| Database Schema | PostgreSQL + PostGIS | Backend Team |
| API Key Storage | Supabase Secrets | Security Team |
| Webhook Secret | Supabase Secrets | Security Team |

---

## 7. Environment Configuration

### Sandbox (Testing)

```
ENTRUST_API_URL=https://api.eu.onfido.com/v3.6
ENTRUST_API_TOKEN=sandbox_xxx
ENTRUST_WEBHOOK_SECRET=whsec_sandbox_xxx
```

### Production

```
ENTRUST_API_URL=https://api.eu.onfido.com/v3.6
ENTRUST_API_TOKEN=live_xxx  # Stored in Supabase Secrets
ENTRUST_WEBHOOK_SECRET=whsec_live_xxx  # Stored in Supabase Secrets
```

**Note:** Request live API token from Entrust support before production launch.

---

## 8. Next Steps

1. ✅ Scope complete
2. ⬜ Request Entrust developer account
3. ⬜ Implement backend Edge Functions
4. ⬜ Integrate SDK in Flutter app
5. ⬜ Test with sandbox environment
6. ⬜ Security review of webhook handler
7. ⬜ Request live API token
8. ⬜ Production deployment

---

**Document Status:** ✅ Complete  
**Review Required By:** Backend Lead, Security Team  
**Dependencies:** Entrust developer account, Supabase Edge Functions
