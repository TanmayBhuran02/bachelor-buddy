package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
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
        val itemIds = intArrayOf(
            R.id.todo_widget_item1,
            R.id.todo_widget_item2,
            R.id.todo_widget_item3,
            R.id.todo_widget_item4,
            R.id.todo_widget_item5,
            R.id.todo_widget_item6
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_todo)

            val rawData = widgetData.getString("todo_widget", null)
            if (rawData != null) {
                try {
                    val json = JSONObject(rawData)
                    val tasks = json.optJSONArray("tasks") ?: JSONArray()
                    val count = tasks.length()

                    val countText = if (count == 1) "1 TASK" else "$count TASKS"
                    views.setTextViewText(R.id.todo_widget_count, countText)

                    if (count == 0) {
                        views.setViewVisibility(R.id.todo_widget_empty, View.VISIBLE)
                        itemIds.forEach { id ->
                            views.setViewVisibility(id, View.GONE)
                        }
                    } else {
                        views.setViewVisibility(R.id.todo_widget_empty, View.GONE)
                        for (i in itemIds.indices) {
                            val viewId = itemIds[i]
                            if (i < count) {
                                val title = tasks.getJSONObject(i).optString("title", "")
                                views.setTextViewText(viewId, "◻  $title")
                                views.setViewVisibility(viewId, View.VISIBLE)
                            } else {
                                views.setViewVisibility(viewId, View.GONE)
                            }
                        }
                    }
                } catch (e: Exception) {
                    views.setViewVisibility(R.id.todo_widget_empty, View.VISIBLE)
                }
            } else {
                views.setTextViewText(R.id.todo_widget_count, "0 TASKS")
                views.setViewVisibility(R.id.todo_widget_empty, View.VISIBLE)
                itemIds.forEach { id ->
                    views.setViewVisibility(id, View.GONE)
                }
            }

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_todo_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
