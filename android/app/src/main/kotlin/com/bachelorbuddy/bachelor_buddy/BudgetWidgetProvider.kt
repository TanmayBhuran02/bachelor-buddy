package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

class BudgetWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_budget)

            val rawData = widgetData.getString("budget_widget", null)
            if (rawData != null) {
                try {
                    val json = JSONObject(rawData)
                    val spentStr = json.optString("spentStr", "₹0")
                    val limitStr = json.optString("limitStr", "₹0")
                    val percentage = json.optInt("percentage", 0)
                    val safeToSpendStr = json.optString("safeToSpendStr", "₹0 / day")

                    views.setTextViewText(R.id.budget_widget_spent, "$spentStr / $limitStr")
                    views.setProgressBar(R.id.budget_widget_progress, 100, percentage.coerceIn(0, 100), false)
                    views.setTextViewText(R.id.budget_widget_safe_to_spend, "Safe to spend: $safeToSpendStr")
                } catch (e: Exception) {
                    // Fallback
                }
            }

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_budget_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
