import Flutter
import dnssd

/// Makes the iPhone reachable by name in the Wi-Fi for the web version
/// (lib/domain/services/web_server/bonjour_announcer.dart). iOS publishes the device's own
/// host name, like "Romans-iPhone.local", only while it advertises a Bonjour
/// service, so keklist advertises its web server as one and reads the host
/// name back from it. Bonjour needs no multicast entitlement, unlike a
/// responder of the app's own.
final class BonjourPlugin: NSObject, FlutterPlugin {
  private var registration: DNSServiceRef?
  private var resolution: DNSServiceRef?
  private var port = 0
  private var hostName: String?
  private var waiting: [FlutterResult] = []
  private var timeout: DispatchWorkItem?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "keklist/bonjour", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(BonjourPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "advertise":
      guard let args = call.arguments as? [String: Any], let port = args["port"] as? Int else {
        result(FlutterError(code: "bad-arguments", message: "advertise needs a port", details: nil))
        return
      }
      advertise(port: port, result: result)
    case "withdraw":
      withdraw()
      finish(nil)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Answers with the host name once the service on [port] is published.
  private func advertise(port: Int, result: @escaping FlutterResult) {
    if registration != nil && port == self.port {
      if let hostName = hostName {
        result(hostName)
        return
      }
      waiting.append(result)
      if resolution == nil { resolve(name: Self.serviceName) }
      return
    }
    withdraw()
    finish(nil)
    self.port = port
    waiting.append(result)
    var ref: DNSServiceRef?
    let error = DNSServiceRegister(
      &ref, 0, 0, Self.serviceName, Self.serviceType, nil, nil,
      UInt16(port).bigEndian, 0, nil,
      { _, _, error, name, _, _, context in
        let plugin = Unmanaged<BonjourPlugin>.fromOpaque(context!).takeUnretainedValue()
        plugin.registered(error: error, name: name.map { String(cString: $0) })
      },
      Unmanaged.passUnretained(self).toOpaque())
    guard Int(error) == kDNSServiceErr_NoError, let ref = ref else {
      fail(error)
      return
    }
    registration = ref
    DNSServiceSetDispatchQueue(ref, .main)
    startTimeout()
  }

  private func registered(error: DNSServiceErrorType, name: String?) {
    guard Int(error) == kDNSServiceErr_NoError else {
      fail(error)
      return
    }
    // Bonjour renames the service if another one is called "keklist".
    resolve(name: name ?? Self.serviceName)
  }

  private func resolve(name: String) {
    var ref: DNSServiceRef?
    let error = DNSServiceResolve(
      &ref, 0, 0, name, Self.serviceType, "local.",
      { _, _, _, error, _, host, _, _, _, context in
        let plugin = Unmanaged<BonjourPlugin>.fromOpaque(context!).takeUnretainedValue()
        plugin.resolved(error: error, host: host.map { String(cString: $0) })
      },
      Unmanaged.passUnretained(self).toOpaque())
    guard Int(error) == kDNSServiceErr_NoError, let ref = ref else {
      finish(nil)
      return
    }
    resolution = ref
    DNSServiceSetDispatchQueue(ref, .main)
    startTimeout()
  }

  private func resolved(error: DNSServiceErrorType, host: String?) {
    stopResolving()
    guard Int(error) == kDNSServiceErr_NoError, var host = host else {
      finish(nil)
      return
    }
    if host.hasSuffix(".") { host.removeLast() }
    hostName = host
    finish(host)
  }

  /// Without Local Network access the name stays unknown; the address
  /// still works in the Wi-Fi.
  private func startTimeout() {
    timeout?.cancel()
    let item = DispatchWorkItem { [weak self] in
      self?.stopResolving()
      self?.finish(nil)
    }
    timeout = item
    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: item)
  }

  private func fail(_ error: DNSServiceErrorType) {
    withdraw()
    let denied = Int(error) == kDNSServiceErr_PolicyDenied
    finish(
      FlutterError(
        code: denied ? "denied" : "failed",
        message: "Bonjour error \(error)",
        details: nil))
  }

  private func finish(_ value: Any?) {
    timeout?.cancel()
    timeout = nil
    let results = waiting
    waiting = []
    results.forEach { $0(value) }
  }

  private func stopResolving() {
    if let resolution = resolution { DNSServiceRefDeallocate(resolution) }
    resolution = nil
  }

  /// Takes the service off the network; whoever waits is answered by the
  /// caller.
  private func withdraw() {
    stopResolving()
    if let registration = registration { DNSServiceRefDeallocate(registration) }
    registration = nil
    hostName = nil
    port = 0
  }

  private static let serviceName = "keklist"
  private static let serviceType = "_http._tcp"
}
