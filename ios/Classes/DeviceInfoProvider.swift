import Foundation
import UIKit
import Network

class DeviceInfoProvider {
    static func getDeviceInfo() -> [String: [String: String]] {
        var info: [String: [String: String]] = [:]
        info["device"] = getDeviceSection()
        info["system"] = getSystemSection()
        info["screen"] = getScreenSection()
        info["network"] = getNetworkInfo()
        return info
    }
    
    private static func getDeviceSection() -> [String: String] {
        return [
            "manufacturer": "Apple",
            "brand": "Apple",
            "model": UIDevice.current.model,
            "device": getModelIdentifier(),
            "is_simulator": String(isSimulator)
        ]
    }
    
    private static func getSystemSection() -> [String: String] {
        return [
            "os_name": "iOS",
            "os_version": UIDevice.current.systemVersion,
            "device_type": UIDevice.current.userInterfaceIdiom == .pad ? "tablet" : "mobile"
        ]
    }
    
    private static func getScreenSection() -> [String: String] {
        let scale = UIScreen.main.scale
        let bounds = UIScreen.main.bounds
        let width = Int(bounds.width * scale)
        let height = Int(bounds.height * scale)
        
        return [
            "density": String(format: "%.1f", scale),
            "width": "\(width)",
            "height": "\(height)"
        ]
    }
    
    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    private static func getModelIdentifier() -> String {
        if let simulatorModelId = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelId
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    private static func getNetworkInfo() -> [String: String] {
        let monitor = NWPathMonitor()
        var currentConnection = "unknown"
        var isAvailable = false
        
        let group = DispatchGroup()
        group.enter()
        
        let queue = DispatchQueue(label: "com.snaply.networkMonitor")
        monitor.pathUpdateHandler = { path in
            isAvailable = path.status == .satisfied
            if path.usesInterfaceType(.wifi) {
                currentConnection = "wifi"
            } else if path.usesInterfaceType(.cellular) {
                currentConnection = "mobile"
            }
            group.leave()
        }
        
        monitor.start(queue: queue)
        
        // Wait with timeout
        _ = group.wait(timeout: .now() + 1.0)
        monitor.cancel()
        
        return [
            "type": currentConnection,
            "is_available": String(isAvailable)
        ]
    }
}