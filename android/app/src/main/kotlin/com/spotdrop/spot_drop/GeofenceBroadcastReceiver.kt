package com.spotdrop.spot_drop

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent

/**
 * Receives geofence transition events from the OS and fires a local notification.
 *
 * This receiver works even when the app is killed — the OS delivers the
 * broadcast directly, which is critical for battery-efficient background
 * geofencing.
 */
class GeofenceBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "geofence_alerts"
        private const val CHANNEL_NAME = "Geofence Alerts"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val geofencingEvent = GeofencingEvent.fromIntent(intent) ?: return

        if (geofencingEvent.hasError()) {
            return
        }

        if (geofencingEvent.geofenceTransition != Geofence.GEOFENCE_TRANSITION_ENTER) {
            return
        }

        val triggeringGeofences = geofencingEvent.triggeringGeofences ?: return
        val prefs = context.getSharedPreferences("spotdrop_geofences", Context.MODE_PRIVATE)

        for (geofence in triggeringGeofences) {
            val identifier = geofence.requestId
            val title = prefs.getString("title_$identifier", "Task") ?: "Task"

            // Show notification
            showNotification(context, identifier, title)

            // Forward to Flutter if app is in foreground
            try {
                MainActivity.eventSink?.success(
                    mapOf(
                        "identifier" to identifier,
                        "event" to "enter"
                    )
                )
            } catch (_: Exception) {
                // App might not be running — notification suffices
            }
        }
    }

    private fun showNotification(context: Context, identifier: String, title: String) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create channel for Android O+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Triggered when you enter a task zone."
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Intent to open the app when notification is tapped
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("taskId", identifier)
        }

        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            identifier.hashCode(),
            launchIntent,
            pendingFlags
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_map)
            .setContentTitle("📍 You're near: $title")
            .setContentText("Tap to view your reminder.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        val notificationId = identifier.hashCode()
        notificationManager.notify(notificationId, notification)
    }
}
