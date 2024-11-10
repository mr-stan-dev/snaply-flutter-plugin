import Flutter
import UIKit
import ReplayKit
import Photos

/// Handles screen recording functionality using ReplayKit.
public class ScreenRecordApi {
    // MARK: - Properties
    
    private var result: FlutterResult?
    private let recorder = RPScreenRecorder.shared()
    
    private var videoOutputURL: URL?
    private var videoWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?
    private var videoWriterInput: AVAssetWriterInput?
    
    private let nameVideo = "snaply_screen_recording.mp4"
    private var recordAudio = false
    private let screenSize = UIScreen.main.bounds
    
    // MARK: - Public Methods
    
    /// Starts screen recording with optional audio.
    /// - Parameter result: Flutter result callback
    @objc func startRecording(result: @escaping FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "UNSUPPORTED_VERSION",
                              message: "Screen recording requires iOS 11.0 or later",
                              details: nil))
            return
        }
        
        guard !recorder.isRecording else {
            result(FlutterError(code: "ALREADY_RECORDING",
                              message: "Screen recording is already in progress",
                              details: nil))
            return
        }
        
        self.result = result
        
        do {
            try setupVideoWriter()
            try setupRecordingInputs()
            try startScreenCapture()
        } catch let error {
            handleError(error, "Failed to start recording")
            cleanup()
        }
    }
    
    /// Stops the current screen recording.
    /// - Parameter result: Flutter result callback
    @objc func stopRecording(result: @escaping FlutterResult) {
        guard #available(iOS 11.0, *) else {
            result(FlutterError(code: "UNSUPPORTED_VERSION",
                              message: "Screen recording requires iOS 11.0 or later",
                              details: nil))
            return
        }
        
        guard recorder.isRecording else {
            result(FlutterError(code: "NOT_RECORDING",
                              message: "No active recording to stop",
                              details: nil))
            return
        }
        
        RPScreenRecorder.shared().stopCapture { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error, "Failed to stop capture")
                result(nil)
                return
            }
            
            self.finishRecording(result)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupVideoWriter() throws {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        videoOutputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent(nameVideo))
        
        // Clean up existing file
        if let url = videoOutputURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        guard let outputURL = videoOutputURL else {
            throw RecordingError.invalidOutputURL
        }
        
        // Check if directory exists and is writable
        let directory = outputURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    }
    
    private func setupRecordingInputs() throws {
        guard let writer = videoWriter else {
            throw RecordingError.writerNotInitialized
        }
        
        // Video settings with compression
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screenSize.width,
            AVVideoHeightKey: screenSize.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 2000000, // 2Mbps
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        
        // Setup audio if enabled
        if recordAudio {
            let audioSettings: [String: Any] = [
                AVNumberOfChannelsKey: 2,
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 128000 // 128kbps
            ]
            
            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioInput?.expectsMediaDataInRealTime = true
            if let audioInput = audioInput {
                writer.add(audioInput)
            }
        }
        
        // Setup video
        videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriterInput?.expectsMediaDataInRealTime = true
        if let videoInput = videoWriterInput {
            writer.add(videoInput)
        }
    }
    
    private func startScreenCapture() throws {
        recorder.isMicrophoneEnabled = recordAudio
        
        recorder.startCapture { [weak self] buffer, bufferType, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error, "Capture failed")
                return
            }
            
            self.processSampleBuffer(buffer, type: bufferType)
        } completionHandler: { [weak self] error in
            if let error = error {
                self?.handleError(error, "Failed to start capture")
            }
        }
    }
    
    private func processSampleBuffer(_ buffer: CMSampleBuffer, type: RPSampleBufferType) {
        guard let writer = videoWriter,
              CMSampleBufferDataIsReady(buffer) else { return }
        
        switch type {
        case .video:
            if writer.status == .unknown {
                writer.startWriting()
                writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
                self.result?(true)
            }
            
            if writer.status == .writing,
               let input = videoWriterInput,
               input.isReadyForMoreMediaData {
                if !input.append(buffer) {
                    handleError(RecordingError.appendFailed, "Failed to write video data")
                }
            }
            
        case .audioApp, .audioMic:
            if recordAudio,
               writer.status == .writing,
               let input = audioInput,
               input.isReadyForMoreMediaData {
                if !input.append(buffer) {
                    handleError(RecordingError.appendFailed, "Failed to write audio data")
                }
            }
            
        @unknown default:
            print("Unknown buffer type received: \(type)")
        }
        
        if writer.status == .failed {
            handleError(writer.error ?? RecordingError.unknown, "AssetWriter failed")
        }
    }
    
    private func finishRecording(_ result: @escaping FlutterResult) {
        videoWriterInput?.markAsFinished()
        audioInput?.markAsFinished()
        
        videoWriter?.finishWriting { [weak self] in
            guard let self = self,
                  let outputURL = self.videoOutputURL else {
                result(nil)
                return
            }
            
            // Verify file exists and has size
            if !FileManager.default.fileExists(atPath: outputURL.path) {
                self.handleError(RecordingError.fileNotFound, "Recording file not found")
                result(nil)
                return
            }
            
            result(outputURL.relativePath)
            self.saveToPhotoLibrary(outputURL)
            self.cleanup()
        }
    }
    
    private func saveToPhotoLibrary(_ url: URL) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                self?.handleError(RecordingError.photoLibraryAccessDenied, "Photo library access denied")
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, error in
                if let error = error {
                    self?.handleError(error, "Failed to save to photo library")
                } else if success {
                    // Add back the alert
                    DispatchQueue.main.async {
                        let msg = "Your video was successfully saved"
                        let alertController = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        // Get the top view controller to present the alert
                        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                            viewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func handleError(_ error: Error, _ message: String) {
        print("ScreenRecordApi Error: \(message) - \(error.localizedDescription)")
        self.result?(FlutterError(code: "RECORDING_ERROR",
                                message: message,
                                details: error.localizedDescription))
    }
    
    private func cleanup() {
        videoWriter = nil
        videoWriterInput = nil
        audioInput = nil
        videoOutputURL = nil
        result = nil
    }
}

// MARK: - Custom Errors

private enum RecordingError: Error {
    case invalidOutputURL
    case writerNotInitialized
    case appendFailed
    case invalidBuffer
    case fileNotFound
    case photoLibraryAccessDenied
    case unknown
}

