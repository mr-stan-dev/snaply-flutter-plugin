import Foundation
import UIKit
import Flutter

class SnaplyFileManager {
    private let snaplyFilesDir = "snaply_files"
    
    /**
     * Returns the directory for storing Snaply temporary files.
     * Creates the directory if it doesn't exist.
     *
     * @return The Snaply files directory path
     * @throws If directory creation fails
     */
    func getSnaplyFilesDir() throws -> String {
                let fileManager = FileManager.default

                // Get cache directory
                guard let cacheDir = fileManager.urls(
                    for: .cachesDirectory,
                    in: .userDomainMask
                ).first else {
                    throw NSError(
                        domain: "SnaplyFileManager",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Cache directory not available"]
                    )
                }

                // Create cache directory if needed
                try fileManager.createDirectory(
                    at: cacheDir,
                    withIntermediateDirectories: true
                )

                // Create and return snaply directory
                let snaplyDir = cacheDir.appendingPathComponent(snaplyFilesDir)
                try fileManager.createDirectory(
                    at: snaplyDir,
                    withIntermediateDirectories: true
                )

                return snaplyDir.path
    }
    
    func shareFiles(_ filePaths: [String]?, result: @escaping FlutterResult) {
        guard let filePaths = filePaths, !filePaths.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "filePaths argument is required", details: nil))
            return
        }
        
        // Convert paths to file URLs and ensure file access
        let fileURLs = filePaths.map { path -> URL in
            let url = URL(fileURLWithPath: path)
            // Start accessing the security-scoped resource
            url.startAccessingSecurityScopedResource()
            return url
        }
        
        let isSingleFile = fileURLs.count == 1
        
        DispatchQueue.main.async {
            let activityItems = fileURLs.map { url -> Any in
                return ShareFileItem(
                    fileURL: url,
                    title: isSingleFile ? "snaply_report.tar" : url.lastPathComponent
                )
            }
            
            let activityViewController = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil
            )
            
            // Configure sharing options based on file type
            if isSingleFile {
                // For single tar file, focus on file transfer options
                activityViewController.excludedActivityTypes = [
                    .assignToContact,
                    .addToReadingList,
                    .openInIBooks,
                    .postToFacebook,
                    .postToFlickr,
                    .postToTencentWeibo,
                    .postToTwitter,
                    .postToVimeo,
                    .postToWeibo,
                    .saveToCameraRoll,
                    .markupAsPDF,
                    .print,
                    .copyToPasteboard
                ]
            } else {
                // For multiple files (images, videos, texts), keep more sharing options
                activityViewController.excludedActivityTypes = [
                    .assignToContact,
                    .addToReadingList,
                    .openInIBooks,
                    .postToFacebook,
                    .postToFlickr,
                    .postToTencentWeibo,
                    .postToTwitter,
                    .postToVimeo,
                    .postToWeibo
                ]
            }
            
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                // For iPad: present as popover
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = viewController.view
                    popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, 
                                              y: UIScreen.main.bounds.height / 2, 
                                              width: 0, 
                                              height: 0)
                }
                
                viewController.present(activityViewController, animated: true) {
                    result("Files shared successfully")
                }
            } else {
                // Stop accessing the security-scoped resources on error
                fileURLs.forEach { $0.stopAccessingSecurityScopedResource() }
                result(FlutterError(code: "SHARE_ERROR", message: "Could not present share sheet", details: nil))
            }
            
            // Add completion handler to stop accessing files
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                // Stop accessing the security-scoped resources when done
                fileURLs.forEach { $0.stopAccessingSecurityScopedResource() }
            }
        }
    }
}

// Add this class to handle file sharing with custom titles
class ShareFileItem: NSObject, UIActivityItemSource {
    let fileURL: URL
    let title: String
    
    init(fileURL: URL, title: String) {
        self.fileURL = fileURL
        self.title = title
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return fileURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return fileURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
} 