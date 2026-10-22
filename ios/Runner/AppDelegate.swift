import UIKit
import Flutter
import WatchConnectivity
//import workmanager

@main
@objc 
final class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    
    private var watchSession: WCSession?
    
//    private lazy var flutterMethodChannel: FlutterMethodChannel = {
//        let controller = window?.rootViewController as! FlutterViewController
//        return FlutterMethodChannel(
//            name: "com.sashkyn.kekable",
//            binaryMessenger: controller.binaryMessenger
//        )
//    }()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MARK: Activation Apple Watch Session
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession?.delegate = self
            watchSession?.activate()
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
      GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
      registerInterfaceStyleChannel(with: engineBridge.pluginRegistry)
      if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BonjourPlugin") {
          BonjourPlugin.register(with: registrar)
      }

      // MARK: Registation method channel
//      flutterMethodChannel.setMethodCallHandler { [weak self] call, result in
//            let methodArguments = call.arguments
//            guard let watchSession = self?.watchSession,
//                    watchSession.isPaired,
//                    var messageData = (methodArguments as? Array<Any>)?.first as? [String: Any] else {
//                return
//            }
//            guard watchSession.isReachable else {
//                return
//            }
//            messageData["method"] = call.method
//            watchSession.sendMessage(
//                messageData,
//                replyHandler: nil,
//                errorHandler: { error in result(error) }
//            )
//      }
  }
}

extension AppDelegate {

    /// Pins every window to the Flutter theme's brightness so native views (the liquid glass tab bar)
    /// never fall back to the device appearance.
    func registerInterfaceStyleChannel(with registry: FlutterPluginRegistry) {
        guard let registrar = registry.registrar(forPlugin: "KeklistInterfaceStyle") else { return }
        let channel = FlutterMethodChannel(name: "com.sashkyn.keklist/interface_style", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler { call, result in
            guard call.method == "setInterfaceStyle" else {
                result(FlutterMethodNotImplemented)
                return
            }
            let style: UIUserInterfaceStyle
            switch call.arguments as? String {
            case "dark": style = .dark
            case "light": style = .light
            default: style = .unspecified
            }
            for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
                scene.windows.forEach { $0.overrideUserInterfaceStyle = style }
            }
            result(nil)
        }
    }
}

extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("AppDelegate WC: activationDidCompleteWith - \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("AppDelegate WC: sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("AppDelegate WC: sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("AppDelegate WC: session didReceiveMessage - \(message)")
//        
//        guard let methodName = message["method"] as? String else {
//            return
//        }
//        
//        var arguments: [String: Any] = message
//        arguments.removeValue(forKey: "method")
        
        //flutterMethodChannel.invokeMethod(methodName, arguments: arguments)
    }
}
