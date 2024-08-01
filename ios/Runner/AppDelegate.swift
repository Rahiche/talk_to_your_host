import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let blurhashChannel = FlutterMethodChannel(name: "app.talktoyourhost/blurhash",
                                              binaryMessenger: controller.binaryMessenger)
    blurhashChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // This method is invoked on the UI thread.
      if call.method == "decodeBlurHash" {
        if let args = call.arguments as? [String: Any],
           let blurHash = args["blurHash"] as? String,
           let width = args["width"] as? CGFloat,
           let height = args["height"] as? CGFloat,
           let punch = args["punch"] as? Float {
            self.decodeBlurHash(blurHash: blurHash, size: CGSize(width: width, height: height), punch: punch, result: result)
        } else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing or invalid arguments", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func decodeBlurHash(blurHash: String, size: CGSize, punch: Float, result: FlutterResult) {
    if let blurhashImage = UIImage(blurHash: blurHash, size: size, punch: punch) {
        if let imageData = blurhashImage.pngData() {
            result(FlutterStandardTypedData(bytes: imageData))
        } else {
            result(FlutterError(code: "IMAGE_ENCODING_ERROR", message: "Failed to encode image to PNG data", details: nil))
        }
    } else {
        result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode BlurHash", details: nil))
    }
  }
}

