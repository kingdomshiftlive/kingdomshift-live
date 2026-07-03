import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications
import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyCJ-MmZO_OwSeOtXcbujPvaw5sPvouIzl8")

        // Notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        // Local Notifications isolate support
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        // Flutter Downloader isolate support
        FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

        // Register plugins
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

// Downloader plugin registration for background isolate
private func registerPlugins(registry: FlutterPluginRegistry) {
    if !registry.hasPlugin("FlutterDownloaderPlugin") {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
