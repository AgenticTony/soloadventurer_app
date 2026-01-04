# Manual Testing Plan: Reliable Operation Queue
**Subtask:** 6.4 - Manual Testing & Edge Cases
**Date:** 2025-01-04
**Tester:** _________________
**Device:** _________________
**OS Version:** _________________

## Overview
This document provides step-by-step instructions for manually testing the Reliable Operation Queue feature under real-world scenarios. Each test case includes setup steps, execution instructions, expected results, and verification criteria.

---

## Test Environment Setup

### Prerequisites
1. Build the app in debug mode
2. Have a test account ready
3. Ensure device has internet connectivity initially
4. Clear app data before starting (optional, for clean state)

### Accessing Queue UI
- **Home Screen:** Tap the cloud sync badge icon in the AppBar
- **Settings:** Profile Settings → Data & Sync → Operation Queue
- **Direct:** Navigate to `/operation-queue` route (if using deep links)

### Queue Status Indicators
- **Empty Queue:** Badge is hidden
- **Pending Operations:** Badge shows count (e.g., "3", "99+")
- **Failed Operations:** Red section appears in queue screen
- **Processing:** Blue banner appears at top of queue screen

---

## Test Scenarios

### Test 1: Airplane Mode On/Off Cycles

#### Purpose
Verify that operations queue correctly when offline and process when connection is restored.

#### Setup
1. Start app with internet connection
2. Navigate to Operation Queue screen to see initial state

#### Steps
1. **Enable Airplane Mode** on device
2. Create a trip update:
   - Go to Trip Planning screen
   - Modify an existing trip (add/remove destination)
   - Save changes
3. **Verify** Operation Queue shows 1 pending operation
4. Create a travel note:
   - Navigate to Travel Notes
   - Create a new note with text
   - Save note
5. **Verify** Operation Queue shows 2 pending operations
6. Wait 30 seconds, **verify** operations remain in pending state
7. **Disable Airplane Mode**
8. **Verify** operations process automatically (queue should clear within 30-60 seconds)
9. **Verify** success notifications appear (if implemented)

#### Expected Results
- ✅ Operations queue immediately when offline
- ✅ Queue persists across the entire offline period
- ✅ Operations process automatically when connection restored
- ✅ No data loss occurs
- ✅ Queue clears after successful processing

#### Notes
- Test with multiple on/off cycles (3-5 times)
- Verify exponential backoff by observing operation timestamps
- Check that operations don't duplicate

---

### Test 2: App Restart with Pending Operations

#### Purpose
Ensure operations persist across app restarts.

#### Setup
1. Start app with internet connection
2. Enable Airplane Mode

#### Steps
1. Create 3-5 operations while offline:
   - 2 trip updates (modify trip dates, add destination)
   - 1 travel note
   - 1 location update (if available)
2. **Verify** Operation Queue shows all pending operations
3. **Force-kill** the app (swipe away from recent apps)
4. **Wait** 10 seconds
5. **Relaunch** the app
6. Navigate to Operation Queue screen
7. **Verify** all operations are still present with correct metadata:
   - Operation types correct
   - Timestamps preserved
   - Attempt counts preserved (should be 0)
8. Disable Airplane Mode
9. **Verify** operations process successfully

#### Expected Results
- ✅ All operations persist across app restart
- ✅ Operation metadata preserved (timestamps, types, attempt counts)
- ✅ No data loss
- ✅ Operations process normally after connection restored

#### Notes
- Test with multiple restart cycles
- Check storage (shared_preferences) to verify persistence
- Try rapid restart (kill immediately after operation)

---

### Test 3: Device Reboot with Pending Operations

#### Purpose
Ensure operations survive device shutdown and restart.

#### Setup
1. Start app with internet connection
2. Enable Airplane Mode

#### Steps
1. Create 5-10 operations while offline:
   - Multiple trip updates
   - Multiple travel notes
   - Several location updates
2. **Verify** Operation Queue shows all operations
3. **Power off** the device completely
4. **Wait** 30 seconds
5. **Power on** the device
6. **Unlock** and **launch** the app
7. Navigate to Operation Queue screen
8. **Verify** all operations are restored:
   - Correct count of operations
   - All metadata preserved
   - No corruption
9. Disable Airplane Mode
10. **Verify** all operations process successfully

#### Expected Results
- ✅ Operations persist across device reboot
- ✅ No operation data corruption
- ✅ Queue state fully restored
- ✅ Operations process correctly after reboot

#### Notes
- This is the most critical test for persistence
- Verify shared_preferences data survives reboot
- Check that timestamps are still accurate after reboot

---

### Test 4: Rapid Network State Changes

#### Purpose
Test queue behavior with unstable connection.

#### Setup
1. Start app with internet connection
2. Have operations ready to create

#### Steps
1. **Enable Airplane Mode**
2. Create 3 operations quickly (within 10 seconds)
3. **Wait** 5 seconds
4. **Disable Airplane Mode**
5. **Wait** 3 seconds (operations start processing)
6. **Enable Airplane Mode** again (interrupt processing)
7. **Verify** operations still in queue or moved to failed
8. **Wait** 10 seconds
9. **Disable Airplane Mode**
10. **Verify** operations retry and process successfully

#### Expected Results
- ✅ Queue handles rapid on/off transitions
- ✅ Operations don't get lost during transitions
- ✅ In-progress operations handle interruption gracefully
- ✅ Retry logic works correctly after interruption

#### Notes
- Try toggling airplane mode 5-10 times rapidly
- Watch for any race conditions or duplicate operations
- Verify exponential backoff resets properly after successful retry

---

### Test 5: Low Memory Conditions

#### Purpose
Ensure queue doesn't cause memory issues with large operation counts.

#### Setup
1. Use a device with limited memory (if available)
2. Enable Airplane Mode

#### Steps
1. **Create 20-50 operations** while offline:
   - Rapidly create trip updates, notes, location updates
   - Try to create within 1-2 minutes
2. **Verify** all operations appear in queue
3. **Check** app performance:
   - Scrolling should be smooth
   - No UI lag or freezing
   - No crashes
4. **Force-kill** app to test memory pressure
5. **Relaunch** app
6. **Verify** all operations load without memory issues
7. Disable Airplane Mode
8. **Monitor** as operations process:
   - Processing should be smooth
   - No memory spikes
   - All operations complete

#### Expected Results
- ✅ App handles 100+ operations without issues
- ✅ Memory usage remains reasonable
- ✅ No crashes or freezes
- ✅ Smooth UI performance even with large queues
- ✅ All operations process successfully

#### Notes
- Use device monitoring tools if available (Android Studio, Xcode)
- Check for memory leaks during queue processing
- Test with even larger queues if device allows (200+ operations)

---

### Test 6: Operation Queue with 100+ Operations

#### Purpose
Stress test the queue with a large number of operations.

#### Setup
1. Enable Airplane Mode
2. Prepare to create many operations quickly

#### Steps
1. **Create 100+ operations** while offline:
   - Modify same trip 20 times (test deduplication)
   - Create 50 travel notes
   - Add 30 location updates
2. **Verify** queue shows operations (may be less due to deduplication)
3. **Check** deduplication worked:
   - Trip updates for same trip should only show latest
   - Notes should all be present (no deduplication)
   - Location updates should all be present (no deduplication)
4. **Verify** UI performance:
   - List scrolls smoothly
   - No lag when opening queue screen
   - Badge shows correct count
5. Disable Airplane Mode
6. **Monitor** processing:
   - Operations should process in batches
   - Priority processing should work (normal before low)
   - All operations complete within reasonable time
7. **Verify** queue clears completely

#### Expected Results
- ✅ Queue handles 100+ operations
- ✅ Deduplication prevents redundant trip updates
- ✅ UI remains responsive
- ✅ All operations process successfully
- ✅ Processing completes within 5-10 minutes

#### Notes
- Pay attention to deduplication behavior
- Monitor processing order (priority-based)
- Check that round-robin prevents starvation
- Verify no operations get "stuck"

---

### Test 7: Concurrent Operation Additions

#### Purpose
Test queue behavior when multiple operations are added simultaneously.

#### Setup
1. Enable Airplane Mode
2. Have multiple app screens ready to navigate

#### Steps
1. **Rapidly add 10 operations** across different screens:
   - Navigate to trip planning → add 3 trip updates
   - Navigate to travel notes → add 5 notes
   - Navigate to location tracking → trigger 2 location updates
   - Complete all within 10-15 seconds
2. **Verify** all 10 operations appear in queue
3. **Check** operation order and metadata
4. **Force-kill** app mid-creation (after 5 operations)
5. **Relaunch** app
6. **Verify** partial state is preserved (5 operations)
7. Add 5 more operations
8. **Verify** queue now shows all 10 operations
9. Disable Airplane Mode
10. **Verify** all operations process successfully

#### Expected Results
- ✅ All concurrent additions are captured
- ✅ No race conditions or lost operations
- ✅ Queue state remains consistent
- ✅ Operations process correctly even with rapid additions

#### Notes
- Try adding operations from different screens simultaneously
- Test rapid app switching while adding operations
- Verify persistence survives mid-operation app crash

---

### Test 8: SOS Operation During Queue Processing

#### Purpose
Verify critical operations bypass normal queue processing.

#### Setup
1. Enable Airplane Mode
2. Create 10-20 normal priority operations
3. Note: You'll need an SOS/emergency feature or simulate with a critical operation

#### Steps
1. **Create** 10 normal operations while offline
2. **Verify** queue shows 10 pending operations
3. **Disable Airplane Mode** (start processing)
4. **Immediately trigger SOS/Critical operation**:
   - If app has SOS feature: Trigger it
   - Otherwise: Note this test requires SOS implementation
5. **Verify** critical operation jumps to front of queue
6. **Verify** critical operation processes first
7. **Verify** normal operations continue after critical completes
8. **Check** queue UI shows priority indicators

#### Expected Results
- ✅ Critical operation prioritized above all others
- ✅ Critical operation bypasses round-robin limits
- ✅ Normal operations resume after critical completes
- ✅ Priority indicators visible in UI

#### Notes
- If SOS feature not implemented yet, skip this test or simulate with high-priority operation
- Critical priority should be 1000, much higher than normal (10)
- Test that multiple critical operations all process before normal ones

---

### Test 9: Failed Operations Management

#### Purpose
Test manual retry and cleanup of failed operations.

#### Setup
1. Enable Airplane Mode
2. Create operations that will fail (if possible)
   - Or simulate by having operations that require special permissions

#### Steps
1. **Create** 3-5 operations
2. **Disable Airplane Mode** and let them process
3. **Simulate failures** (if possible):
   - Revoke app permissions
   - Or use invalid authentication
   - Or make operations that hit server errors
4. **Verify** operations move to Failed section
5. **Check** failed operation details:
   - Error message displayed
   - Retry count visible
   - Last attempt timestamp shown
6. **Test individual retry**:
   - Tap "Retry" button on one failed operation
   - **Verify** operation moves back to pending
   - **Verify** operation retries processing
7. **Test "Retry All"**:
   - Tap "Retry All" button
   - **Verify** all failed operations move to pending
   - **Verify** all retry processing
8. **Test "Clear All"**:
   - Create new failed operations
   - Tap "Clear All" button
   - **Verify** confirmation dialog appears
   - Confirm clear
   - **Verify** all failed operations removed
9. **Test individual removal**:
   - Create failed operation
   - Tap "Remove" button on operation
   - **Verify** confirmation dialog appears
   - Confirm removal
   - **Verify** specific operation removed

#### Expected Results
- ✅ Failed operations display with error details
- ✅ Individual retry works correctly
- ✅ Retry all works correctly
- ✅ Clear all removes all failed operations
- ✅ Individual removal works
- ✅ Confirmation dialogs prevent accidental data loss
- ✅ Retry resets attempt count

#### Notes
- If hard to create failed operations, consider mocking network failures
- Test with various error states (network errors, auth errors, server errors)
- Verify retry metadata (attempt count resets to 0)

---

### Test 10: Queue Processing Behavior

#### Purpose
Verify queue processing mechanics work as expected.

#### Setup
1. Enable Airplane Mode
2. Have app ready

#### Steps
1. **Create** operations with different priorities:
   - 5 normal priority (trip updates, notes)
   - 5 low priority (location updates)
2. **Verify** sorting shows normal before low in queue
3. **Wait** 10 minutes (or manually adjust timestamps if possible)
4. **Verify** aging boost: low priority operations should have increased priority
5. Disable Airplane Mode
6. **Monitor** processing order:
   - Watch queue screen as operations process
   - **Verify** normal operations process first
   - **Verify** low priority operations wait
   - **Verify** after 3 normal operations, some low priority process (round-robin)
7. **Check** processing status banner appears and disappears

#### Expected Results
- ✅ Operations sorted by priority initially
- ✅ Aging boosts old operations (>5 minutes)
- ✅ Round-robin prevents starvation (max 3 consecutive per priority)
- ✅ Processing status banner visible during active processing
- ✅ All operations complete successfully

#### Notes
- Watch queue screen closely to observe processing order
- Note any operations that seem "stuck"
- Verify round-robin by counting consecutive operations per priority

---

## General Verification Checklist

For each test, verify the following:

### UI Behavior
- [ ] Queue status indicator badge shows correct count
- [ ] Badge hides when queue is empty
- [ ] Operation list displays correctly
- [ ] Icons match operation types (flight, note, location)
- [ ] Status chips display correctly (Pending, Retrying, Failed)
- [ ] Priority labels visible (Critical, High, Normal, Low)
- [ ] Relative timestamps format correctly (just now, 2m ago, 1h ago)
- [ ] Pull-to-refresh works
- [ ] Processing status banner appears/disappears appropriately
- [ ] Empty state shows friendly message

### Data Integrity
- [ ] No operations lost during any scenario
- [ ] Operation metadata preserved (timestamps, attempt counts, errors)
- [ ] Deduplication works correctly for trip updates
- [ ] Notes are never deduplicated (unique content preserved)
- [ ] Location updates never deduplicated (time-series preserved)

### Performance
- [ ] UI remains responsive with large queues
- [ ] Scrolling is smooth
- [ ] No memory leaks detected
- [ ] No crashes or freezes
- [ ] Processing completes in reasonable time

### Error Handling
- [ ] Failed operations show clear error messages
- [ ] Retry mechanism works as expected
- [ ] Exponential backoff is observable (increasing delays)
- [ ] Max retries enforced (operations move to failed after 3 attempts)
- [ ] Confirmation dialogs prevent accidental data loss

---

## Test Results Template

### Test 1: Airplane Mode On/Off Cycles
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 2: App Restart with Pending Operations
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 3: Device Reboot with Pending Operations
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 4: Rapid Network State Changes
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 5: Low Memory Conditions
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 6: Operation Queue with 100+ Operations
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 7: Concurrent Operation Additions
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 8: SOS Operation During Queue Processing
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 9: Failed Operations Management
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

### Test 10: Queue Processing Behavior
- **Status:** ⬜ Pass ⬜ Fail ⬜ N/A
- **Issues Found:**
- **Notes:**

---

## Summary

### Overall Assessment
- **Total Tests:** 10
- **Passed:** _____
- **Failed:** _____
- **N/A:** _____

### Critical Issues Found
1.
2.
3.

### Minor Issues Found
1.
2.
3.

### Recommendations
1.
2.
3.

### Tester Comments
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________

---

## Additional Notes

### Device Information
- Device Model: _________________
- OS Version: _________________
- App Version: _________________
- Available Memory: _________________
- Available Storage: _________________

### Testing Environment
- Testing Date: _________________
- Testing Duration: _________________
- Network Conditions: _________________
- Background Apps: _________________

### Special Considerations
- Any tests skipped? Why? _____________________________________________
- Any workarounds used? _____________________________________________
- Any unexpected behaviors observed? __________________________________
