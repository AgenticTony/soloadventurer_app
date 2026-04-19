# Sprint 6.7: Safety Enhancements — "Guardian" Check-In System
**Duration:** Weeks 16-17
**Theme:** Build the single most defensible, differentiating feature in the product. The Guardian check-in system is the safety moat that makes SoloAdventurer categorically different from every other social/travel/dating platform. Combined with ID verification, it creates a two-punch safety story no competitor has.
**Depends on:** Sprint 6.5, Sprint 6.6

## Guiding Principles
1. **Guardian is the brand.** This feature repositions SoloAdventurer from "travel social app with verification" to "the platform that watches your back." It deserves its own name, its own hero space in the app, and its own marketing story.
2. **Fraud prevention is invisible; trust signals are visible and earned.** The photo/liveness check at signup is silent infrastructure. The ID Verified badge is the visible trust signal. Guardian is the active safety layer that intervenes if something goes wrong.
3. **Free tier is genuinely safe.** One contact, standard check-ins, in-app notifications. Not theater — real protection. Pro tier adds more contacts, location sharing, SMS escalation, and priority response.
4. **Default to escalating, not silencing.** Better to notify a contact unnecessarily than to fail when needed. Users can dismiss false alarms easily, but the system never defaults to silence.
5. **Never claim prevention.** Guardian reduces response time. It does not prevent harm. All copy reflects this honestly.
6. **Contact-side experience is lightweight.** Contacts don't need to install the app. SMS + short URL to a simple web page. Sarah's mom in the UK can respond to a check-in escalation without ever hearing of SoloAdventurer.
7. **Legal and operational exposure is real.** Liability disclaimers required. Emergency services integration deferred to Year 2. Start with contact-only notification.

---

## Existing Infrastructure (Already Built)

The following are already implemented and will be extended:

- `process-checkin` Edge Function — create, complete, escalate check-ins
- `ScheduleCheckInScreen` — schedule with time/location triggers
- `ManualCheckInScreen` — manual check-in
- `BackgroundCheckInServiceImpl` — Workmanager periodic monitoring
- `AddEditTrustedContactScreen` — manage emergency contacts
- `trigger-sos` Edge Function — SOS alerts
- `process-safety-alert` Edge Function — Twilio SMS + Resend email to contacts
- `check_ins` and `trusted_contacts` Supabase tables
- Escalation flow: overdue check-in → "missed" status → notify contacts

---

## Tasks

### 6.7.1 — Guardian auto-prompt at meetup/connection creation
The check-in should be offered at the moment of highest intent — when a user is about to meet someone.
- [ ] When a user confirms a meetup or connection with another traveler, show Guardian prompt: "Meeting someone new? Let us check in on you." with one-tap enable
- [ ] Pre-populate: who they're meeting (name, photo from profile), meeting location, date/time
- [ ] User sets expected duration ("Coffee — 1-2 hours" / "Dinner — 2-3 hours" / "Day activity — 4-6 hours" / Custom)
- [ ] Smart defaults: check-in intervals based on duration (e.g., first check-in at 75% of expected duration, then every 2 hours)
- [ ] If user has trusted contacts, auto-select the primary one. If none, prompt to add one first.
- [ ] **Test:** Auto-prompt appears at meetup confirmation, pre-populated correctly

### 6.7.2 — Two-stage check-in notification flow
The current escalation jumps straight to "missed → notify contacts." This needs a graduated approach that gives the user multiple chances to respond before escalating.
- [ ] **Stage 1 — Gentle check-in** (at scheduled time): in-app notification — "Hey, just checking in. Everything going well?" with "I'm good!" button. 15 minutes to respond.
- [ ] **Stage 2 — Urgent check-in** (if no response after 15 min): full-screen notification with sound/vibration, more persistent. "We haven't heard from you — tap to confirm you're okay." 15 minutes to respond.
- [ ] **Stage 3 — Contact notification** (if no response after Stage 2): SMS + email to designated contact(s) with context — who the user was meeting, where, when the meetup started, last known location if available. Framing: "Sarah hasn't responded to a check-in during her meetup with [Name] in [City]. She may be fine, but we wanted you to know."
- [ ] User can end the meetup at any time with "I'm heading home" button — stops all future check-ins
- [ ] User can extend the meetup ("Having a great time, staying longer") — resets the timer
- [ ] All stages logged in `check_ins` table with timestamps for audit trail
- [ ] **Test:** Two-stage notification flow with timeout, escalation to contact

### 6.7.3 — Contact-side experience (SMS + web)
Contacts should not need to install the app to receive or respond to check-in escalations.
- [ ] When escalation triggers, contact receives SMS via Twilio: "[Name] hasn't responded to a safety check-in. They were meeting [Other Person] at [Location]. Tap to see details: [short URL]"
- [ ] Short URL loads a lightweight web page (hosted on Supabase or Vercel) showing:
  - User's name and photo (if they opted in to sharing)
  - Who they were meeting (name, photo)
  - Meeting location and start time
  - Last known location (if user opted in to location sharing — Pro feature)
  - Time since last response
- [ ] Contact can respond: "I've reached them, they're fine" / "I can't reach them" / "Please escalate further"
- [ ] Contact response is logged in the check-in record
- [ ] If contact confirms user is safe, escalation ends. If contact can't reach user, system logs and can notify user that their contact is concerned.
- [ ] **Test:** SMS delivery, web page loads, contact can respond, response logged

### 6.7.4 — Guardian Pro upgrade moment
Guardian is the second blockbuster Pro feature alongside ID verification. The upgrade moment is at check-in creation.
- [ ] **Free tier:** 1 designated contact, in-app notifications only, standard intervals, no location sharing with contacts
- [ ] **Pro tier:** up to 3 contacts, SMS + email notifications to contacts, optional location sharing on escalation, custom intervals, priority response
- [ ] At check-in creation, if user is on free tier and tries to add a second contact or enable location sharing: contextual modal — "Add more emergency contacts and share your location — upgrade to Explorer" (NOT "pay for safety")
- [ ] The Guardian settings page shows free vs Pro features clearly, without negative framing for free users
- [ ] **Test:** Free user limited to 1 contact, Pro user can add multiple

### 6.7.5 — Share My Meetup (~3 screens)
The "Share My Meetup" feature from the original Sprint 6.7 plan — a complementary feature where users proactively share meetup details with contacts before the meetup even starts.
- [ ] `ShareMeetupScreen` — create shareable meetup details (who, where, when)
- [ ] `MeetupDetailPreviewScreen` — preview link shared with trusted contacts
- [ ] `TrustedContactMeetupView` — what trusted contacts see when receiving a share
- [ ] Generates shareable link with: match name, photo, meeting location, date/time
- [ ] Real-time updates if plans change
- [ ] This is separate from (but complementary to) the Guardian auto-check-in. Share My Meetup = proactive info share. Guardian = reactive safety net.
- [ ] **Test:** Share My Meetup widget tests

### 6.7.6 — AI message moderation (~2-3 screens)
Kept from original plan. Background scanning, not blocking.
- [ ] `MessageModerationService` — Supabase Edge Function that scans messages in background
- [ ] "This message may be inappropriate" overlay — AI flags messages, recipient sees overlay with View / Delete / Report options
- [ ] Sender-side: no blocking — message delivers immediately
- [ ] Hard 2-second timeout fallback — if Edge Function doesn't respond, message delivers
- [ ] "Are you sure?" sender warning for potentially offensive messages (optional, post-flag)
- [ ] Report flow streamlined from flag prompt
- [ ] **Test:** Moderation overlay widget tests, timeout fallback test

### 6.7.7 — Liability disclaimer (required before ship)
- [ ] Create `LiabilityDisclaimerModal` — reusable modal component
- [ ] Content: Guardian is a communication aid, NOT a substitute for calling emergency services directly. Users should always contact local authorities in an emergency.
- [ ] Must appear on first use of SOS screen, Guardian check-in, and Share My Meetup
- [ ] User must acknowledge before proceeding
- [ ] Store acknowledgment in local preferences
- [ ] ZClaw must approve the wording before ship
- [ ] **Test:** Disclaimer modal widget test

### 6.7.8 — Safety center updates
- [ ] Rename/update safety hub to feature Guardian prominently
- [ ] Add "Guardian Check-In" quick action card (primary position)
- [ ] Add "Share My Meetup" quick action card
- [ ] Add "Message Safety" section
- [ ] Update safety tips with Guardian usage guidance
- [ ] Add liability disclaimer trigger on first SOS/Guardian/Share use
- [ ] Guardian status indicator: active check-ins shown with countdown/time

### 6.7.9 — Guardian naming and branding
- [ ] Decide on feature name — "Guardian" is the working name. Alternatives: "Check-In," "Lookout," "Travel Buddy," "Safe Meet"
- [ ] Create feature icon (shield with checkmark or similar)
- [ ] Ensure the name works in word-of-mouth: "I use SoloAdventurer — it has this feature called [X] that checks in on me when I'm meeting strangers"
- [ ] Copy must never say "we keep you safe" — always "we help you stay connected with someone who cares about you"

### 6.7.10 — International considerations
- [ ] Timezone handling: if user is in Thailand and contact is in the UK, don't send 3am notifications for routine check-ins. Only bypass timezone silence for escalated alerts.
- [ ] Consider SMS delivery reliability by country (Twilio coverage varies)
- [ ] Guardian should work offline: if the user has no signal at check-in time, the system should default to escalating (not silently failing)

---

## Free vs Pro Guardian Feature Split

| Feature | Free | Explorer (Pro) |
|---|---|---|
| Designated contacts | 1 | Up to 3 |
| Check-in notifications | In-app only | In-app + SMS + email |
| Location sharing with contacts | No | Yes (on escalation) |
| Custom check-in intervals | No (smart defaults) | Yes |
| Auto-prompt at meetup | Yes | Yes |
| Share My Meetup | Yes | Yes |
| Priority response for escalations | No | Yes |
| Emergency services integration | No | Year 2 (post-launch) |

---

## Technical Architecture

### Check-In Flow
```
User confirms meetup → Guardian prompt → Sets duration → Check-in created
                                                            ↓
                                                    Scheduled time arrives
                                                            ↓
                                              Stage 1: Gentle in-app check
                                                            ↓ (no response 15 min)
                                              Stage 2: Urgent full-screen check
                                                            ↓ (no response 15 min)
                                              Stage 3: SMS/email to contact(s)
                                                            ↓
                                              Contact responds via web/SMS
                                                            ↓
                                              Resolution: safe / escalated / unresolved
```

### Existing Edge Functions Used
- `process-checkin` — create, complete, escalate (extend with two-stage logic)
- `process-safety-alert` — Twilio SMS + Resend email to contacts (extend with Guardian context)
- `trigger-sos` — manual SOS (unchanged)
- `send-push-notification` — in-app notifications (extend with Guardian notification types)

### New Database Fields Needed
- `check_ins` table: add `stage` (1/2/3), `meetup_with_user_id`, `meetup_with_name`, `meetup_location_text`, `expected_duration_minutes`, `contact_response`, `contact_response_at`
- `trusted_contacts` table: add `is_primary` (boolean), `phone_number` (for SMS), `timezone` (for smart notification timing)

---

## Test Plan
- [ ] Unit: Two-stage escalation timer logic (Stage 1 → Stage 2 → Contact)
- [ ] Unit: Free vs Pro contact limits (1 vs 3)
- [ ] Unit: Timezone-aware notification scheduling
- [ ] Widget: Guardian auto-prompt at meetup confirmation
- [ ] Widget: Check-in notification stages (gentle, urgent)
- [ ] Widget: Pro upgrade modal when adding second contact
- [ ] Widget: Liability disclaimer modal
- [ ] Integration: Full flow — create meetup → auto-prompt → check-in scheduled → Stage 1 → Stage 2 → contact notified
- [ ] Integration: Contact web page loads and accepts response
- [ ] Integration: User ends meetup early → no further check-ins
- [ ] Integration: AI moderation overlay with 2-second timeout fallback
- [ ] Edge Function: `process-checkin` two-stage escalation logic
- [ ] `flutter analyze` — no errors
- [ ] `flutter test` — all tests pass

## Definition of Done
- [ ] Guardian auto-prompts at meetup/connection confirmation with pre-populated details
- [ ] Two-stage notification flow works (gentle → urgent → contact)
- [ ] Contact-side experience works via SMS + web (no app install needed)
- [ ] Free tier: 1 contact, in-app notifications. Pro: 3 contacts, SMS/email, location sharing
- [ ] Pro upgrade moment at check-in creation (contextual, not "pay for safety")
- [ ] Share My Meetup creates shareable links
- [ ] AI moderation runs in background without blocking message delivery
- [ ] 2-second timeout fallback tested and working
- [ ] Liability disclaimer appears on first use of SOS, Guardian, and Share My Meetup
- [ ] ZClaw has signed off on all disclaimer copy
- [ ] Guardian naming finalized and consistent throughout the app
- [ ] Safety hub updated with Guardian as primary feature
- [ ] All timezone and international edge cases handled
- [ ] Full audit trail for every check-in (all stages, responses, timestamps)
- [ ] All tests pass: `flutter test`
- [ ] `flutter analyze` — no errors

## Verification
```bash
flutter analyze   # No errors in Sprint 6.7 files
flutter test      # All new + existing tests pass
# Manual: confirm meetup → Guardian prompts → schedule check-in → walk through two stages → contact receives SMS → respond via web → resolution logged
# Manual: AI moderation flags a test message → overlay appears → timeout fallback works
# Manual: liability disclaimer on first SOS, Guardian, and Share use
```

## Post-Launch (Not This Sprint)
- Emergency services integration (911/999/112) — requires serious legal/operational preparation
- Predictive check-ins based on calendar/events
- Guardian analytics dashboard (check-in completion rates, escalation frequency, response times)
- Multi-contact sequential escalation (Contact 1 → wait → Contact 2 → wait → Contact 3)
- Guardian as brand centerpiece in marketing (press pitches, ambassador talking points)
- Liability insurance / errors and omissions coverage for safety features
