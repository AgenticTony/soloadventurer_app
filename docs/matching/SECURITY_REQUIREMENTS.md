# Security Requirements: Onfido/Entrust Integration

**Version:** 1.0  
**Date:** 2026-04-01  
**Author:** Security Lead  
**Classification:** INTERNAL - Security Review Required

---

## Executive Summary

This document defines security requirements for the Onfido/Entrust ID verification integration supporting women-only mode. Key security controls include:

- API keys stored in Supabase Vault (encrypted at rest)
- Webhook signature verification (HMAC-SHA256)
- Comprehensive audit logging
- GDPR-compliant data handling

---

## 1. API Key Storage

### 1.1 Supabase Vault (Recommended)

Supabase provides a Vault for storing secrets encrypted at rest.

```sql
-- Enable Vault extension
CREATE EXTENSION IF NOT EXISTS vault;

-- Store Entrust API token
SELECT vault.create_secret(
  'entrust_api_token',
  'live_xxxxxxxxxxxxx',  -- The actual token
  'Entrust/Onfido API token for production'
);

-- Store webhook secret
SELECT vault.create_secret(
  'entrust_webhook_secret',
  'whsec_xxxxxxxxxxxxx',  -- The webhook signing secret
  'Entrust webhook verification secret'
);

-- Create a wrapper function for Edge Functions to access secrets
CREATE OR REPLACE FUNCTION get_entrust_api_token()
RETURNS TEXT AS $$
DECLARE
  secret TEXT;
BEGIN
  SELECT decrypted_secret INTO secret
  FROM vault.decrypted_secrets
  WHERE name = 'entrust_api_token';
  
  RETURN secret;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_entrust_webhook_secret()
RETURNS TEXT AS $$
DECLARE
  secret TEXT;
BEGIN
  SELECT decrypted_secret INTO secret
  FROM vault.decrypted_secrets
  WHERE name = 'entrust_webhook_secret';
  
  RETURN secret;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 1.2 Access Control

```sql
-- Grant access only to service role (Edge Functions)
GRANT EXECUTE ON FUNCTION get_entrust_api_token() TO service_role;
GRANT EXECUTE ON FUNCTION get_entrust_webhook_secret() TO service_role;

-- Revoke from public (default)
REVOKE ALL ON FUNCTION get_entrust_api_token() FROM PUBLIC;
REVOKE ALL ON FUNCTION get_entrust_webhook_secret() FROM PUBLIC;
```

### 1.3 Environment-Specific Keys

| Environment | Key Name | Storage |
|-------------|----------|---------|
| Development | `sandbox_*` | Supabase Vault (dev project) |
| Staging | `sandbox_*` | Supabase Vault (staging project) |
| Production | `live_*` | Supabase Vault (prod project) |

**NEVER commit API keys to:**
- Git repositories
- Environment files (.env) in codebase
- Client-side code
- Logs or error messages

### 1.4 Key Rotation

| Event | Action |
|-------|--------|
| Scheduled rotation | Every 90 days, generate new key, update Vault |
| Suspected compromise | Immediate rotation via Entrust dashboard |
| Team member departure | Review access logs, rotate if suspicious |
| Production deployment | Verify correct key in Vault before deploy |

---

## 2. Webhook Signature Verification

### 2.1 Why This Matters

Without signature verification, attackers can:
- Fake successful verifications
- Bypass ID checks entirely
- Enable women-only mode fraudulently

### 2.2 Implementation

```typescript
// Edge Function: /api/webhooks/entrust/verification
import { crypto } from "https://deno.land/std@0.208.0/crypto/mod.ts";

interface WebhookPayload {
  payload: {
    resource_type: string;
    action: string;
    object: {
      id: string;
      status: string;
      applicant_id: string;
      // ... more fields
    };
  };
  signature: string;  // Format: "sha256=<hex>"
}

export async function verifyWebhookSignature(
  payload: WebhookPayload,
  rawBody: string
): Promise<boolean> {
  // 1. Get webhook secret from Vault
  const secret = await getEntrustWebhookSecret();
  
  if (!secret) {
    console.error('CRITICAL: Webhook secret not configured');
    return false;
  }
  
  // 2. Extract signature from header
  const signatureHeader = payload.signature;
  
  if (!signatureHeader || !signatureHeader.startsWith('sha256=')) {
    console.error('Invalid signature format');
    return false;
  }
  
  const providedSignature = signatureHeader.replace('sha256=', '');
  
  // 3. Calculate expected signature
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const bodyData = encoder.encode(rawBody);
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign('HMAC', key, bodyData);
  
  // 4. Convert to hex
  const expectedSignature = Array.from(new Uint8Array(signature))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  // 5. Constant-time comparison (prevent timing attacks)
  if (providedSignature.length !== expectedSignature.length) {
    return false;
  }
  
  let result = 0;
  for (let i = 0; i < providedSignature.length; i++) {
    result |= providedSignature.charCodeAt(i) ^ expectedSignature.charCodeAt(i);
  }
  
  return result === 0;
}
```

### 2.3 Reject Unsigned Webhooks

```typescript
// Main handler
export async function handleEntrustWebhook(request: Request): Promise<Response> {
  const rawBody = await request.text();
  let payload: WebhookPayload;
  
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return new Response('Invalid JSON', { status: 400 });
  }
  
  // CRITICAL: Verify signature BEFORE processing
  const isValid = await verifyWebhookSignature(payload, rawBody);
  
  if (!isValid) {
    // Log potential attack
    await logSecurityEvent({
      type: 'webhook_signature_invalid',
      ip: request.headers.get('x-forwarded-for'),
      user_agent: request.headers.get('user-agent'),
      payload_preview: rawBody.substring(0, 200),
      timestamp: new Date(),
    });
    
    return new Response('Unauthorized', { status: 401 });
  }
  
  // Process verified webhook
  // ...
}
```

---

## 3. Audit Logging Requirements

### 3.1 Audit Table Schema

```sql
CREATE TABLE verification_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Who
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  actor_type TEXT NOT NULL CHECK (actor_type IN ('user', 'system', 'admin', 'webhook')),
  actor_ip TEXT,
  
  -- What
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id TEXT,
  
  -- Details
  details JSONB DEFAULT '{}',
  
  -- Result
  status TEXT NOT NULL CHECK (status IN ('success', 'failure', 'pending')),
  error_message TEXT,
  
  -- When
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for querying
CREATE INDEX idx_audit_user ON verification_audit_log(user_id, created_at DESC);
CREATE INDEX idx_audit_action ON verification_audit_log(action, created_at DESC);
CREATE INDEX idx_audit_resource ON verification_audit_log(resource_type, resource_id);

-- Prevent deletion (security)
ALTER TABLE verification_audit_log SET (
  pg_policy = 'auditing',
  retention_policy = '7 years'
);
```

### 3.2 Required Audit Events

| Event | Action | Details to Log |
|-------|--------|----------------|
| Verification started | `verification.started` | `user_id`, `ip`, `user_agent` |
| SDK token generated | `verification.token_generated` | `user_id`, `applicant_id`, `expires_at` |
| Document captured | `verification.document_captured` | `user_id`, `document_type`, `quality_score` |
| Liveness completed | `verification.liveness_completed` | `user_id`, `success`, `score` |
| Webhook received | `verification.webhook_received` | `workflow_run_id`, `signature_valid` |
| Verification completed | `verification.completed` | `user_id`, `status`, `verified_gender` |
| Women-only enabled | `women_only.enabled` | `user_id`, `verification_id` |
| Gender changed | `gender.changed` | `user_id`, `old_gender`, `new_gender` |
| Gender change blocked | `gender.change_blocked` | `user_id`, `reason`, `days_until_allowed` |
| Account banned | `account.banned` | `user_id`, `reason`, `related_verification_id` |
| API error | `verification.api_error` | `user_id`, `error_code`, `error_message` |
| Webhook signature invalid | `security.webhook_invalid` | `ip`, `payload_preview` |

### 3.3 Audit Helper Function

```typescript
// Edge Function utility
export async function logAuditEvent(event: {
  userId?: string;
  action: string;
  resourceType: string;
  resourceId?: string;
  details?: Record<string, unknown>;
  status: 'success' | 'failure' | 'pending';
  errorMessage?: string;
  request?: Request;
}): Promise<void> {
  await supabase.from('verification_audit_log').insert({
    user_id: event.userId,
    actor_type: event.userId ? 'user' : 'system',
    actor_ip: event.request?.headers.get('x-forwarded-for'),
    action: event.action,
    resource_type: event.resourceType,
    resource_id: event.resourceId,
    details: event.details || {},
    status: event.status,
    error_message: event.errorMessage,
  });
}
```

---

## 4. Gender Change Cooldown & Audit

### 4.1 Database Schema (Already Exists)

```sql
-- In users table
gender_updated_at TIMESTAMPTZ,
previous_gender TEXT,
```

### 4.2 Enforced Cooldown Logic

```typescript
const GENDER_CHANGE_COOLDOWN_DAYS = 90;

export async function canChangeGender(userId: string): Promise<{
  allowed: boolean;
  reason?: string;
  daysUntilAllowed?: number;
}> {
  const { data: user } = await supabase
    .from('users')
    .select('gender, gender_updated_at, previous_gender')
    .eq('id', userId)
    .single();
  
  if (!user) {
    return { allowed: false, reason: 'User not found' };
  }
  
  // First time setting gender
  if (!user.gender_updated_at) {
    return { allowed: true };
  }
  
  // Check cooldown
  const lastChange = new Date(user.gender_updated_at);
  const cooldownEnd = addDays(lastChange, GENDER_CHANGE_COOLDOWN_DAYS);
  const now = new Date();
  
  if (now < cooldownEnd) {
    const daysRemaining = Math.ceil((cooldownEnd.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    
    await logAuditEvent({
      userId,
      action: 'gender.change_blocked',
      resourceType: 'user',
      resourceId: userId,
      details: {
        current_gender: user.gender,
        previous_gender: user.previous_gender,
        days_until_allowed: daysRemaining,
      },
      status: 'failure',
    });
    
    return {
      allowed: false,
      reason: `Gender can only be changed once every 90 days`,
      daysUntilAllowed: daysRemaining,
    };
  }
  
  return { allowed: true };
}

export async function changeGender(
  userId: string,
  newGender: string
): Promise<{ success: boolean; error?: string }> {
  // Check cooldown
  const canChange = await canChangeGender(userId);
  if (!canChange.allowed) {
    return { success: false, error: canChange.reason };
  }
  
  // If changing to female and not verified, require verification
  if (newGender === 'female') {
    const verification = await getVerificationStatus(userId);
    if (!verification || verification.verified_gender !== 'female') {
      return {
        success: false,
        error: 'Gender change to female requires ID verification',
      };
    }
  }
  
  // Update gender (trigger will log previous_gender and timestamp)
  const { error } = await supabase
    .from('users')
    .update({ gender: newGender })
    .eq('id', userId);
  
  if (error) {
    return { success: false, error: 'Database error' };
  }
  
  // Log audit event
  await logAuditEvent({
    userId,
    action: 'gender.changed',
    resourceType: 'user',
    resourceId: userId,
    details: { new_gender: newGender },
    status: 'success',
  });
  
  return { success: true };
}
```

### 4.3 Permanent Audit Trail

All gender changes are permanently logged:
- In `users` table: `previous_gender`, `gender_updated_at`
- In `verification_audit_log`: Every change event
- Retained for 7 years (legal requirement)

---

## 5. GDPR Compliance Checklist

### 5.1 Legal Basis

| Processing Activity | Legal Basis | Justification |
|---------------------|-------------|---------------|
| ID verification | Legitimate Interest | Safety and fraud prevention |
| Gender extraction | Legitimate Interest | Feature access control |
| Biometric processing | Explicit Consent | Obtained before verification |
| Data retention | Legal Obligation | 7-year retention for audit |
| Data sharing with Entrust | Contractual Necessity | Verification requires processor |

### 5.2 Data Subject Rights Implementation

#### Right to Access (Art. 15)

```typescript
// Endpoint: GET /api/user/data-export
export async function exportUserData(userId: string) {
  const data = {
    profile: await supabase.from('users').select('*').eq('id', userId).single(),
    verifications: await supabase.from('user_verifications').select('*').eq('user_id', userId),
    audit_logs: await supabase.from('verification_audit_log').select('*').eq('user_id', userId),
    trips: await supabase.from('trips').select('*').eq('user_id', userId),
    messages: await supabase.from('messages').select('*').or(`sender_id.eq.${userId},receiver_id.eq.${userId}`),
  };
  
  return JSON.stringify(data, null, 2);
}
```

#### Right to Erasure (Art. 17)

```typescript
// Endpoint: DELETE /api/user/account
export async function deleteUserAccount(userId: string) {
  // 1. Anonymize user record (keep for audit)
  await supabase.from('users').update({
    email: `deleted_${userId}@deleted.com`,
    first_name: 'Deleted',
    gender: 'prefer-not-to-say',
    avatar_url: null,
  }).eq('id', userId);
  
  // 2. Delete verification data
  const verification = await supabase.from('user_verifications')
    .select('entrust_applicant_id')
    .eq('user_id', userId)
    .single();
  
  if (verification?.entrust_applicant_id) {
    // Request Entrust to delete applicant data
    await fetch(`https://api.eu.onfido.com/v3.6/applicants/${verification.entrust_applicant_id}`, {
      method: 'DELETE',
      headers: { Authorization: `Token token=${apiToken}` },
    });
  }
  
  // 3. Delete local verification record
  await supabase.from('user_verifications').delete().eq('user_id', userId);
  
  // 4. Delete trips
  await supabase.from('trips').delete().eq('user_id', userId);
  
  // 5. Delete messages (or anonymize)
  await supabase.from('messages').delete().or(`sender_id.eq.${userId},receiver_id.eq.${userId}`);
  
  // 6. Keep audit logs (legal retention) but anonymize user_id
  await supabase.from('verification_audit_log')
    .update({ user_id: null })
    .eq('user_id', userId);
  
  // 7. Log deletion
  await logAuditEvent({
    action: 'account.deleted',
    resourceType: 'user',
    resourceId: userId,
    details: { gdpr_request: true },
    status: 'success',
  });
}
```

#### Right to Rectification (Art. 16)

Users can update their profile information, but:
- Gender changes require re-verification (if changing to female)
- Gender changes have 90-day cooldown
- Verified data cannot be changed without re-verification

#### Right to Object (Art. 21)

Users can:
- Disable women-only mode (stops verification requirement)
- Delete account (stops all processing)
- Opt-out of analytics/tracking (separate consent)

### 5.3 Data Processing Agreement (DPA)

Required with Entrust before production:
- [ ] Signed DPA with Entrust
- [ ] Standard Contractual Clauses (SCCs) if EU data to US
- [ ] Sub-processor list from Entrust
- [ ] Data breach notification procedure

### 5.4 Privacy Notice Requirements

Must disclose in privacy policy:
- ✅ What data is collected (passport, selfie, biometrics)
- ✅ Purpose of collection (verification for women-only mode)
- ✅ Who processes data (SoloAdventurer + Entrust)
- ✅ Retention period (90 days by Entrust, 7 years audit logs by us)
- ✅ Data subject rights (access, delete, rectify, object)
- ✅ How to complain (supervisory authority)

### 5.5 Consent Management

```typescript
// Store consent timestamp
export async function recordVerificationConsent(userId: string) {
  await supabase.from('user_consents').insert({
    user_id: userId,
    consent_type: 'biometric_verification',
    consent_text_version: '1.0',
    consented_at: new Date(),
    ip_address: request.headers.get('x-forwarded-for'),
    user_agent: request.headers.get('user-agent'),
  });
}
```

---

## 6. Security Checklist for Production

### Pre-Launch

- [ ] API tokens stored in Supabase Vault (not env vars)
- [ ] Webhook secret configured in Vault
- [ ] Webhook signature verification tested with real signatures
- [ ] Audit logging enabled and tested
- [ ] GDPR privacy policy updated
- [ ] Consent flow implemented
- [ ] Data export endpoint tested
- [ ] Account deletion flow tested
- [ ] DPA signed with Entrust
- [ ] Penetration testing completed
- [ ] Security review sign-off

### Post-Launch Monitoring

- [ ] Alert on webhook signature failures (>5/hour)
- [ ] Alert on verification failures (>20% rate)
- [ ] Weekly audit log review
- [ ] Monthly DPA compliance review

---

## 7. Incident Response

### Security Incident Classification

| Severity | Example | Response Time | Actions |
|----------|---------|---------------|---------|
| **Critical** | API key leaked, webhook bypass discovered | Immediate | Rotate keys, block traffic, notify Entrust |
| **High** | Multiple failed webhook signatures from same IP | 1 hour | Block IP, investigate source |
| **Medium** | Unusual verification failure spike | 4 hours | Investigate, report to Entrust |
| **Low** | Single failed verification | 24 hours | Log and monitor |

### Webhook Bypass Attempt Response

```typescript
// If webhook signature validation fails
if (!isValidSignature) {
  // 1. Log security event
  await logSecurityEvent({
    type: 'webhook_bypass_attempt',
    severity: 'high',
    ip: request.headers.get('x-forwarded-for'),
    payload_preview: rawBody.substring(0, 500),
  });
  
  // 2. Alert security team (Slack/email)
  await sendSecurityAlert({
    channel: '#security-alerts',
    message: `Webhook signature validation failed from IP ${ip}`,
    severity: 'high',
  });
  
  // 3. Optionally block IP after multiple failures
  const recentFailures = await getRecentSignatureFailures(ip);
  if (recentFailures > 5) {
    await blockIP(ip, duration: '1 hour');
  }
  
  return new Response('Unauthorized', { status: 401 });
}
```

---

**Document Status:** ✅ Complete  
**Review Required By:** CTO, Legal/Compliance, Security Team  
**Next Steps:** 
1. Legal review of GDPR checklist
2. Security team sign-off
3. Schedule penetration test
