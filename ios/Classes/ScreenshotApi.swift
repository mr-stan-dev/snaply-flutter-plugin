import Flutter
import UIKit

/// Handles taking screenshots of Flutter views
public class ScreenshotApi {
    // MARK: - Constants
    
    private struct Constants {
        /// Scale factor for image capture (0.3 = 30% of original scale)
        static let captureScale: CGFloat = 0.3
        
        /// JPEG compression qualities to try in order
        static let compressionQualities: [CGFloat] = [0.5, 0.3, 0.1]
    }
    
    /// Possible errors that can occur during screenshot capture
    private enum ScreenshotError: Error {
        case viewControllerNotFound
        case viewNotFound
        case imageCaptureFailed
        case imageCompressionFailed
        
        var flutterError: FlutterError {
            switch self {
            case .viewControllerNotFound:
                return FlutterError(code: "VIEW_CONTROLLER_ERROR",
                                  message: "Flutter view controller not found",
                                  details: nil)
            case .viewNotFound:
                return FlutterError(code: "VIEW_ERROR",
                                  message: "Flutter view not found",
                                  details: nil)
            case .imageCaptureFailed:
                return FlutterError(code: "CAPTURE_ERROR",
                                  message: "Failed to capture screenshot",
                                  details: nil)
            case .imageCompressionFailed:
                return FlutterError(code: "COMPRESSION_ERROR",
                                  message: "Failed to compress image",
                                  details: nil)
            }
        }
    }
    
    /// Takes a screenshot of the current Flutter view
    /// - Parameters:
    ///   - result: Flutter result callback
    ///   - controller: Flutter view controller
    func takeScreenshot(result: @escaping FlutterResult, controller: FlutterViewController!) {
        do {
            // Validate controller and view
            guard let controller = controller else {
                throw ScreenshotError.viewControllerNotFound
            }
            
            guard let view = controller.view else {
                throw ScreenshotError.viewNotFound
            }
            
            // Ensure we're on main thread for UI operations
            DispatchQueue.main.async {
                guard let image = self.captureImage(view: view) else {
                    result(ScreenshotError.imageCaptureFailed.flutterError)
                    return
                }
                
                guard let imageData = self.compressImage(image) else {
                    result(ScreenshotError.imageCompressionFailed.flutterError)
                    return
                }
                
                result(imageData)
            }
        } catch let error as ScreenshotError {
            result(error.flutterError)
        } catch {
            result(FlutterError(code: "UNKNOWN_ERROR",
                              message: error.localizedDescription,
                              details: nil))
        }
    }
    
    /// Captures an image of the provided view
    /// - Parameter view: The view to capture
    /// - Returns: Optional UIImage of the captured view
    private func captureImage(view: UIView) -> UIImage? {
        let scale = UIScreen.main.scale
        let size = view.bounds.size
        
        // Check for valid dimensions
        guard size.width > 0, size.height > 0 else {
            print("Invalid view dimensions for screenshot")
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, view.isOpaque, scale * Constants.captureScale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        // Attempt to capture view hierarchy
        if !view.drawHierarchy(in: view.bounds, afterScreenUpdates: true) {
            print("Failed to draw view hierarchy")
            return nil
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Compresses the image to JPEG format
    /// - Parameter image: The image to compress
    /// - Returns: Optional Data containing the compressed image
    private func compressImage(_ image: UIImage) -> Data? {
        // Try different compression qualities if initial compression fails
        for quality in Constants.compressionQualities {
            if let data = image.jpegData(compressionQuality: quality) {
                return data
            }
        }
        
        return nil
    }
}
