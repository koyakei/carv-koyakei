import SwiftUI
import Combine
import CoreBluetooth
import Spatial
import SceneKit
import RealityKit
import Spatial
import simd
import ARKit
struct ContentView: View {
    @State private var arSession = ARSession()
    @State private var locationManager = CLLocationManager()
    func formatQuaternion(_ quat: simd_quatd) -> String {
        let components = [quat.real, quat.imag.x, quat.imag.y, quat.imag.z]
        
        let rounded = components.map { value in
            String(format: "%.1f", round(value * 10) / 10)  // 四捨五入処理
        }
        
        return """
        simd_quatd(
            real: \(rounded[0]),
            ix: \(rounded[1]),
            iy: \(rounded[2]),
            iz: \(rounded[3])
        )
        """
    }
    @ObservedObject var ble = BluethoothCentralManager()
    @StateObject var carv2DataPair: Carv2DataPair = Carv2DataPair.shared
    var body: some View {
        VStack {
            Text(formatQuaternion(Carv2DataPair.shared.left.attitude.quaternion))
            Button(action: { ble.scan() }) {
                Text("Scan")
            }
            Button(action: { ble.retrieveAndConnect() }) {
                Text("Retrieve and Connect")
            }
            .padding()
            List(ble.carvDeviceList) { device in
                device.id == Carv2Data.leftCharactaristicUUID ? Text("Left") : Text("Right")
                DeviceRow(device: device, ble: ble)
            }
        }
        
        var createArrowEntity = {
            // 矢印エンティティの生成
            // メイン軸（青）
            let mainShaft = ModelEntity(
                mesh: .generateCylinder(height: 0.5, radius: 0.03),
                materials: [SimpleMaterial(color: .blue, isMetallic: true)]
            )
            mainShaft.position.y = 0.5

            // 矢先（赤）
            let arrowHead = ModelEntity(
                mesh: .generateCone(height: 0.3, radius: 0.1),
                materials: [SimpleMaterial(color: .red, isMetallic: true)]
            )
            arrowHead.position.y = 0.65

            // 方向マーカー（X軸）
            let xMarker = ModelEntity(
                mesh: .generateBox(size: [1, 0.02, 0.02]),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            xMarker.position.x = 0.1

            // 方向マーカー（Z軸）
            let zMarker = ModelEntity(
                mesh: .generateBox(size: [0.02, 0.02, 1]),
                materials: [SimpleMaterial(color: .green, isMetallic: false)]
            )
            zMarker.position.z = 0.09

            // ベースプレート（方向判別用）
            let basePlate = ModelEntity(
                mesh: .generateBox(size: [0.2, 0.01, 0.2]),
                materials: [SimpleMaterial(color: .gray, roughness: 0.5, isMetallic: true)]
            )
            basePlate.position.y = -0.005
            let arrowEntity = ModelEntity()
            // 全パーツを追加
            arrowEntity.addChild(mainShaft)
            arrowEntity.addChild(arrowHead)
            arrowEntity.addChild(xMarker)
            arrowEntity.addChild(zMarker)
            arrowEntity.addChild(basePlate)
            
            // 中央固定設定
            arrowEntity.position = [0, 0, -2] // カメラ前方1m
            return arrowEntity
        }
        
        HStack {
            RealityView { content in
                content.camera = .spatialTracking
                
                // ワールド空間アンカーを使用
                let worldAnchor = AnchorEntity(world: .zero)
                let arrowEntity = createArrowEntity()
                worldAnchor.addChild(arrowEntity)
                content.add(worldAnchor)
                
                // 磁北補正用コンポーネント
                let magNorthCorrector = MagneticNorthCorrector()
                
                let controller = RotationController(entity: arrowEntity)
                
                Carv2DataPair.shared.$left
                    .map(\.realityKitRotation)
                    .sink { rotation in
                        controller.bind(rotationPublisher: Just(rotation).eraseToAnyPublisher())
                    }
                    .store(in: &controller.cancellables)
                
                // センサーデータとARセッション情報を統合

            }
            .frame(height: 400)
            
            RealityView { content in
                // カメラ設定（空間追跡有効化）
                content.camera = .spatialTracking
                
                
                let arrowEntity = createArrowEntity()
                let worldAnchor = AnchorEntity(world: .zero)
                worldAnchor.addChild(arrowEntity)
                content.add(worldAnchor)
                
                if let cameraTransform = content.cameraTarget?.transform {
                    arrowEntity.transform.translation = cameraTransform.translation
                }
                
                // 姿勢更新コントローラー
                let controller = RotationController(entity: arrowEntity)
                
                // センサーデータ購読
                Carv2DataPair.shared.$left
                    .map(\.realityKitRotation)
                    .sink { rotation in
                        controller.bind(rotationPublisher: Just(rotation).eraseToAnyPublisher())
                    }
                    .store(in: &controller.cancellables)
            } update: { content in
                // フレーム更新処理
                guard let currentFrame = arSession.currentFrame else { return }
                
                // デバイスの姿勢情報取得
                let deviceTransform = currentFrame.camera.transform
                let deviceRotation = simd_quatf(deviceTransform)
                
                // 磁北補正
                if let heading = locationManager.heading {
                    let northRotation = simd_quatf(
                        angle: Float(-heading.magneticHeading).degreesToRadians,
                        axis: [0, 1, 0]
                    )
                    
                    // センサーデータと統合
                    let correctedRotation = deviceRotation * northRotation
                    content.entities[0].transform.rotation = correctedRotation
                }
                
                // センサーデータ適用
                content.entities[0].transform.rotation = simd_quatf(carv2DataPair.left.realityKitRotation)
            }
            .frame(height: 400)
        }
    }
   
}

extension simd_quatf {
    init(from double4: SIMD4<Double>) {
        self.init(
            ix: Float(double4.x),
            iy: Float(double4.y),
            iz: Float(double4.z),
            r: Float(double4.w)
        )
    }
}
// Carv2DataPairの拡張
extension Carv2DataPair {
    var rotationPublisher: AnyPublisher<Rotation3D, Never> {
        $left.map(\.attitude).eraseToAnyPublisher()
    }
}







#Preview {
    ContentView()
}


struct Arrow3DView: View {
    var rotation: Rotation3D
    
    var body: some View {
        ZStack {
            // 3D矢印の本体
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(width: 100, height: 20)
                .offset(x: 40, y: 0)
            
            // 矢印の頭（3D用に調整）
            Triangle()
                .fill(Color.red)
                .frame(width: 30, height: 20)
                .offset(x: 60, y: 0)
        }
        .frame(width: 200, height: 200)
        .rotation3DEffect(
            rotation.angle,
            axis: rotation.axis,
            anchor: .center,
            perspective: 0.5
        )
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

// 三角形シェイプのカスタム定義
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

extension Rotation3D {
    var angle: Angle {
        Angle(radians: quaternion.angle) // クォータニオンの角度をAngleに変換
    }
    
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        let axis = quaternion.axis
        return (CGFloat(axis.x), CGFloat(axis.y), CGFloat(axis.z))
    }
}
