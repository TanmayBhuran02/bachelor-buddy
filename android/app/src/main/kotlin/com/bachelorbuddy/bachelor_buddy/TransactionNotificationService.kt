package com.bachelorbuddy.bachelor_buddy

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class TransactionNotificationService : NotificationListenerService() {
    companion object {
        private const val TAG = "TxnNotificationService"
        const val PREFS_NAME = "bb_txn_prefs"
        const val KEY_ENABLED = "enabled"
        const val KEY_PACKAGES = "packages"

        var notificationListener: ((packageName: String, title: String, text: String, timestamp: Long) -> Unit)? = null
        var isConfigLoaded: Boolean = false
        var isEnabled: Boolean = false
        var activePackages: Set<String> = emptySet()

        fun updateConfiguration(context: Context, enabled: Boolean, packages: Set<String>) {
            isEnabled = enabled
            activePackages = packages
            isConfigLoaded = true
            try {
                context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                    .putBoolean(KEY_ENABLED, enabled)
                    .putStringSet(KEY_PACKAGES, packages)
                    .apply()
                Log.d(TAG, "Config updated: enabled=$enabled, activeAppsCount=${packages.size}")
            } catch (e: Exception) {
                Log.e(TAG, "Error updating config: $e")
            }
        }

        fun loadConfiguration(context: Context) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                isEnabled = prefs.getBoolean(KEY_ENABLED, false)
                activePackages = prefs.getStringSet(KEY_PACKAGES, emptySet()) ?: emptySet()
                isConfigLoaded = true
                Log.d(TAG, "Config loaded: enabled=$isEnabled, activeAppsCount=${activePackages.size}")
            } catch (e: Exception) {
                Log.e(TAG, "Error loading config: $e")
            }
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        loadConfiguration(this)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        if (!isConfigLoaded) {
            loadConfiguration(this)
        }

        // Drop immediately if listener is disabled
        if (!isEnabled) return

        val packageName = sbn.packageName ?: return

        // Strictly drop any package not present in user whitelist without reading content
        if (!activePackages.contains(packageName)) return

        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""
        val fullContent = if (bigText.isNotEmpty()) "$title $bigText" else "$title $text"

        if (fullContent.isBlank()) return

        // Privacy: Never log message content in system logcat
        Log.d(TAG, "Monitored notification received from $packageName")

        notificationListener?.invoke(packageName, title, fullContent, sbn.postTime)
    }
}
