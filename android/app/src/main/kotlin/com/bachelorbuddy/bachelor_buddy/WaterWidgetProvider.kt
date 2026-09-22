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

class WaterWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_water)

            val rawData = widgetData.getString("water_widget", null)
            if (rawData != null) {
                try {
                    val json = JSONObject(rawData)
                    val intake = json.optInt("intakeMl", 1600)
                    val goal = json.optInt("goalMl", 2500)
                    val glassesDrank = json.optInt("glassesDrank", 8)
                    val totalGlasses = json.optInt("totalGlasses", 12)
                    val glassMl = json.optInt("glassMl", 200)

                    views.setTextViewText(R.id.water_widget_progress, "$intake / $goal ml")
                    views.setTextViewText(R.id.water_widget_glasses, "$glassesDrank of $totalGlasses glasses drank")
                    views.setTextViewText(R.id.btn_water_add, "+1 Glass (${glassMl}ml)")

                    val addUri = Uri.parse("bachelorbuddy://water_add_glass?amount=$glassMl")
                    val addIntent = HomeWidgetBackgroundIntent.getBroadcast(context, addUri)
                    views.setOnClickPendingIntent(R.id.btn_water_add, addIntent)
                } catch (e: Exception) {
                    // Fallback
                }
            }

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_water_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
