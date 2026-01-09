# Supabase Database Setup Guide

This guide will walk you through setting up your Supabase database for SoloAdventurer.

## Step 1: Access Your Supabase Dashboard

1. Go to https://supabase.com/dashboard
2. Select your project: `zyiuajhltmxbsrqplqlx`
3. Navigate to the **SQL Editor** from the left sidebar

## Step 2: Run the Database Schema

1. In the SQL Editor, click **"New Query"**
2. Open the file: `docs/supabase/database_schema.sql`
3. Copy the entire contents of the file
4. Paste into the SQL Editor
5. Click **"Run"** or press `Cmd/Ctrl + Enter`

## Step 3: Verify Tables Were Created

In the SQL Editor, run this query to verify:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

You should see these tables:
- `profiles` (user profile information)
- `trips` (travel trips)
- `itinerary_items` (trip itinerary items)
- `journals` (travel journals)
- `trusted_contacts` (emergency contacts)
- `check_ins` (safety check-ins)
- `location_updates` (location tracking)

## Step 4: Configure Email Confirmation (Optional but Recommended)

1. In Supabase Dashboard, go to **Authentication** → **Providers**
2. Click on **Email**
3. Enable **"Confirm email"**
4. Customize the email templates if needed
5. Save changes

## Step 5: Create Storage Buckets (For Images/Attachments)

1. Go to **Storage** from the left sidebar
2. Click **"Create a new bucket"**
3. Create these buckets:

### Bucket: `avatars`
- Purpose: User profile pictures
- Public: Yes (for profile images)
- File size limit: 2MB
- Allowed MIME types: `image/png`, `image/jpeg`, `image/jpg`

### Bucket: `journal-photos`
- Purpose: Journal entry photos
- Public: Yes (authenticated users only)
- File size limit: 5MB
- Allowed MIME types: `image/png`, `image/jpeg`, `image/jpg`

### Bucket: `trip-photos`
- Purpose: Trip photos
- Public: Yes (authenticated users only)
- File size limit: 5MB
- Allowed MIME types: `image/png`, `image/jpeg`, `image/jpg`

## Step 6: Set Up Storage Policies

For each bucket, run these policies in the SQL Editor:

### Avatars Bucket Policies
```sql
-- Allow authenticated users to upload avatars
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow public access to view avatars
CREATE POLICY "Public can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Allow users to delete their own avatars
CREATE POLICY "Users can delete own avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### Journal Photos Bucket Policies
```sql
CREATE POLICY "Authenticated users can upload journal photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'journal-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Authenticated users can view journal photos"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'journal-photos');

CREATE POLICY "Users can delete own journal photos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'journal-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### Trip Photos Bucket Policies
```sql
CREATE POLICY "Authenticated users can upload trip photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'trip-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Authenticated users can view trip photos"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'trip-photos');

CREATE POLICY "Users can delete own trip photos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'trip-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
```

## Step 7: Test the Setup

1. Run your Flutter app: `flutter run`
2. Register a new user
3. Check that a profile was automatically created in the `profiles` table
4. Try creating a trip
5. Verify data appears in the `trips` table

## Troubleshooting

### Issue: RLS Policies Blocking Access

If you get permission errors, check the RLS policies:

```sql
-- View RLS policies for a table
SELECT * FROM pg_policies WHERE tablename = 'profiles';
```

### Issue: Profile Not Created on Signup

Check the trigger is working:

```sql
-- View trigger
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
```

### Issue: Email Verification Not Working

1. Check Email Provider settings in Authentication → Providers → Email
2. Verify email templates are configured
3. Check the "Site URL" in your project settings

## Helpful SQL Queries

### View All Users with Profiles
```sql
SELECT
    p.id,
    p.email,
    p.username,
    p.created_at,
    COUNT(DISTINCT t.id) as trip_count
FROM profiles p
LEFT JOIN trips t ON p.id = t.user_id
GROUP BY p.id
ORDER BY p.created_at DESC;
```

### View Active Safety Alerts (Missed Check-ins)
```sql
SELECT
    ci.id,
    ci.user_id,
    p.username,
    p.email,
    ci.scheduled_for,
    ci.title,
    ci.status
FROM check_ins ci
JOIN profiles p ON ci.user_id = p.id
WHERE ci.status = 'missed'
    AND ci.scheduled_for > NOW() - INTERVAL '7 days'
ORDER BY ci.scheduled_for DESC;
```

### Clean Up Old Location Updates (Keep Last 30 Days)
```sql
DELETE FROM location_updates
WHERE recorded_at < NOW() - INTERVAL '30 days';
```

## Next Steps

After the database is set up:

1. ✅ Database schema created
2. ✅ Storage buckets configured
3. ⏳ Test user registration and login
4. ⏳ Test creating trips and journals
5. ⏳ Test safety features (check-ins, location sharing)

For questions or issues, check the Supabase documentation:
- https://supabase.com/docs
- https://supabase.com/docs/guides/auth
- https://supabase.com/docs/guides/storage
