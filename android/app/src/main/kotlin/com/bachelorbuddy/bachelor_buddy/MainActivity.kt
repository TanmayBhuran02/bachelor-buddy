package com.bachelorbuddy.bachelor_buddy

import android.content.Intent
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.bachelorbuddy/txn_listener"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationListenerGranted" -> {
                    val isGranted = NotificationManagerCompat.getEnabledListenerPackages(this)
                        .contains(packageName)
                    result.success(isGranted)
                }
                "openNotificationListenerSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "updateMonitoredPackages" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    TransactionNotificationService.updateConfiguration(
                        this,
                        enabled,
                        packages.toSet()
                    )
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        TransactionNotificationService.notificationListener = { pkg, title, text, timestamp ->
            runOnUiThread {
                channel.invokeMethod(
                    "onNotificationReceived", mapOf(
                        "packageName" to pkg,
                        "title" to title,
                        "text" to text,
                        "timestamp" to timestamp
                    )
                )
            }
        }
    }
}
