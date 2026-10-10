package com.bachelorbuddy.bachelor_buddy

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class TransactionNotificationService : NotificationListenerService() {
    companion object {
        private const val TAG = "TxnNotificationService"
        var notificationListener: ((packageName: String, title: String, text: String, timestamp: Long) -> Unit)? = null

        val SUPPORTED_PACKAGES = setOf(
            "com.google.android.apps.nbu.paisa.user", // Google Pay
            "com.phonepe.app",                        // PhonePe
            "net.one97.paytm",                        // Paytm
            "money.super.app",                        // super.money
            "com.whatsapp",                           // WhatsApp Pay
            // Bank apps
            "com.sbi.lotusintouch",
            "com.msf.kbank.mobile",
            "com.axis.mobile",
            "com.icicibank.imobile",
            "com.snapwork.hdfc"
        )
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return
        val packageName = sbn.packageName ?: return

        val isSupported = SUPPORTED_PACKAGES.contains(packageName) ||
                packageName.contains("pay", ignoreCase = true) ||
                packageName.contains("bank", ignoreCase = true) ||
                packageName.contains("upi", ignoreCase = true)

        if (!isSupported) return

        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""
        val fullContent = if (bigText.isNotEmpty()) "$title $bigText" else "$title $text"

        if (fullContent.isBlank()) return

        Log.d(TAG, "Notification received from $packageName: $fullContent")

        notificationListener?.invoke(packageName, title, fullContent, sbn.postTime)
    }
}
