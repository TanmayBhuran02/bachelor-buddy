package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class TiffinWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_tiffin)

            val rawData = widgetData.getString("tiffin_widget", null)
            if (rawData != null) {
                try {
                    val json = JSONObject(rawData)
                    val meal = json.optString("meal", "Lunch • Sai Tiffin")
                    val status = json.optString("status", "Pending Confirmation")
                    val planId = json.optString("planId", "")
                    val date = json.optString("date", "")

                    views.setTextViewText(R.id.tiffin_widget_meal, meal)
                    views.setTextViewText(R.id.tiffin_widget_status, "Status: $status")

                    // Mark received intent
                    val receivedUri = Uri.parse("bachelorbuddy://tiffin_mark_received?planId=$planId&date=$date")
                    val receivedIntent = HomeWidgetBackgroundIntent.getBroadcast(context, receivedUri)
                    views.setOnClickPendingIntent(R.id.btn_tiffin_received, receivedIntent)

                    // Skip intent
                    val skipUri = Uri.parse("bachelorbuddy://tiffin_skip?planId=$planId&date=$date")
                    val skipIntent = HomeWidgetBackgroundIntent.getBroadcast(context, skipUri)
                    views.setOnClickPendingIntent(R.id.btn_tiffin_skip, skipIntent)
                } catch (e: Exception) {
                    // Fallback to default
                }
            }

            // Click container opens app
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_tiffin_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
