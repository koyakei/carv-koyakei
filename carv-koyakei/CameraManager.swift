import SwiftUI
@preconcurrency import AVFoundation

@Observable
@MainActor
class CameraManager {
    let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private var initialZoomFactor: CGFloat = 1.0
    private var currentScale: CGFloat = 1.0

    var minZoom: CGFloat { device?.minAvailableVideoZoomFactor ?? 0.5 }
    var maxZoom: CGFloat { device?.maxAvailableVideoZoomFactor ?? 3.0 }

    init() {
        configureCamera()
    }

    private func configureCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera device found")
            return
        }
        self.device = device

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let input = try AVCaptureDeviceInput(device: device)
                guard let session = self?.session else { return }
                
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                session.startRunning()
            } catch {
                print("Camera configuration error: \(error)")
            }
        }
    }

    func handleZoomChange(scale: CGFloat) {
        guard let device = device else { return }

        if currentScale == 1.0 {
            initialZoomFactor = device.videoZoomFactor
        }
        currentScale = scale

        let targetZoom = (initialZoomFactor * scale).clamped(to: minZoom...maxZoom)

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = targetZoom
            device.unlockForConfiguration()
        } catch {
            print("Zoom adjustment error: \(error)")
        }
    }

    func resetZoomTracking() {
        currentScale = 1.0
    }
}

// MARK: - ヘルパー拡張
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
