import Foundation
import AVFoundation
import Photos
import Combine

class CameraManager: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    @Published var session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    override init() {
        super.init()
        checkPermissions()
        setupSession()
    }
    
    func checkPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
        AVCaptureDevice.requestAccess(for: .audio) { _ in }
        PHPhotoLibrary.requestAuthorization { _ in }
    }
    
    func setupSession() {
        // Configurar AudioSession para grabación
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .videoRecording, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Error configurando AudioSession: \(error)")
        }

        session.beginConfiguration()
        
        // Configurar preset de alta calidad
        if session.canSetSessionPreset(.high) {
            session.preferredHardwareAccelerator = .useAlways
            session.sessionPreset = .high
        }
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
            self.videoDeviceInput = videoInput
        }
        
        // Audio Input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        // Output
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func toggleRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            isRecording = false
        } else {
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            if FileManager.default.fileExists(atPath: outputPath) {
                try? FileManager.default.removeItem(at: outputURL)
            }
            
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            isRecording = true
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording: \(error.localizedDescription)")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { success, error in
            if success {
                print("Video saved to photos")
            } else if let error = error {
                print("Error saving to photos: \(error.localizedDescription)")
            }
        }
    }
}
