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
    @State private var parallelAngle = {
        getSignedAngleBetweenQuaternions(q1: simd_quatf(Carv2DataPair.shared.left.leftRealityKitRotation), q2:  simd_quatf(Carv2DataPair.shared.right.rightRealityKitRotation) )
    }
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
            Text(parallelAngle().description)
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
        
        let createArrowEntity = {
            // 矢印エンティティの生成
            // メイン軸（青）Y軸
            let mainShaft = ModelEntity(
                mesh: .generateCylinder(height: 0.5, radius: 0.03),
                materials: [SimpleMaterial(color: .blue, isMetallic: true)]
            )
            mainShaft.position.y = 0.25

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
            xMarker.position.x = 0.2

            // 方向マーカー（Z軸）
            let zMarker = ModelEntity(
                mesh: .generateBox(size: [0.02, 0.02, 1]),
                materials: [SimpleMaterial(color: .green, isMetallic: false)]
            )
            zMarker.position.z = 0.2

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
            
            // 中央固定設定// カメラ前方1m
            return arrowEntity
        }
        let bootsAnchor = {
            let arrowEntity = createArrowEntity()
            let worldAnchor = AnchorEntity(.camera)
            worldAnchor.addChild(arrowEntity)
            worldAnchor.position.z = -2
            return worldAnchor
        }
        HStack {
            RealityView { content in
                // カメラ設定（空間追跡有効化）
                content.camera = .spatialTracking
                let leftBootsAnchor = bootsAnchor()
                leftBootsAnchor.position.x = -0.5
                leftBootsAnchor.name = "LeftArrowAnchor"
                // 左X マイナスがスキーの方向
                let rightBootsAnchor = bootsAnchor()
                rightBootsAnchor.position.x = 0.5
                rightBootsAnchor.name = "RightArrowAnchor"
                content.add(leftBootsAnchor)
                content.add(rightBootsAnchor)
            } update: { content in
                if let arrow = content.entities.first(where: { $0.name == "LeftArrowAnchor" }) {
                    arrow.setOrientation(simd_quatf(Carv2DataPair.shared.left.leftRealityKitRotation), relativeTo: nil)
                }
                if let arrow = content.entities.first(where: { $0.name == "RightArrowAnchor" }) {
                    arrow.setOrientation(simd_quatf(Carv2DataPair.shared.right.rightRealityKitRotation) , relativeTo: nil)
                }
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


#Preview {
    ContentView()
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
import simd

func getSignedAngleBetweenQuaternions(q1: simd_quatf, q2: simd_quatf) -> Float {
    // -X軸方向の基準ベクトル
    let minusX = simd_float3(-1, 0, 0)
    
    // 各クオータニオンで回転後のベクトルを取得
    let v1 = q1.act(minusX)
    let v2 = q2.act(minusX)
    
    // YZ平面への投影
    let proj1 = simd_float3(0, v1.y, v1.z)
    let proj2 = simd_float3(0, v2.y, v2.z)
    
    // 正規化
    let norm1 = simd_normalize(proj1)
    let norm2 = simd_normalize(proj2)
    
    // ゼロベクトルチェック
    if norm1 == .zero || norm2 == .zero {
        return 0
    }
    
    // 内積と外積計算
    let dot = simd_dot(norm1, norm2)
    let cross = simd_cross(norm1, norm2)
    
    // 角度計算（符号付き）
    let angleRad = atan2(cross.x, dot)
    let angleDeg = angleRad * (180 / .pi)
    
    // 角度を-180°～180°に正規化
    return angleDeg.truncatingRemainder(dividingBy: 360) - (angleDeg > 180 ? 360 : 0) + (angleDeg < -180 ? 360 : 0)
}
