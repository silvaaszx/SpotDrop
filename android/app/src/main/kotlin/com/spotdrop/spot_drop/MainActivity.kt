package com.spotdrop.spot_drop

import android.Manifest
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL = "com.spotdrop/geofencing"
        private const val EVENT_CHANNEL = "com.spotdrop/geofencing_events"

        // Singleton event sink so the BroadcastReceiver can push events
        @Volatile
        var eventSink: EventChannel.EventSink? = null
    }

    private lateinit var geofencingClient: GeofencingClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        geofencingClient = LocationServices.getGeofencingClient(this)

        // ── Method Channel ──
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "registerGeofence" -> {
                        val identifier = call.argument<String>("identifier")
                        val latitude = call.argument<Double>("latitude")
                        val longitude = call.argument<Double>("longitude")
                        val radius = call.argument<Double>("radius")
                        val title = call.argument<String>("title")

                        if (identifier == null || latitude == null || longitude == null ||
                            radius == null || title == null
                        ) {
                            result.error("INVALID_ARGS", "Missing arguments", null)
                            return@setMethodCallHandler
                        }

                        registerGeofence(identifier, latitude, longitude, radius.toFloat(), title, result)
                    }

                    "removeGeofence" -> {
                        val identifier = call.argument<String>("identifier")
                        if (identifier == null) {
                            result.error("INVALID_ARGS", "Missing identifier", null)
                            return@setMethodCallHandler
                        }
                        removeGeofence(identifier, result)
                    }

                    else -> result.notImplemented()
                }
            }

        // ── Event Channel ──
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    // ─── Geofence registration ───

    private fun registerGeofence(
        identifier: String,
        latitude: Double,
        longitude: Double,
        radius: Float,
        title: String,
        result: MethodChannel.Result
    ) {
        if (ActivityCompat.checkSelfPermission(
                this, Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            result.error("PERMISSION_DENIED", "Location permission not granted", null)
            return
        }

        // Store title in SharedPreferences for the BroadcastReceiver
        getSharedPreferences("spotdrop_geofences", MODE_PRIVATE)
            .edit()
            .putString("title_$identifier", title)
            .apply()

        val geofence = Geofence.Builder()
            .setRequestId(identifier)
            .setCircularRegion(latitude, longitude, radius)
            .setExpirationDuration(Geofence.NEVER_EXPIRE)
            .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER)
            .build()

        val request = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofence(geofence)
            .build()

        val pendingIntent = getGeofencePendingIntent()

        geofencingClient.addGeofences(request, pendingIntent)
            .addOnSuccessListener { result.success(true) }
            .addOnFailureListener { e ->
                result.error("GEOFENCE_ERROR", e.localizedMessage ?: "Failed to add geofence", null)
            }
    }

    private fun removeGeofence(identifier: String, result: MethodChannel.Result) {
        geofencingClient.removeGeofences(listOf(identifier))
            .addOnSuccessListener {
                getSharedPreferences("spotdrop_geofences", MODE_PRIVATE)
                    .edit()
                    .remove("title_$identifier")
                    .apply()
                result.success(true)
            }
            .addOnFailureListener { e ->
                result.error("GEOFENCE_ERROR", e.localizedMessage ?: "Failed to remove geofence", null)
            }
    }

    private fun getGeofencePendingIntent(): PendingIntent {
        val intent = Intent(this, GeofenceBroadcastReceiver::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getBroadcast(this, 0, intent, flags)
    }
}
