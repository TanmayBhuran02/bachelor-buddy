package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
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
                    val meal = json.optString("meal", "No active plan")
                    val status = json.optString("status", "pending")
                    val planId = json.optString("planId", "")
                    val date = json.optString("date", "")
                    val price = json.optString("price", "")

                    views.setTextViewText(R.id.tiffin_widget_meal, meal)
                    if (price.isNotEmpty()) {
                        views.setTextViewText(R.id.tiffin_widget_subtitle, "Price: $price • Daily delivery")
                    }

                    when (status.lowercase()) {
                        "received" -> {
                            views.setTextViewText(R.id.tiffin_widget_status, "Received")
                            views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#00BFA6"))
                            views.setViewVisibility(R.id.tiffin_actions_layout, View.GONE)
                        }
                        "skipped" -> {
                            views.setTextViewText(R.id.tiffin_widget_status, "Skipped")
                            views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#FF6B6B"))
                            views.setViewVisibility(R.id.tiffin_actions_layout, View.GONE)
                        }
                        else -> {
                            views.setTextViewText(R.id.tiffin_widget_status, "Pending")
                            views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#FFB74D"))
                            views.setViewVisibility(R.id.tiffin_actions_layout, View.VISIBLE)
                        }
                    }

                    if (planId.isNotEmpty() && date.isNotEmpty()) {
                        // Mark received intent
                        val receivedUri = Uri.parse("bachelorbuddy://tiffin_mark_received?planId=$planId&date=$date")
                        val receivedIntent = HomeWidgetBackgroundIntent.getBroadcast(context, receivedUri)
                        views.setOnClickPendingIntent(R.id.btn_tiffin_received, receivedIntent)

                        // Skip intent
                        val skipUri = Uri.parse("bachelorbuddy://tiffin_skip?planId=$planId&date=$date")
                        val skipIntent = HomeWidgetBackgroundIntent.getBroadcast(context, skipUri)
                        views.setOnClickPendingIntent(R.id.btn_tiffin_skip, skipIntent)
                    }
                } catch (e: Exception) {
                    // Fallback
                }
            } else {
                views.setTextViewText(R.id.tiffin_widget_meal, "No Active Plan")
                views.setTextViewText(R.id.tiffin_widget_subtitle, "Tap to configure daily tiffin")
                views.setTextViewText(R.id.tiffin_widget_status, "Inactive")
                views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#9E9EB0"))
                views.setViewVisibility(R.id.tiffin_actions_layout, View.GONE)
            }

            // Click container opens app
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_tiffin_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
