//
//  CameraManager.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/03/05.
//
import SwiftUI
import AVFoundation

@Observable
class CameraManager{
    let session = AVCaptureSession()
    private var device: AVCaptureDevice!
    private var initialZoomFactor: CGFloat = 1.0
    private var currentScale: CGFloat = 1.0
    
    // ズーム範囲のプロパティ
    var minZoom: CGFloat { device?.minAvailableVideoZoomFactor ?? 0.5 }
    var maxZoom: CGFloat { device?.maxAvailableVideoZoomFactor ?? 3.0 }
    
    init() {
        configureCamera()
    }
    
    private func configureCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .back) else { return }
        self.device = device
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = 1.0
            device.unlockForConfiguration()
            
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            session.startRunning()
        } catch {
            print("Camera configuration error: \(error)")
        }
    }
    
    func handleZoomChange(scale: CGFloat) {
        guard let device = device else { return }
        
        if currentScale == 1.0 {
            initialZoomFactor = device.videoZoomFactor
        }
        currentScale = scale
        
        let targetZoom = (initialZoomFactor * scale)
            .clamped(to: minZoom...maxZoom)
        
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
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
