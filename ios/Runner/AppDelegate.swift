import Flutter
import WatchConnectivity
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {
    private var session: WCSession?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let watchMethodChannel = FlutterMethodChannel(name: "com.opdehipt.email_alias/watch",
                                                      binaryMessenger: controller.binaryMessenger)
        watchMethodChannel.setMethodCallHandler({
            [self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case "updateApplicationContext":
                do {
                    try self.update(applicationContext: call.arguments as! [String : Any])
                    result(nil)
                } catch {
                    result(FlutterError(code: "Error updating application context", message: error.localizedDescription, details: nil))
                }
                break;
            default:
                result(FlutterMethodNotImplemented)
                break
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func update(applicationContext context: [String: Any]) throws {
        if let session, session.activationState == .activated && session.isPaired && session.isWatchAppInstalled {
            try session.updateApplicationContext(context)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}
