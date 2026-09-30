# Enable Google Sign-In for Larnity-test App

### Active Supabase Project
- **Project Name:** Larnity-test
- **Project URL:** `https://lppxrbkgnajekulxpuce.supabase.co`
- **Project Ref:** `lppxrbkgnajekulxpuce`

---

## Step 1: Add Redirect URLs in Supabase Dashboard

1. Open your **Larnity-test** Supabase URL Configuration:
   👉 **[https://supabase.com/dashboard/project/lppxrbkgnajekulxpuce/auth/url-configuration](https://supabase.com/dashboard/project/lppxrbkgnajekulxpuce/auth/url-configuration)**

2. Scroll to the **Redirect URLs** section.

3. Click **`Add URL`** and add each of these URLs:
   ```text
   io.supabase.larnity://login-callback
   io.supabase.larnity://**
   com.example.larnity://login-callback
   com.example.larnity://**
   ```

4. Click **Save** at the bottom of the page.

---

## Step 2: Verify Google Provider Settings

1. Open the Auth Providers page:
   👉 **[https://supabase.com/dashboard/project/lppxrbkgnajekulxpuce/auth/providers](https://supabase.com/dashboard/project/lppxrbkgnajekulxpuce/auth/providers)**

2. Click **Google**:
   - Ensure the toggle **"Enable Sign in with Google"** is **ON**.
   - Note the **Authorized redirect URI**:
     ```text
     https://lppxrbkgnajekulxpuce.supabase.co/auth/v1/callback
     ```
   - In your Google Cloud Console (Credentials ➔ OAuth 2.0 Client ID), make sure that exact callback URL is listed under **Authorized redirect URIs**.

---

## Step 3: IMPORTANT — Rebuild the Mobile App

Because we updated native settings in `android/app/src/main/AndroidManifest.xml`:
- **Hot reload (`r`) or hot restart (`R`) will NOT apply Android manifest changes.**
- You **must stop the app** (`q` in terminal) and run:
  ```bash
  flutter run
  ```
  so Android installs the new `singleTask` launchMode and deep-link filters.

---

## What was fixed in the Codebase:
1. **`AndroidManifest.xml`**: Set `launchMode="singleTask"` and removed empty `taskAffinity` so Android correctly brings the app forward when returning from Google in the browser.
2. **`auth_datasource.dart`**: Added safe fallback to session user metadata so new Google users are never kicked out if the `profiles` table row creation encounters any lag or RLS restrictions.
3. **`auth_provider.dart`**: Prevented resetting `isAuthenticated` to false when a valid Supabase session is active.
4. **`auth_screen.dart`**: Added a loading indicator to the Google button and an automatic navigation listener to `/explore` on sign-in.
5. **`signup.dart` & `signin.dart`**: Replaced dead dummy callbacks (`onPressed: () {}`) with `authNotifier.signInWithGoogle()`.
