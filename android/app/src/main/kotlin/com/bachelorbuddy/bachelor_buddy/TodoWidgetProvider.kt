package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

class TodoWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_todo)

            val rawData = widgetData.getString("todo_widget", null)
            if (rawData != null) {
                try {
                    val json = JSONObject(rawData)
                    val tasks = json.optJSONArray("tasks") ?: JSONArray()
                    val count = tasks.length()

                    views.setTextViewText(R.id.todo_widget_count, "$count tasks")

                    val t1 = if (count > 0) "• " + tasks.getJSONObject(0).optString("title") else "No pending tasks"
                    val t2 = if (count > 1) "• " + tasks.getJSONObject(1).optString("title") else ""
                    val t3 = if (count > 2) "• " + tasks.getJSONObject(2).optString("title") else ""

                    views.setTextViewText(R.id.todo_widget_item1, t1)
                    views.setTextViewText(R.id.todo_widget_item2, t2)
                    views.setTextViewText(R.id.todo_widget_item3, t3)
                } catch (e: Exception) {
                    // Fallback
                }
            } else {
                views.setTextViewText(R.id.todo_widget_count, "0 tasks")
                views.setTextViewText(R.id.todo_widget_item1, "No pending tasks")
                views.setTextViewText(R.id.todo_widget_item2, "")
                views.setTextViewText(R.id.todo_widget_item3, "")
            }

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_todo_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
