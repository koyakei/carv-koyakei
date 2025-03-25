import Foundation
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var status: SessionStatus = .unconfigured
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    enum SessionStatus {
        case unconfigured
        case configured
        case unauthorized
    }
    
    override init() {
        super.init()
        checkPermissions()    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            
            configureSession()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted { self?.configureSession() }
            }
        default:
            status = .unauthorized
        }
    }
    
    private func configureSession() {
        sessionQueue.async { // セッション操作を専用キューで実行
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            
            do {
                guard let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .back
                ) else {
                    DispatchQueue.main.async {
                        self.status = .unauthorized
                    }
                    return
                }
                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                
                DispatchQueue.main.async {
                    self.status = .configured
                }
                
                // セッション開始をキュー外で実行
                self.session.commitConfiguration()
                self.session.startRunning() // ここで開始
                
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.status = .unauthorized
                }
            }
        }
    }
}
