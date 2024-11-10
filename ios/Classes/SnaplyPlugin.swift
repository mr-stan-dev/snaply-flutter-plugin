import Flutter
import UIKit
import Network

// MARK: - Constants

private enum SnaplyConstants {
    static let channelName = "SnaplyMethodChannel"
    
    enum Methods {
        static let takeScreenshot = "takeScreenshotMethod"
        static let startRecording = "startScreenRecordingMethod"
        static let stopRecording = "stopScreenRecordingMethod"
        static let shareFiles = "shareFilesMethod"
        static let getSnaplyDirectory = "getSnaplyDirectoryMethod"
        static let getDeviceInfo = "getDeviceInfoMethod"
    }
}

public class SnaplyPlugin: NSObject, FlutterPlugin {
    
    // MARK: - Properties
    
    private let screenRecordApi: ScreenRecordApi
    private let screenshotApi: ScreenshotApi
    private let fileManager: SnaplyFileManager
    
    private weak var controller: FlutterViewController?  // Make weak to avoid retain cycles
    private let messenger: FlutterBinaryMessenger
    
    // MARK: - Initialization
    
    private init(controller: FlutterViewController, messenger: FlutterBinaryMessenger) {
        self.controller = controller
        self.messenger = messenger
        self.screenRecordApi = ScreenRecordApi()
        self.screenshotApi = ScreenshotApi()
        self.fileManager = SnaplyFileManager()
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: SnaplyConstants.channelName, 
                                         binaryMessenger: registrar.messenger())
        
        guard let app = UIApplication.shared.delegate,
              let controller = app.window??.rootViewController as? FlutterViewController else {
            print("Failed to initialize SnaplyPlugin: Could not get FlutterViewController")
            return
        }
        
        let instance = SnaplyPlugin(controller: controller, messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let controller = controller else {
            result(FlutterError(code: "NO_CONTROLLER",
                              message: "FlutterViewController is not available",
                              details: nil))
            return
        }
        
        switch call.method {
        case SnaplyConstants.Methods.takeScreenshot:
            screenshotApi.takeScreenshot(result: result, controller: controller)
        case SnaplyConstants.Methods.startRecording:
            screenRecordApi.startRecording(result: result)
        case SnaplyConstants.Methods.stopRecording:
            screenRecordApi.stopRecording(result: result)
        case SnaplyConstants.Methods.shareFiles:
            fileManager.shareFiles(
                (call.arguments as? [String: Any])?["filePaths"] as? [String],
                result: result
            )
        case SnaplyConstants.Methods.getSnaplyDirectory:
            fileManager.getSnaplyFilesDir(result)
        case SnaplyConstants.Methods.getDeviceInfo:
            handleGetDeviceInfo(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleGetDeviceInfo(result: @escaping FlutterResult) {
        result(DeviceInfoProvider.getDeviceInfo())
    }
}
