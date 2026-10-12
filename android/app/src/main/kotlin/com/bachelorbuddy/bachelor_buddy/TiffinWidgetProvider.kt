package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

class TiffinWidgetProvider : HomeWidgetProvider() {

    companion object {
        private var cachedRawData: String? = null
    }

    private fun getSharedPreferencesData(context: Context): SharedPreferences {
        return try {
            HomeWidgetPlugin.getData(context)
        } catch (e: Throwable) {
            context.getSharedPreferences("com.bachelorbuddy.widgets", Context.MODE_PRIVATE)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            updateWidget(context, appWidgetManager, widgetId, widgetData, options)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val widgetData = getSharedPreferencesData(context)
        updateWidget(context, appWidgetManager, appWidgetId, widgetData, newOptions)
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences,
        options: Bundle?
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_tiffin)

        // Read size from options to determine how many plans fit
        val minH = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0) ?: 0
        val maxH = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0) ?: 0
        val effectiveHeight = if (minH > 0) minH else maxH

        // Resolve data from passed prefs, app group prefs, and memory cache
        var rawData = widgetData.getString("tiffin_widget", null)
        if (rawData.isNullOrEmpty()) {
            val groupPrefs = context.getSharedPreferences("com.bachelorbuddy.widgets", Context.MODE_PRIVATE)
            rawData = groupPrefs.getString("tiffin_widget", null)
        }
        if (rawData.isNullOrEmpty()) {
            rawData = cachedRawData
        }
        if (!rawData.isNullOrEmpty()) {
            cachedRawData = rawData
        }

        val planList = mutableListOf<JSONObject>()

        if (rawData != null) {
            try {
                val json = JSONObject(rawData)
                val plansArray = json.optJSONArray("plans")
                if (plansArray != null && plansArray.length() > 0) {
                    for (i in 0 until plansArray.length()) {
                        planList.add(plansArray.getJSONObject(i))
                    }
                } else if (json.optString("meal", "").isNotEmpty() &&
                    json.optString("meal") != "No Active Plan" &&
                    json.optString("status") != "inactive"
                ) {
                    // Fallback to legacy single plan format
                    val single = JSONObject().apply {
                        put("meal", json.optString("meal"))
                        put("status", json.optString("status"))
                        put("price", json.optString("price"))
                        put("planId", json.optString("planId"))
                        put("date", json.optString("date"))
                    }
                    planList.add(single)
                }
            } catch (e: Exception) {
                // Parse error fallback
            }
        }

        val maxPlans = when {
            effectiveHeight in 1..95 -> 1
            effectiveHeight in 96..165 -> 2
            effectiveHeight > 165 -> 3
            else -> if (planList.size <= 1) 1 else 2
        }

        if (planList.isEmpty()) {
            // Empty state
            views.setViewVisibility(R.id.tiffin_empty_layout, View.VISIBLE)
            views.setViewVisibility(R.id.tiffin_plan_1, View.GONE)
            views.setViewVisibility(R.id.tiffin_plan_2, View.GONE)
            views.setViewVisibility(R.id.tiffin_plan_3, View.GONE)
            views.setViewVisibility(R.id.tiffin_more_hint, View.GONE)

            views.setTextViewText(R.id.tiffin_empty_title, "No Active Meal Plans")
            views.setTextColor(R.id.tiffin_empty_title, Color.parseColor("#F1F5F9"))
            views.setTextViewText(R.id.tiffin_empty_subtitle, "Tap to configure daily tiffin")
            views.setTextViewText(R.id.tiffin_widget_count, "0 PLANS")
            views.setTextViewText(R.id.tiffin_widget_status, "INACTIVE")
            views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#9E9EB0"))
        } else {
            views.setViewVisibility(R.id.tiffin_empty_layout, View.GONE)

            val countText = if (planList.size == 1) "1 PLAN" else "${planList.size} PLANS"
            views.setTextViewText(R.id.tiffin_widget_count, countText)

            // Header status calculation
            val allReceived = planList.all { it.optString("status", "").equals("received", ignoreCase = true) }
            val allSkipped = planList.all { it.optString("status", "").equals("skipped", ignoreCase = true) }
            val anyPending = planList.any { !it.optString("status", "").equals("received", ignoreCase = true) && !it.optString("status", "").equals("skipped", ignoreCase = true) }

            when {
                allReceived -> {
                    views.setTextViewText(R.id.tiffin_widget_status, "ALL RECEIVED")
                    views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#34D399"))
                }
                allSkipped -> {
                    views.setTextViewText(R.id.tiffin_widget_status, "SKIPPED")
                    views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#F87171"))
                }
                anyPending -> {
                    views.setTextViewText(R.id.tiffin_widget_status, "PENDING")
                    views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#FBBF24"))
                }
                else -> {
                    views.setTextViewText(R.id.tiffin_widget_status, "ACTIVE")
                    views.setTextColor(R.id.tiffin_widget_status, Color.parseColor("#34D399"))
                }
            }

            // In compact 1-plan view, prioritize the pending meal so user can interact immediately
            val orderedList = if (maxPlans == 1 && planList.size > 1) {
                planList.sortedBy { p ->
                    val s = p.optString("status", "").lowercase()
                    if (s != "received" && s != "skipped") 0 else 1
                }
            } else {
                planList
            }

            val numToShow = orderedList.size.coerceAtMost(maxPlans)

            // Slot 1
            if (numToShow >= 1) {
                bindPlanSlot(
                    context = context,
                    views = views,
                    plan = orderedList[0],
                    containerId = R.id.tiffin_plan_1,
                    mealId = R.id.tiffin_widget_meal,
                    subtitleId = R.id.tiffin_widget_subtitle,
                    statusId = R.id.tiffin_status_1,
                    actionsId = R.id.tiffin_actions_layout,
                    skipBtnId = R.id.btn_tiffin_skip,
                    receivedBtnId = R.id.btn_tiffin_received
                )
            } else {
                views.setViewVisibility(R.id.tiffin_plan_1, View.GONE)
            }

            // Slot 2
            if (numToShow >= 2) {
                bindPlanSlot(
                    context = context,
                    views = views,
                    plan = orderedList[1],
                    containerId = R.id.tiffin_plan_2,
                    mealId = R.id.tiffin_meal_2,
                    subtitleId = R.id.tiffin_subtitle_2,
                    statusId = R.id.tiffin_status_2,
                    actionsId = R.id.tiffin_actions_2,
                    skipBtnId = R.id.btn_tiffin_skip_2,
                    receivedBtnId = R.id.btn_tiffin_received_2
                )
            } else {
                views.setViewVisibility(R.id.tiffin_plan_2, View.GONE)
            }

            // Slot 3
            if (numToShow >= 3) {
                bindPlanSlot(
                    context = context,
                    views = views,
                    plan = orderedList[2],
                    containerId = R.id.tiffin_plan_3,
                    mealId = R.id.tiffin_meal_3,
                    subtitleId = R.id.tiffin_subtitle_3,
                    statusId = R.id.tiffin_status_3,
                    actionsId = R.id.tiffin_actions_3,
                    skipBtnId = R.id.btn_tiffin_skip_3,
                    receivedBtnId = R.id.btn_tiffin_received_3
                )
            } else {
                views.setViewVisibility(R.id.tiffin_plan_3, View.GONE)
            }

            // Hint footer if more plans remain
            val remaining = orderedList.size - numToShow
            if (remaining > 0) {
                views.setViewVisibility(R.id.tiffin_more_hint, View.VISIBLE)
                val hintText = if (remaining == 1) "+1 more plan (resize ↕)" else "+$remaining more plans (resize ↕)"
                views.setTextViewText(R.id.tiffin_more_hint, hintText)
            } else {
                views.setViewVisibility(R.id.tiffin_more_hint, View.GONE)
            }
        }

        // Tap background opens app
        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.widget_tiffin_container, pendingIntent)

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun bindPlanSlot(
        context: Context,
        views: RemoteViews,
        plan: JSONObject,
        containerId: Int,
        mealId: Int,
        subtitleId: Int,
        statusId: Int,
        actionsId: Int,
        skipBtnId: Int,
        receivedBtnId: Int
    ) {
        views.setViewVisibility(containerId, View.VISIBLE)

        val rawMeal = plan.optString("meal", "Meal Plan")
        val mealType = plan.optString("mealType", "").lowercase()
        val icon = when {
            mealType.contains("lunch") || rawMeal.lowercase().contains("lunch") -> "☀️ "
            mealType.contains("dinner") || rawMeal.lowercase().contains("dinner") -> "🌙 "
            mealType.contains("breakfast") || rawMeal.lowercase().contains("breakfast") -> "☕ "
            else -> "🍱 "
        }
        val formattedMeal = if (rawMeal.startsWith("☀️") || rawMeal.startsWith("🌙") || rawMeal.startsWith("☕") || rawMeal.startsWith("🍱")) {
            rawMeal
        } else {
            "$icon$rawMeal"
        }
        val status = plan.optString("status", "pending")
        val planId = plan.optString("planId", "")
        val date = plan.optString("date", "")
        val price = plan.optString("price", "")
        val provider = plan.optString("provider", "")

        views.setTextViewText(mealId, formattedMeal)

        val subText = when {
            price.isNotEmpty() && provider.isNotEmpty() -> "Price: $price • $provider"
            price.isNotEmpty() -> "Price: $price • Daily delivery"
            provider.isNotEmpty() -> provider
            else -> "Scheduled for today"
        }
        views.setTextViewText(subtitleId, subText)

        when (status.lowercase()) {
            "received" -> {
                views.setTextViewText(statusId, "✓ Received")
                views.setTextColor(statusId, Color.parseColor("#34D399"))
                views.setViewVisibility(actionsId, View.GONE)
            }
            "skipped" -> {
                views.setTextViewText(statusId, "✕ Skipped")
                views.setTextColor(statusId, Color.parseColor("#F87171"))
                views.setViewVisibility(actionsId, View.GONE)
            }
            else -> {
                views.setTextViewText(statusId, "• Pending")
                views.setTextColor(statusId, Color.parseColor("#FBBF24"))
                views.setViewVisibility(actionsId, View.VISIBLE)

                if (planId.isNotEmpty() && date.isNotEmpty()) {
                    val receivedUri = Uri.parse("bachelorbuddy://tiffin_mark_received?planId=$planId&date=$date")
                    val receivedIntent = HomeWidgetBackgroundIntent.getBroadcast(context, receivedUri)
                    views.setOnClickPendingIntent(receivedBtnId, receivedIntent)

                    val skipUri = Uri.parse("bachelorbuddy://tiffin_skip?planId=$planId&date=$date")
                    val skipIntent = HomeWidgetBackgroundIntent.getBroadcast(context, skipUri)
                    views.setOnClickPendingIntent(skipBtnId, skipIntent)
                }
            }
        }
    }
}
