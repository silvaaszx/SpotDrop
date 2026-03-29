import Flutter
import UIKit
import CoreLocation
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    // MARK: — Properties
    
    private let locationManager = CLLocationManager()
    private var methodChannel: FlutterMethodChannel?
    private var eventSink: FlutterEventSink?
    
    // MARK: — Lifecycle
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        // ── Method Channel ──
        methodChannel = FlutterMethodChannel(
            name: "com.spotdrop/geofencing",
            binaryMessenger: controller.binaryMessenger
        )
        methodChannel?.setMethodCallHandler(handleMethodCall)
        
        // ── Event Channel ──
        let eventChannel = FlutterEventChannel(
            name: "com.spotdrop/geofencing_events",
            binaryMessenger: controller.binaryMessenger
        )
        eventChannel.setStreamHandler(self)
        
        // ── Core Location ──
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // ── Notifications ──
        // Handled by flutter_local_notifications plugin
        // UNUserNotificationCenter.current().delegate = self
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: — Method Channel Handler
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerGeofence":
            guard let args = call.arguments as? [String: Any],
                  let identifier = args["identifier"] as? String,
                  let latitude = args["latitude"] as? Double,
                  let longitude = args["longitude"] as? Double,
                  let radius = args["radius"] as? Double,
                  let title = args["title"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            registerGeofence(
                identifier: identifier,
                latitude: latitude,
                longitude: longitude,
                radius: radius,
                title: title,
                result: result
            )
            
        case "removeGeofence":
            guard let args = call.arguments as? [String: Any],
                  let identifier = args["identifier"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing identifier", details: nil))
                return
            }
            removeGeofence(identifier: identifier, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: — Geofence Registration
    
    private func registerGeofence(
        identifier: String,
        latitude: Double,
        longitude: Double,
        radius: Double,
        title: String,
        result: @escaping FlutterResult
    ) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            result(FlutterError(code: "UNAVAILABLE", message: "Geofencing not available", details: nil))
            return
        }
        
        // Clamp radius to device maximum (iOS typically allows ~100km, but we respect API limit)
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(
            center: center,
            radius: clampedRadius,
            identifier: identifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        // Store the title for notification display
        UserDefaults.standard.set(title, forKey: "geofence_title_\(identifier)")
        
        locationManager.startMonitoring(for: region)
        result(true)
    }
    
    private func removeGeofence(identifier: String, result: @escaping FlutterResult) {
        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                locationManager.stopMonitoring(for: region)
                UserDefaults.standard.removeObject(forKey: "geofence_title_\(identifier)")
                result(true)
                return
            }
        }
        // Region not found — still succeed silently
        result(true)
    }
    
    // MARK: — Local Notification (Background-safe)
    
    private func showLocalNotification(identifier: String, title: String) {
        let content = UNMutableNotificationContent()
        content.title = "📍 You're near: \(title)"
        content.body = "Tap to view your reminder."
        content.sound = .default
        content.userInfo = ["taskId": identifier]
        
        let request = UNNotificationRequest(
            identifier: "geofence_\(identifier)",
            content: content,
            trigger: nil // fire immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[SpotDrop] Notification error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: — CLLocationManagerDelegate

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        let identifier = circularRegion.identifier
        let title = UserDefaults.standard.string(forKey: "geofence_title_\(identifier)") ?? "Task"
        
        // 1. Fire local notification immediately (works in background)
        showLocalNotification(identifier: identifier, title: title)
        
        // 2. Forward to Flutter via EventChannel (if app is in foreground)
        eventSink?([
            "identifier": identifier,
            "event": "enter"
        ])
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Currently not used, but the bridge is ready for future use
        guard let circularRegion = region as? CLCircularRegion else { return }
        eventSink?([
            "identifier": circularRegion.identifier,
            "event": "exit"
        ])
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("[SpotDrop] Monitoring failed for region \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
    }
}

// MARK: — FlutterStreamHandler (EventChannel)

extension AppDelegate: FlutterStreamHandler {
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: — UNUserNotificationCenterDelegate

extension AppDelegate {
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handled by flutter_local_notifications plugin
        completionHandler()
    }
}
