package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class QuickExpenseWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_quick_expense)

            // Quick Chai ₹20 intent
            val chaiUri = Uri.parse("bachelorbuddy://quick_expense?amount=2000&note=Chai&category=Food")
            val chaiIntent = HomeWidgetBackgroundIntent.getBroadcast(context, chaiUri)
            views.setOnClickPendingIntent(R.id.btn_quick_chai, chaiIntent)

            // Quick Lunch ₹100 intent
            val lunchUri = Uri.parse("bachelorbuddy://quick_expense?amount=10000&note=Lunch&category=Food")
            val lunchIntent = HomeWidgetBackgroundIntent.getBroadcast(context, lunchUri)
            views.setOnClickPendingIntent(R.id.btn_quick_lunch, lunchIntent)

            // Custom opens app
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.btn_quick_custom, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_quick_expense_container, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
