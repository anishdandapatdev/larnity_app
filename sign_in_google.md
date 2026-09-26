# Enable Google Sign-In for Larnity Mobile App

### Context
Google Sign-In is already fully configured and working on the **web app** (`dev.larnity.com`). 

To allow the **Flutter mobile app** to use the exact same Google authentication flow via deep linking, there is **only ONE step** required in the Supabase Dashboard. 

> ⚠️ **Note**: Do **NOT** change or recreate Google Cloud Console credentials or the existing Google provider settings in Supabase. Everything is already working for the web.

---

## The Only Step Required: Add Mobile Deep Link to Supabase

1. Open the **[Supabase Dashboard](https://supabase.com/dashboard/project/qtbaoqrrxupwkyofcjqp)**.
2. In the left sidebar, navigate to:
   **Authentication** ➔ **URL Configuration**.
3. Scroll down to the **Redirect URLs** table.
4. Click the green **`Add URL`** button and add:
   ```
   io.supabase.larnity://login-callback
   ```
5. *(Recommended fallback)* Click **`Add URL`** again and add:
   ```
   com.example.larnity://login-callback
   ```
6. Click **Save**.

---

### That's it!
Once this URL is saved in Supabase:
- When a mobile user taps **Sign in with Google**, Supabase opens Google login in the browser.
- After the user confirms their account, Supabase safely redirects back to `io.supabase.larnity://login-callback`.
- The Android / iOS app captures the deep link, logs the user in, and navigates them straight to the app home screen.
