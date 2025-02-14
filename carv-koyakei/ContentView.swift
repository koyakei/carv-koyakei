import SwiftUI
import Combine
import CoreBluetooth
import Spatial
import SceneKit
import RealityKit
import Spatial
import simd
import ARKit
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureAudioSession()
        return true
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowAirPlay]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession設定エラー: \(error)")
        }
    }
}
struct ContentView: View {
    @StateObject private var conductor = DynamicOscillatorConductor()
    @State private var timer: Timer?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var arSession = ARSession()
    @State private var locationManager = CLLocationManager()
    @State private var parallelAngle = {
        getSignedAngleBetweenQuaternions(q1: simd_quatf(Carv2DataPair.shared.left.leftRealityKitRotation), q2:  simd_quatf(Carv2DataPair.shared.right.rightRealityKitRotation) )
    }
    @State private var yawingRotationAngle : Float = 0
    @State private var parallelAngle2 : Double = 0
    private let leftAnchorName: String = "leftAnchor"
    private let rightAnchorName: String = "rightAnchor"
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
    func createAxisLabel(text: String, color: UIColor) -> ModelEntity {
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        return ModelEntity(
            mesh: textMesh,
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
    }
    let coordinateConversion = simd_quatf(angle: -.pi/2, axis: [1, 0, 0])

    // クオータニオン変換処理
    func convertSensorQuaternion(_ sensorQuat: simd_quatf) -> simd_quatf {
        return coordinateConversion * sensorQuat * coordinateConversion.inverse
    }
    @ObservedObject var ble = BluethoothCentralManager()
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack {
            Text("paralell rotation angle \(Carv2DataPair.shared.yawingAngulerRateDiffrential * 10)")
            Text("parallel angle \(ceil(parallelAngle()))")
            Text("parallel angle2 \(ceil(parallelAngle2))")
            Button(action: { conductor.data.isPlaying.toggle()}){
                conductor.data.isPlaying ? Text("stop paralell tone") : Text("start paralell tone")
            }
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
            // Y軸ラベル（青）
            let yLabel = createAxisLabel(text: "Y", color: .blue)
            yLabel.position = [0, 0.6, 0]  // メインシャフト上部

            // X軸ラベル（赤）
            let xLabel = createAxisLabel(text: "X", color: .red)
            xLabel.position = [0.3, 0, 0]  // Xマーカー右側
            xLabel.transform.rotation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])

            // Z軸ラベル（緑）
            let zLabel = createAxisLabel(text: "Z", color: .green)
            zLabel.position = [0, 0, 0.3]  // Zマーカー前方
            zLabel.transform.rotation = simd_quatf(angle: -.pi/2, axis: [1, 0, 0])

            // ラベルをエンティティに追加
            arrowEntity.addChild(yLabel)
            arrowEntity.addChild(xLabel)
            arrowEntity.addChild(zLabel)
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
            //ARView
//            RealityView { content in
//                // カメラ設定（空間追跡有効化）
//                content.camera = .virtual
//                let leftBootsAnchor = bootsAnchor()
//                leftBootsAnchor.position.x = -0.5
//                leftBootsAnchor.name = leftAnchorName
//                // 左X マイナスがスキーの方向
//                let rightBootsAnchor = bootsAnchor()
//                rightBootsAnchor.position.x = 0.5
//                rightBootsAnchor.name = rightAnchorName
//                content.add(leftBootsAnchor)
//                content.add(rightBootsAnchor)
//            } update: { content in
//                
//                guard let arrowLeft = content.entities.first(where: { $0.name == leftAnchorName }) else { return }
//                let cameraAlignment = simd_quatf(angle: .pi/2, axis: [0, 0, 1])
//                let finalQuat = cameraAlignment * simd_quatf(Carv2DataPair.shared.left.realityKitRotation3)
////                arrowLeft.transform.rotation = simd_quatf(Carv2DataPair.shared.left.realityKitRotation3)
//                arrowLeft.setOrientation(convertSensorQuaternion(simd_quatf(Carv2DataPair.shared.left.realityKitRotation3)), relativeTo: nil)
////                arrowLeft.setOrientation(worldUpOrientation , relativeTo: nil)
//                
//                guard let arrowRight = content.entities.first(where: { $0.name == rightAnchorName })else  { return }
//                    let worldUpOrientation2 = simd_quatf(
//                        angle: -0.0, // 追加回転不要
//                        axis: [0, 0, 1] // Y軸基準
//                    )
//                
//                arrowRight.setOrientation(convertSensorQuaternion(simd_quatf(Carv2DataPair.shared.left.realityKitRotation4)), relativeTo: nil)
////                arrowRight.transform.rotation = simd_quatf(Carv2DataPair.shared.left.realityKitRotation4)
////                arrowRight.setOrientation(simd_quatf(Carv2DataPair.shared.right.rightRealityKitRotation) * worldUpOrientation2, relativeTo: nil)
//                DispatchQueue.main.async {
//                    parallelAngle2 = Double(getSignedAngleBetweenQuaternions2(q1: arrowLeft.orientation(relativeTo: nil), q2: arrowRight.orientation(relativeTo: nil))) //Modifying state during view update, this will cause undefined behavior.
//                }
//
//            }
//            .frame(height: 400)
        }.onAppear {
            conductor.start()
            Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak conductor] _ in
                    conductor?.data.frequency = AUValue(ToneStep.hight(ceil(Carv2DataPair.shared.yawingAngulerRateDiffrential * 10)))
                    
                    if (-1.0...1.0).contains(Carv2DataPair.shared.yawingAngulerRateDiffrential ) {
                        conductor?.data.isPlaying = false
                    } else {
                        conductor?.data.isPlaying = true
                    }
                    if Carv2DataPair.shared.yawingAngulerRateDiffrential > 0 {
                        conductor?.changeWaveFormToSin()
                    } else {
                        conductor?.changeWaveFormToTriangle()
                    }
                }
                .store(in: &cancellables)
        }
        .onDisappear {
            timer?.invalidate()
            conductor.stop()
        }.onChange(of: scenePhase) {
            if scenePhase == .background {
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    print("バックグラウンドオーディオ維持失敗: \(error)")
                }
            }
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

func getSignedAngleBetweenQuaternions2(q1: simd_quatf, q2: simd_quatf) -> Double {
    let dotProduct = simd_dot(q1.vector, q2.vector)
    let angle = 2 * acos(min(abs(dotProduct), 1.0))
    let degree = Angle(radians: Double(angle)).degrees
    return dotProduct < 0 ? -degree : degree
}

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
