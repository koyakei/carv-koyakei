import SwiftUI
import RealityKit
import ARKit
import CoreLocation

struct OrientationTrackingView: UIViewRepresentable {
    let locationManager = CLLocationManager()
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR設定（向き追跡専用）
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading // 地磁気北と重力を基準
        config.providesAudioData = false
        arView.session.run(config)
        
        // 位置情報権限リクエスト
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 向き指示用矢印エンティティの更新
        updateOrientationArrow(in: uiView)
    }
    
    private func updateOrientationArrow(in arView: ARView) {
        // 既存のアンカーを削除
        arView.scene.anchors.removeAll()
        
        // 新しいアンカーの作成（カメラに固定）
        let anchor = AnchorEntity(.camera)
        
        // 矢印モデル（向きのみに焦点）
        let arrow = ModelEntity(
            mesh: .generateCone(height: 0.3, radius: 0.1),
            materials: [SimpleMaterial(color: .red, isMetallic: true)]
        )
        
        // デバイスの向きに基づく回転
        if let currentFrame = arView.session.currentFrame {
            let cameraTransform = currentFrame.camera.transform
            let orientation = simd_quatf(cameraTransform)
            
            // 地磁気補正（オプション）
            if let heading = locationManager.heading {
                let magneticRotation = simd_quatf(
                    angle: Float(-heading.magneticHeading).degreesToRadians,
                    axis: [0, 1, 0]
                )
                arrow.transform.rotation = orientation * magneticRotation
            } else {
                arrow.transform.rotation = orientation
            }
        }
        
        anchor.addChild(arrow)
        arView.scene.addAnchor(anchor)
    }
}

// クォータニオン変換拡張
extension simd_quatf {
    init(_ matrix: float4x4) {
        self.init(matrix)
    }
}

extension Float {
    var degreesToRadians: Self { self * .pi / 180 }
}
