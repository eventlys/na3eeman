package com.na3eman.app

import android.app.Application
// import com.facebook.FacebookSdk
// import com.facebook.appevents.AppEventsLogger

/**
 * MainApplication
 * ================
 * Custom Application class that runs before any Activity.
 * This is the ONLY correct place to initialize the Facebook SDK —
 * the SDK must be initialized before any Activity (including MainActivity)
 * is created, otherwise flutter_facebook_auth throws:
 *
 *   "The SDK has not been initialized, make sure to call
 *    FacebookSdk.sdkInitialize() first."
 *
 * ─── Setup steps ───────────────────────────────────────────────────────────
 * 1. Add this file to the same package as MainActivity.kt (already done).
 * 2. In AndroidManifest.xml, change android:name="${applicationName}" to
 *    android:name=".MainApplication"  (see comment in AndroidManifest.xml).
 * 3. Add your Facebook App ID and Client Token to res/values/strings.xml.
 * 4. If you use Firebase, call FirebaseApp.initializeApp(this) here too.
 * ───────────────────────────────────────────────────────────────────────────
 */
class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        // ── Facebook SDK ───────────────────────────────────────────────────
        // sdkInitialize is called automatically when facebook_app_id is
        // present in AndroidManifest.xml meta-data (which we added), so the
        // explicit call below is a safety net for older SDK versions.
        // AppEventsLogger.activateApp() starts automatic event logging.
        // FacebookSdk.sdkInitialize(applicationContext)
        // AppEventsLogger.activateApp(this)
    }
}
