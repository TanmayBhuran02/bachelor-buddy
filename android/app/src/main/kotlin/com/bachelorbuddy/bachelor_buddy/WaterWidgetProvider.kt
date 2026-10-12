package com.bachelorbuddy.bachelor_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
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

            var intake = 0
            var goal = 2500
            var glassMl = 200
            var percent = 0

            val rawData = widgetData.getString("water_widget", null)
            if (rawData != null) {
                try {
                    val json = JSONObject(rawData)
                    intake = json.optInt("intakeMl", 0)
                    goal = json.optInt("goalMl", 2500)
                    glassMl = json.optInt("glassMl", 200)
                    percent = if (goal > 0) (intake * 100 / goal).coerceIn(0, 100) else 0
                } catch (e: Exception) {
                    // Fallback to defaults
                }
            }

            // Generate circular widget bitmap
            val bitmap = createCircularWidgetBitmap(intake, goal, glassMl, percent)
            views.setImageViewBitmap(R.id.water_widget_circle_image, bitmap)

            // Complete circle acts as +1 glass button
            val addUri = Uri.parse("bachelorbuddy://water_add_glass?amount=$glassMl")
            val addIntent = HomeWidgetBackgroundIntent.getBroadcast(context, addUri)
            views.setOnClickPendingIntent(R.id.widget_water_container, addIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun createCircularWidgetBitmap(
        intake: Int,
        goal: Int,
        glassMl: Int,
        percent: Int
    ): Bitmap {
        val size = 512
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val cx = size / 2f
        val cy = size / 2f
        val strokeWidth = 32f
        val ringPadding = 18f
        val ringRadius = (size / 2f) - ringPadding - (strokeWidth / 2f)

        // 1. Draw outer track ring (background circular border)
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            this.strokeWidth = strokeWidth
            color = Color.parseColor("#E0E0E0")
            strokeCap = Paint.Cap.ROUND
        }
        canvas.drawCircle(cx, cy, ringRadius, trackPaint)

        // 2. Draw goal progress arc
        if (percent > 0) {
            val progressPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                this.strokeWidth = strokeWidth
                color = Color.parseColor("#00C4B4") // Vibrant hydration teal
                strokeCap = Paint.Cap.ROUND
            }
            val arcRect = RectF(
                cx - ringRadius,
                cy - ringRadius,
                cx + ringRadius,
                cy + ringRadius
            )
            val sweepAngle = (percent / 100f) * 360f
            canvas.drawArc(arcRect, -90f, sweepAngle, false, progressPaint)
        }

        // 3. Inner button circle (Brutalist card cream surface with bold black outline)
        val innerRadius = ringRadius - (strokeWidth / 2f) - 10f

        // Hard drop shadow for tactile neo-brutalist feel
        val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.parseColor("#1A1A1A")
        }
        canvas.drawCircle(cx + 6f, cy + 6f, innerRadius, shadowPaint)

        // Inner button body
        val innerFillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.parseColor("#FFFEEF")
        }
        canvas.drawCircle(cx, cy, innerRadius, innerFillPaint)

        // Inner button border stroke
        val innerStrokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            this.strokeWidth = 7f
            color = Color.parseColor("#1A1A1A")
        }
        canvas.drawCircle(cx, cy, innerRadius, innerStrokePaint)

        // 4. Center Label: ONLY "+{glassMl}" (e.g. +200)
        val text = "+$glassMl"
        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#1A1A1A")
            textSize = 96f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val textBounds = android.graphics.Rect()
        textPaint.getTextBounds(text, 0, text.length, textBounds)
        val yOffset = cy - textBounds.exactCenterY()
        canvas.drawText(text, cx, yOffset, textPaint)

        return bitmap
    }
}
