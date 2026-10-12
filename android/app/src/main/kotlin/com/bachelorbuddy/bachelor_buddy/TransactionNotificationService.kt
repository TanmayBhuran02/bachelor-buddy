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
            val enriched = packages.toMutableSet()
            if (enriched.contains("money.super.app")) {
                enriched.add("money.super.payments")
            }
            if (enriched.contains("money.super.payments")) {
                enriched.add("money.super.app")
            }
            activePackages = enriched
            isConfigLoaded = true
            try {
                context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                    .putBoolean(KEY_ENABLED, enabled)
                    .putStringSet(KEY_PACKAGES, enriched)
                    .apply()
                Log.d(TAG, "Config updated: enabled=$enabled, activeAppsCount=${enriched.size}")
            } catch (e: Exception) {
                Log.e(TAG, "Error updating config: $e")
            }
        }

        fun loadConfiguration(context: Context) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                isEnabled = prefs.getBoolean(KEY_ENABLED, false)
                val stored = prefs.getStringSet(KEY_PACKAGES, emptySet()) ?: emptySet()
                val enriched = stored.toMutableSet()
                if (enriched.contains("money.super.app")) {
                    enriched.add("money.super.payments")
                }
                if (enriched.contains("money.super.payments")) {
                    enriched.add("money.super.app")
                }
                activePackages = enriched
                isConfigLoaded = true
                Log.d(TAG, "Config loaded: enabled=$isEnabled, activeAppsCount=${activePackages.size}")
            } catch (e: Exception) {
                Log.e(TAG, "Error loading config: $e")
            }
        }

        fun isPackageWhitelisted(pkg: String): Boolean {
            if (activePackages.contains(pkg)) return true
            if ((pkg == "money.super.payments" || pkg == "money.super.app") &&
                (activePackages.contains("money.super.payments") || activePackages.contains("money.super.app"))
            ) {
                return true
            }
            return false
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

        // Strictly drop any package not present in user whitelist
        if (!isPackageWhitelisted(packageName)) return

        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()?.trim() ?: ""

        val parts = mutableListOf<String>()
        if (title.isNotEmpty()) parts.add(title)
        if (text.isNotEmpty()) parts.add(text)
        if (bigText.isNotEmpty() && bigText != text) parts.add(bigText)

        val textLines = extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)
        if (textLines != null) {
            for (line in textLines) {
                val lineStr = line?.toString()?.trim()
                if (!lineStr.isNullOrEmpty() && !parts.contains(lineStr)) {
                    parts.add(lineStr)
                }
            }
        }

        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()?.trim() ?: ""
        if (subText.isNotEmpty() && !parts.contains(subText)) parts.add(subText)

        val fullContent = parts.joinToString(" ").trim()
        if (fullContent.isBlank()) return

        // Privacy: Never log message content in system logcat
        Log.d(TAG, "Monitored notification received from $packageName")

        notificationListener?.invoke(packageName, title, fullContent, sbn.postTime)
    }
}
