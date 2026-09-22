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

            var glassMl = 200
            val rawData = widgetData.getString("water_widget", null)
            if (rawData != null) {
                try {
                    val json = JSONObject(rawData)
                    val intake = json.optInt("intakeMl", 0)
                    val goal = json.optInt("goalMl", 2500)
                    val glassesDrank = json.optInt("glassesDrank", 0)
                    val totalGlasses = json.optInt("totalGlasses", 12)
                    glassMl = json.optInt("glassMl", 200)

                    val percent = if (goal > 0) (intake * 100 / goal).coerceIn(0, 100) else 0

                    views.setTextViewText(R.id.water_widget_progress, "$intake / $goal ml")
                    views.setProgressBar(R.id.water_widget_progress_bar, 100, percent, false)
                    views.setTextViewText(R.id.water_widget_glasses, "$glassesDrank of $totalGlasses glasses drank ($percent%)")
                    views.setTextViewText(R.id.btn_water_add_text, "+$glassMl ml")
                } catch (e: Exception) {
                    // Fallback
                }
            } else {
                views.setTextViewText(R.id.water_widget_progress, "0 / 2,500 ml")
                views.setProgressBar(R.id.water_widget_progress_bar, 100, 0, false)
                views.setTextViewText(R.id.water_widget_glasses, "Tap + to log water")
                views.setTextViewText(R.id.btn_water_add_text, "+200 ml")
            }

            // Quick add intent
            val addUri = Uri.parse("bachelorbuddy://water_add_glass?amount=$glassMl")
            val addIntent = HomeWidgetBackgroundIntent.getBroadcast(context, addUri)
            views.setOnClickPendingIntent(R.id.btn_water_add, addIntent)

            // Click container opens app
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_water_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
