import Foundation
import AVFoundation

@MainActor
class CameraViewModel: NSObject {
    var session = AVCaptureSession()
    var status: SessionStatus = .unconfigured
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    enum SessionStatus {
        case unconfigured
        case configured
        case unauthorized
    }
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    Task { @MainActor in
                        self.configureSession()
                    }
                }
            }
        default:
            status = .unauthorized
        }
    }
    
    private func configureSession() {
        sessionQueue.async {
            // Perform session setup off the main actor
            do {
                guard let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .back
                ) else {
                    Task { @MainActor in
                        self.status = .unauthorized
                    }
                    return
                }
                let input = try AVCaptureDeviceInput(device: camera)
                
                self.session.beginConfiguration()
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                self.session.commitConfiguration()
                
                self.session.startRunning()
                
                Task { @MainActor in
                    self.status = .configured
                }
            } catch {
                Task { @MainActor in
                    self.status = .unauthorized
                }
                print(error.localizedDescription)
            }
        }
    }
}
