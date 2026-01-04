# Operation Queue Testing Reference Guide

## Quick Reference for Manual Testers

This guide provides essential parameters and expected behaviors for testing the Reliable Operation Queue feature.

---

## Key Queue Parameters

### Retry Configuration
- **Max Retries:** 3 attempts (per operation)
- **Base Delay:** 1 second
- **Max Delay:** 5 minutes
- **Jitter Factor:** 0.1 (10% randomness to prevent thundering herd)
- **Backoff Strategy:** Exponential (1s → 2s → 4s → 8s → 16s... up to 5m)

**Expected Behavior:**
- After 1st failure: waits ~1 second before retry
- After 2nd failure: waits ~2 seconds before retry
- After 3rd failure: waits ~4 seconds before retry
- After 4th failure (if max retries > 3): waits ~8 seconds
- Maximum wait between retries: 5 minutes

### Priority Levels
| Priority | Value | Use Cases | Examples |
|----------|-------|-----------|----------|
| **Critical** | 1000 | Emergency operations | SOS alerts, safety-critical operations |
| **High** | 100 | Important user operations | Authentication, payments, user-requested sync |
| **Normal** | 10 | Standard operations | Trip updates, travel notes, content uploads |
| **Low** | 1 | Background operations | Location updates, analytics, logging |

### Aging & Starvation Prevention
- **Aging Threshold:** 5 minutes
- **Aging Boost:** +20 priority
- **Round-Robin Limit:** 3 consecutive operations per priority level

**Expected Behavior:**
- Operations waiting >5 minutes get +20 priority boost
- After 3 consecutive operations of same priority, queue switches to next priority
- Critical operations (≥1000) exempt from round-robin limits
- Low priority (1) becomes 21 after 5 minutes, then 41 after 10 minutes, etc.

### Processing Schedule
- **Processing Interval:** Every 30 seconds
- **Auto-start:** When connectivity is restored
- **Auto-pause:** When connectivity is lost

---

## Operation Types & Behaviors

### Trip Planning Operations
- **Priority:** Normal (10)
- **Deduplication:** ✅ Enabled (for updates only)
  - Key: `trip_{tripId}` for update operations
  - No deduplication for create/delete operations
- **Max Retries:** 3
- **Requires Network:** Yes

**Test Tips:**
- Multiple updates to same trip should replace each other in queue
- Creating and deleting trips are never deduplicated

### Travel Note Operations
- **Priority:** Normal (10)
- **Deduplication:** ❌ Disabled
  - Rationale: Each note is unique user-generated content
- **Max Retries:** 3
- **Requires Network:** Yes

**Test Tips:**
- Every note should appear in queue (no deduplication)
- All notes should be preserved

### Location Update Operations
- **Priority:** Low (1)
- **Deduplication:** ❌ Disabled
  - Rationale: Location updates form a time-series data stream
- **Max Retries:** 3
- **Requires Network:** Yes

**Test Tips:**
- Every location update should queue separately
- Processed after all higher-priority operations
- After 5 minutes, priority boosts to 21, then 41, etc.

---

## Queue States & Transitions

```
[Created] → [Pending] → [Processing] → [Completed]
                ↓               ↓
             [Failed] ←───────┘
                ↓
           [Manually Retried] → [Pending]
                ↓
           [Cleared] → [Removed]
```

### State Descriptions
- **Pending:** Operation is waiting to be processed
- **Processing:** Operation is currently executing
- **Failed:** Operation failed after max retries (3)
- **Completed:** Operation executed successfully (removed from queue)

---

## Expected Behaviors by Scenario

### Scenario 1: Airplane Mode On/Off
| Action | Expected Queue State |
|--------|---------------------|
| Enable airplane mode | New operations queue immediately |
| Create operations | All show as "Pending" |
| Wait 30 seconds | Operations remain pending (no processing) |
| Disable airplane mode | Processing starts within 30s |
| Wait 30-60 seconds | Operations should complete |

### Scenario 2: App Restart
| Action | Expected Behavior |
|--------|------------------|
| Create operations while offline | Operations queue normally |
| Force-kill app | Operations persist to storage |
| Relaunch app | All operations restored with metadata |
| Check timestamps | Should match creation time |
| Go online | All operations process normally |

### Scenario 3: Device Reboot
| Action | Expected Behavior |
|--------|------------------|
| Create operations while offline | Operations queue normally |
| Power off device | Operations saved to persistent storage |
| Power on device | Operations survive reboot |
| Launch app | All operations restored |
| Go online | All operations process normally |

### Scenario 4: Rapid Network Changes
| Action | Expected Behavior |
|--------|------------------|
| Enable airplane mode | Operations queue |
| Disable (10s later) | Processing starts |
| Enable again (3s later) | In-flight operations pause or complete |
| Disable again (10s later) | Processing resumes, retries with backoff |
| Final state | All operations complete successfully |

### Scenario 5: 100+ Operations
| Metric | Expected Value |
|--------|---------------|
| Trip updates to same trip (20) | Only 1 in queue (latest) |
| Travel notes (50) | 50 in queue (no deduplication) |
| Location updates (30) | 30 in queue (no deduplication) |
| Total in queue | ~81 operations |
| Processing time | 5-10 minutes |
| UI performance | Smooth scrolling, no lag |

### Scenario 6: Failed Operations
| Action | Expected Behavior |
|--------|------------------|
| Operation fails | Moves to "Failed" section |
| Check metadata | Shows attempt count (3/3), last error, timestamp |
| Tap "Retry" | Operation moves to pending, attempt count resets to 0 |
| Tap "Retry All" | All failed operations move to pending |
| Tap "Remove" | Confirmation dialog, then removes that operation |
| Tap "Clear All" | Confirmation dialog, then removes all failed |

### Scenario 7: Priority Processing
| Time | Expected Processing Order |
|------|---------------------------|
| 0:00 | Normal priority (10) operations process first |
| 0:30 | After 3 normal operations, low priority (1) operations process |
| 1:00 | After 3 low priority, normal operations process again |
| 5:00+ | Low priority operations boosted to 21, process more frequently |
| 10:00+ | Low priority boosted to 41, compete with normal (10) |

---

## UI Elements Reference

### Queue Status Indicator (AppBar Badge)
- **Icon:** Cloud sync (Icons.cloud_sync)
- **Badge:** Shows pending operation count
- **Hidden:** When pending count = 0
- **99+:** Shows "99+" for counts ≥ 99
- **Tap:** Navigates to Operation Queue screen
- **Animation:** Material badge animates count changes

### Operation Queue Screen
| Element | Description |
|---------|-------------|
| **AppBar** | Shows pending and failed operation counts |
| **Processing Banner** | Blue banner at top when queue is actively processing |
| **Pending Section** | Lists all pending operations |
| **Failed Section** | Lists all failed operations with error details |
| **FAB** | Manual queue processing trigger |
| **Pull-to-Refresh** | Refreshes queue state |
| **Empty State** | Friendly message when queue is clear |

### Operation List Item
| Element | Description |
|---------|-------------|
| **Icon** | Type-specific (flight, note, location) with colored background |
| **Status Chip** | Pending (grey), Retrying (blue), Failed (red) |
| **Priority Label** | Critical, High, Normal, Low |
| **Title** | Operation type and description |
| **Retry Metadata** | Attempt count and last attempt time |
| **Error Message** | Shown for failed operations |
| **Relative Time** | "Just now", "2m ago", "1h ago", "2d ago" |
| **Actions** | Retry button (failed), Remove button |

---

## Common Testing Pitfalls

### ❌ Don't
- Don't expect operations to process instantly (30s intervals)
- Don't test aging with wait times <5 minutes
- Don't assume failed operations will auto-retry indefinitely (max 3 attempts)
- Don't expect trip updates to queue multiple times (deduplication)
- Don't test with <10 operations for stress testing

### ✅ Do
- Do wait at least 30 seconds between checking queue state
- Do wait 5+ minutes to observe aging behavior
- Do create 100+ operations for stress testing
- Do force-kill app during queue operations
- Do test with airplane mode toggles
- Do check persistence after device reboot
- Do verify deduplication with trip updates
- Do verify NO deduplication with notes and locations
- Do monitor console logs for debug output
- Do take screenshots of any unexpected behavior

---

## Debug Logging

The queue outputs debug logs that can help verify behavior:

```
// Operation queued
Operation {id} added to queue (priority: {priority})

// Duplicate detected
Duplicate operation found: {deduplicationKey}, replacing old operation

// Priority aging
Operation {id} has been waiting {minutes}min, boosting priority from {old} to {new}

// Backoff period
Operation {id} is in backoff period. Can retry in {seconds}s

// Processing
Processing queue: {pending} pending, {failed} failed
Processing operation {id} (attempt {attemptCount}/{maxRetries})
Operation {id} completed successfully
Operation {id} failed: {error}

// Round-robin
Processed 3 operations at priority {level}, skipping to next level
```

**How to View:**
- Android: `adb logcat | grep flutter`
- iOS: Xcode Console
- Emulator/Simulator: Run app with `flutter run` from command line

---

## Performance Benchmarks

### Expected Performance
| Metric | Target | Acceptable |
|--------|--------|------------|
| Queue add operation | <100ms | <500ms |
| Queue save/load | <500ms | <2s |
| UI render (100 items) | <200ms | <1s |
| Processing cycle | 30s interval | ±5s |
| Memory overhead | <50MB | <100MB |

### Warning Signs
- ⚠️ UI lag when scrolling queue
- ⚠️ App crashes when adding operations
- ⚠️ Operations lost after app restart
- ⚠️ Duplicate operations appearing
- ⚠️ Processing never completes
- ⚠️ Memory continuously growing

---

## Testing Checklist Summary

### Core Functionality
- [ ] Operations queue when offline
- [ ] Operations process when online
- [ ] Queue persists across app restarts
- [ ] Queue persists across device reboots
- [ ] Failed operations can be retried manually
- [ ] Failed operations can be cleared
- [ ] Priority processing works correctly
- [ ] Deduplication works for trip updates
- [ ] Notes are never deduplicated
- [ ] Location updates are never deduplicated

### Retry Logic
- [ ] Exponential backoff observable (1s, 2s, 4s, 8s...)
- [ ] Max retries enforced (3 attempts)
- [ ] Failed operations show error details
- [ ] Retry resets attempt count
- [ ] Backoff period respected

### UI/UX
- [ ] Queue status indicator shows correct count
- [ ] Badge hides when empty
- [ ] Pull-to-refresh works
- [ ] Empty state displays
- [ ] Processing status banner shows/hides correctly
- [ ] Confirmation dialogs for destructive actions
- [ ] Relative timestamps format correctly

### Edge Cases
- [ ] 100+ operations handled smoothly
- [ ] Rapid network toggles handled
- [ ] Concurrent additions work
- [ ] Aging boost observable (>5 min wait)
- [ ] Round-robin prevents starvation
- [ ] No memory leaks
- [ ] No data loss

---

## Questions or Issues?

If you encounter unexpected behavior during testing:
1. Capture the exact steps to reproduce
2. Take screenshots
3. Copy console logs (debug output)
4. Note the device, OS version, and app version
5. Document expected vs actual behavior

**Test Results Form:** See `manual_testing_plan.md` for the full test results template.
