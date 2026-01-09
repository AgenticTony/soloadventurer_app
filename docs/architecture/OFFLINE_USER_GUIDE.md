# Offline Mode Guide

## Welcome to Offline-First Travel Planning

SoloAdventurer is designed to work perfectly even when you don't have an internet connection. Whether you're on a flight, in a remote area, or just experiencing poor connectivity, you can continue planning your adventures without interruption.

This guide explains how offline mode works, what you can do without internet, and how your data stays synchronized across all your devices.

---

## Table of Contents

- [How Offline Mode Works](#how-offline-mode-works)
- [What Data is Available Offline](#what-data-is-available-offline)
- [Understanding Sync Status](#understanding-sync-status)
- [How Automatic Sync Works](#how-automatic-sync-works)
- [Offline Mode Features](#offline-mode-features)
- [Troubleshooting Sync Issues](#troubleshooting-sync-issues)
- [Frequently Asked Questions](#frequently-asked-questions)

---

## How Offline Mode Works

### The Offline-First Approach

SoloAdventurer uses an **offline-first architecture**, which means:

- **All data is stored locally on your device** - Your trips, journals, and preferences are saved in a local database
- **You don't need internet to use the app** - View, create, edit, and delete your travel plans anytime
- **Changes sync automatically** - When you reconnect to the internet, your changes sync to the cloud
- **Work across multiple devices** - Access your updated plans on your phone, tablet, or computer

### What Happens When You Go Offline

1. **The app detects you're offline** automatically
2. **An offline banner appears** at the top of the screen to inform you
3. **All your data remains accessible** from your local storage
4. **You can continue using the app normally** - create trips, write journals, update plans
5. **Changes are saved locally** and queued for sync when you're back online

### What Happens When You Go Back Online

1. **The app detects internet connection** automatically
2. **Offline banner disappears** and sync status shows
3. **Your changes sync in the background** - you don't need to do anything
4. **Updates from other devices download** automatically
5. **Conflicts are resolved** - if you edited the same item on multiple devices, the app handles it

---

## What Data is Available Offline

### ✅ Fully Available Offline

You can access and modify all this data without internet:

#### **Trips & Travel Plans**
- View all your planned trips
- Create new trips
- Edit trip details (dates, destinations, notes)
- Delete trips you no longer need

#### **Itinerary Items**
- View your complete itinerary for each trip
- Add activities, transportation, accommodations
- Update times and locations
- Reorder items in your schedule

#### **Travel Journals**
- Read all your journal entries
- Write new journal entries
- Edit existing entries
- Add photos and notes

#### **User Profile & Preferences**
- View your profile information
- Update your travel preferences
- Change app settings
- Manage notification preferences

### 📡 Data That Requires Internet

Some features need an internet connection:

- **Account creation and sign-in** (initial setup only)
- **Downloading maps** (cached maps work offline)
- **Real-time data** (weather, live updates)
- **Photo uploads** (photos are queued and uploaded when online)
- **Sharing trips** with other travelers

### 💡 Tip

The app will cache reference data like:
- Country information
- Currency data
- Common travel locations

This makes most features work smoothly even without internet!

---

## Understanding Sync Status

The app shows your sync status through clear visual indicators:

### Status Indicators

#### 🟢 **All Synced**
- **Icon**: Green checkmark or cloud with checkmark
- **Meaning**: All your data is up-to-date on the server
- **Action needed**: None!

#### 🟡 **Syncing...**
- **Icon**: Yellow/orange spinning arrows or clock icon
- **Meaning**: Your changes are being synced to the cloud
- **Action needed**: None - just wait a moment

#### 🟠 **Pending Sync**
- **Icon**: Orange cloud with sync icon
- **Meaning**: You have unsaved changes that will sync when you're online
- **Action needed**: Connect to internet to sync

#### 🔴 **Sync Error**
- **Icon**: Red exclamation mark or error icon
- **Meaning**: There was a problem syncing your data
- **Action needed**: See [Troubleshooting](#troubleshooting-sync-issues)

### Where to Find Sync Status

1. **Status Banner** - Top of the app screen
2. **Individual Items** - Each trip, journal, and itinerary item shows its sync status
3. **Settings Screen** - Detailed sync status and history
4. **Notification Center** - Sync notifications and errors

---

## How Automatic Sync Works

### The Sync Process

Syncing happens automatically in these situations:

#### 1. **When You Connect to Internet**
- The app detects network connectivity
- Automatically starts syncing queued changes
- Downloads updates from other devices
- All happens in the background - you can keep using the app

#### 2. **When You Open the App**
- If the app was closed while you had unsynced changes
- Syncing resumes automatically when you reopen the app
- You'll see a notification showing sync progress

#### 3. **Periodic Background Sync**
- The app periodically checks for updates
- Ensures your data is always current
- Minimizes battery and data usage

#### 4. **After Significant Changes**
- Creating, editing, or deleting important items
- Syncing prioritizes recent, important changes
- Ensures your latest data is backed up quickly

### What Gets Synced

Every time you sync, the app:

✅ **Uploads your local changes**:
- New trips you created
- Edits to existing trips
- Journal entries you wrote
- Changes to your profile
- Deleted items

✅ **Downloads updates from the cloud**:
- Changes made on other devices
- Shared trip updates from travel companions
- Account updates

### Conflict Resolution

Sometimes you might edit the same item on multiple devices while offline. Don't worry - the app handles this!

**Default Rule**: Most recent edit wins (based on time)

**Smart Merging**:
- If you edited different fields (e.g., title on phone, description on tablet), both changes are kept
- If you edited the same field, the most recent edit is used
- You'll see a notification if conflicts were resolved

**Special Cases**:
- **Deleted vs. Edited**: If you deleted an item on one device but edited it on another, the edit wins (your data is preserved)
- **Duplicates**: If you created similar items offline, the app might suggest merging them

---

## Offline Mode Features

### Create & Edit Trips Offline

**What You Can Do:**
- Plan a new trip from scratch
- Set dates, destinations, and budgets
- Add notes and descriptions
- Invite travel companions (invitations sent when online)

**Example Scenario:**
> You're on a flight to Japan and decide to plan a side trip to Kyoto. You create the entire trip offline - add dates, itinerary items, notes, and even write journal entries about your excitement. When you land and connect to WiFi, everything syncs to your account automatically. Your travel companion sees the new trip on their device!

### Write Travel Journals Offline

**What You Can Do:**
- Write detailed journal entries
- Add photos (queued for upload)
- Record memories and experiences
- Organize entries by trip or date

**Example Scenario:**
> You're hiking in Patagonia with no cell service. You write a beautiful journal entry about the stunning views and add photos from your phone. The app saves everything locally. When you return to your lodge with WiFi that evening, your journal entry syncs to the cloud, and your family can read about your adventure back home.

### Update Itineraries Offline

**What You Can Do:**
- Add new activities and events
- Update times and locations
- Reorder items in your schedule
- Add notes and reminders

**Example Scenario:**
> You're on a road trip and decide to change your plans. Instead of visiting the museum at 2 PM, you want to go to the beach. You update your itinerary offline - remove the museum, add the beach, adjust times. The changes save instantly. When you stop for coffee and connect to WiFi, your updated itinerary syncs, and anyone viewing your trip sees the new plan.

### Access All Your Data Offline

**What You Can Do:**
- View trip details anytime
- Read past journal entries
- Check your itinerary
- Look up travel notes

**Example Scenario:**
> You're in a remote village in Peru with no internet. You need to check your hotel booking details and the address of a restaurant you planned to visit. Even though you're completely offline, you open the app and find all the information instantly - it's all stored on your phone!

---

## Troubleshooting Sync Issues

### Common Problems & Solutions

#### ❌ Problem: "Sync Failed" Error

**Possible Causes:**
- Weak or unstable internet connection
- Server is temporarily unavailable
- Account authentication issue

**Solutions:**
1. **Check your internet connection**
   - Try opening a web browser to verify you're online
   - Switch between WiFi and mobile data

2. **Wait a moment and try again**
   - Sometimes the server is busy (wait 1-2 minutes)
   - Pull down to refresh on any screen

3. **Force sync manually**
   - Go to **Settings > Sync**
   - Tap **"Sync Now"**

4. **Check for app updates**
   - Ensure you have the latest version of the app
   - Updates often fix sync issues

#### ❌ Problem: Changes Not Appearing on Other Devices

**Possible Causes:**
- Sync hasn't completed yet
- Other device is offline
- Changes haven't been uploaded yet

**Solutions:**
1. **Check sync status on this device**
   - Look for the green checkmark (synced) status
   - If you see orange/yellow, wait for sync to complete

2. **Check the other device**
   - Is it connected to internet?
   - Open the app on that device to trigger sync

3. **Wait a few minutes**
   - Syncing can take up to a few minutes depending on:
     - How much data changed
     - Internet speed
     - Server load

4. **Refresh the app**
   - Close and reopen the app on both devices
   - Pull down to refresh on any screen

#### ❌ Problem: "Data Conflict" Message

**What This Means:**
- You edited the same item on multiple devices while offline
- The app resolved which version to keep

**What Happens:**
- The app keeps the most recent edit (usually)
- You'll see a notification explaining what happened
- Your data is NOT lost - it's all in your sync history

**What To Do:**
1. Review the item to make sure it looks correct
2. If needed, you can manually edit it again
3. Check **Settings > Sync History** to see what was resolved

#### ❌ Problem: Sync Stuck / Not Progressing

**Possible Causes:**
- Large amount of data to sync
- Slow internet connection
- App needs restart

**Solutions:**
1. **Wait longer** (if you have lots of changes)
   - Syncing hundreds of items can take 5-10 minutes
   - Check if the progress indicator is moving

2. **Restart the app**
   - Close the app completely
   - Reopen it
   - Syncing should resume

3. **Check your data connection**
   - Try faster WiFi if available
   - Move to an area with better signal

4. **Free up device storage**
   - Syncing requires temporary storage space
   - Delete unnecessary photos or apps if your phone is full

#### ❌ Problem: Items Disappeared After Sync

**Possible Causes:**
- Item was deleted on another device
- Item was deleted due to conflict resolution
- Sync error

**Solutions:**
1. **Check other devices**
   - Did you delete the item on another device?
   - Check if it exists there

2. **Check sync history**
   - Go to **Settings > Sync History**
   - See if the item was marked as deleted

3. **Restore from backup** (if available)
   - Go to **Settings > Backup & Restore**
   - Check if there's a backup before the item disappeared

4. **Contact support** if you believe data was lost in error
   - We can often recover data from server logs

### Getting Help

If you're still having trouble:

1. **Check the FAQ** below for common questions
2. **Visit our Help Center** at [help.soloadventurer.com](https://help.soloadventurer.com)
3. **Contact Support**:
   - Email: support@soloadventurer.com
   - In-app: **Settings > Help & Support > Contact Us**
   - Include details about what you were doing and what error you see

---

## Frequently Asked Questions

### General Questions

#### Q: Do I need internet to use SoloAdventurer?

**A:** No! The app is designed to work perfectly offline. You can view, create, edit, and delete all your travel plans without an internet connection. You only need internet for initial account setup and syncing data across devices.

#### Q: What happens if I create a trip offline?

**A:** The trip is saved immediately to your device. When you connect to the internet, it automatically syncs to the cloud. You'll see a sync indicator showing it's queued for upload, then syncing, then complete.

#### Q: Will I lose my data if I'm offline for a long time?

**A:** No! All your data is stored locally on your device. You could be offline for weeks or months, and your data will be safe on your phone. When you finally connect to the internet, everything will sync normally.

#### Q: How much storage does offline mode use?

**A:** The app is quite efficient. Most users use less than 100 MB for storing dozens of trips with thousands of journal entries. Photos take more space - you can choose to store photos offline or only sync them when online.

### Sync & Data

#### Q: How often does my data sync?

**A:** Syncing happens automatically:
- Immediately when you connect to internet
- Every few minutes while you're online
- When you open the app
- After making significant changes

You don't need to manually sync - it just works!

#### Q: Can I sync manually?

**A:** Yes! Go to **Settings > Sync** and tap **"Sync Now"**. This is useful if you want to ensure everything is up-to-date before going offline.

#### Q: What if I edit the same trip on my phone and laptop while both are offline?

**A:** When both devices come back online, the app will sync and resolve conflicts. Usually, the most recent edit wins. If you edited different parts (like title on phone, description on laptop), both changes are merged together. You'll see a notification if any conflicts were resolved.

#### Q: Can I see what's been synced?

**A:** Yes! Go to **Settings > Sync History** to see:
- Recent sync activity
- Items that were uploaded/downloaded
- Any conflicts that were resolved
- Sync errors and how they were fixed

#### Q: Does syncing use a lot of data?

**A:** Not usually. Text data (trips, journals, itineraries) is tiny - syncing hundreds of items uses less data than sending a few photos. Photos use more data, but you can choose to only sync photos on WiFi in settings.

### Privacy & Security

#### Q: Is my data safe when stored offline?

**A:** Yes! All data on your device is encrypted and secure. The app uses the same security standards as online banking. Even if someone steals your phone, they can't access your travel data without your password/biometrics.

#### Q: What happens if I lose my phone?

**A:** All your data is also stored in the cloud. When you get a new phone and sign in, everything syncs back automatically. You won't lose any trips, journals, or memories.

#### Q: Can anyone see my offline data?

**A:** No. Your offline data is encrypted and protected by your device's security (passcode, fingerprint, Face ID). Additionally, the app requires authentication to open.

### Travel Scenarios

#### Q: Can I use SoloAdventurer on a flight?

**A:** Absolutely! The app works perfectly in airplane mode. You can plan trips, write journals, update itineraries - everything works. When you land and connect to WiFi, all your changes sync automatically.

#### Q: What if I'm traveling in a remote area with no signal?

**A:** No problem! The app works entirely offline. You can access all your trips, create new ones, write journals, and update plans. When you eventually find WiFi or cell service, everything syncs.

#### Q: Can I share trips while offline?

**A:** You can set up trip sharing while offline (add email addresses, set permissions), but the actual invitations and shared access won't happen until you're online. The other person will see the trip when you both have internet.

#### Q: Will my photos sync offline?

**A:** Photos you add while offline are saved to your device. They'll sync to the cloud when you're online. You can choose in settings to only sync photos on WiFi to save mobile data.

### Performance

#### Q: Does offline mode slow down the app?

**A:** No! In fact, the app is faster offline because it reads from local storage instead of downloading from the internet. Everything is instant.

#### Q: How much battery does sync use?

**A:** Very little. Syncing is efficient and runs in the background. The app is designed to minimize battery usage - it only syncs when there are actual changes to sync.

#### Q: Does having lots of offline data make the app slow?

**A:** No. The app uses an optimized database that can handle thousands of trips and journal entries without slowing down. You can have years of travel data and the app will still be fast.

### Tips & Tricks

#### Q: How do I prepare for a long trip offline?

**A:** Before you leave:
1. Sync everything (connect to WiFi)
2. Verify sync is complete (green checkmarks)
3. Download any maps you might need
4. Optionally, download reference info for destinations

Now you're ready to travel completely offline!

#### Q: Can I use offline mode to save data when roaming?

**A:** Yes! The app is perfect for avoiding roaming charges. Put your phone in airplane mode and turn on WiFi only. You can use the app completely offline at your destination. When you find free WiFi, everything syncs at no extra cost.

#### Q: What's the best way to manage photos offline?

**A:** Tips for photo management:
- Enable **"Sync photos on WiFi only"** in settings
- Consider **"Low-res photos offline"** to save space
- The app automatically compresses photos for efficient sync
- Full-quality photos are always saved in the cloud

---

## Quick Reference: Sync Status Icons

| Icon | Status | What It Means |
|------|--------|---------------|
| ✅ 🟢 | All Synced | Everything is up-to-date |
| ⏳ 🟡 | Syncing | Changes are uploading/downloading |
| ☁️ 🟠 | Pending Sync | Changes will sync when you're online |
| ❌ 🔴 | Sync Error | There was a problem - see troubleshooting |
| ✈️ ️📴 | Offline | You're offline - working locally |

---

## Need More Help?

We're here to help you make the most of SoloAdventurer's offline capabilities!

**In-App Help:**
- **Settings > Help & Support** - FAQs, tutorials, and tips
- **Settings > Contact Us** - Email our support team

**Online Resources:**
- **Help Center:** [help.soloadventurer.com](https://help.soloadventurer.com)
- **Video Tutorials:** [youtube.com/soloadventurer](https://youtube.com/soloadventurer)
- **Community Forum:** [community.soloadventurer.com](https://community.soloadventurer.com)

**Contact Support:**
- 📧 Email: support@soloadventurer.com
- 💬 In-App Chat: **Settings > Help > Chat with Us**
- 🕐 Response Time: Usually within 24 hours

---

## Enjoy Your Offline Adventures!

SoloAdventurer's offline-first design means you can focus on what matters most - your adventures - without worrying about internet connectivity. Whether you're flying to Tokyo, hiking in Patagonia, or road-tripping across the country, your travel plans are always with you.

**Happy travels! 🌍✈️**

---

*Last Updated: January 2026*
*App Version: 1.0.0+
