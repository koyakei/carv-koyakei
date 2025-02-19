import SwiftUI
import Combine
import CoreBluetooth
import Spatial
import SceneKit
import RealityKit
import Spatial
import simd
import ARKit
let manager = OrientationManager()

struct ContentView: View {
    @StateObject private var conductor = DynamicOscillatorConductor()
    @State private var timer: Timer?
    @State private var updateSubscription: AnyCancellable?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var arSession = ARSession()
    @State private var locationManager = CLLocationManager()
    @State private var parallelAngle = {
        getSignedAngleBetweenQuaternions(q1: simd_quatf(Carv2DataPair.shared.left.leftRealityKitRotation), q2:  simd_quatf(Carv2DataPair.shared.right.rightRealityKitRotation) )
    }
    
    @ObservedObject var carv2DataPair = Carv2DataPair.shared // 値が更新されない
    @ObservedObject var carv1DataPair = Carv1DataPair.shared
    @State private var parallelAngle2 : Double = 0
    @State private var diffTargetAngle : Float = 1.5
    private let leftAnchorName: String = "leftAnchor"
    private let rightAnchorName: String = "rightAnchor"
    private let leftAnchorName2: String = "leftAnchor2"
    private let rightAnchorName2: String = "rightAnchor2"
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
    let points: [(x: CGFloat, y: CGFloat)] = [
        (0.4, 0.1),(0.5, 0.1),
        (0.35, 0.15),(0.5, 0.15),(0.6, 0.15),
        (0.35, 0.2),(0.5, 0.2), (0.6, 0.2),
        (0.55, 0.25),
        (0.35, 0.3), (0.45, 0.3),(0.55, 0.3),(0.65, 0.3),
        (0.35, 0.35), (0.45, 0.35), (0.55, 0.35), (0.65, 0.35),
        (0.65, 0.4), (0.65, 0.45), (0.65, 0.5),
        (0.3, 0.6), (0.5, 0.6), (0.65, 0.6),
        (0.3, 0.7), (0.5, 0.7), (0.65, 0.7),
        (0.3, 0.75), (0.5, 0.75), (0.65, 0.75),
        (0.35, 0.8), (0.55, 0.8),
        (0.5, 0.9)
    ]
    var body: some View {
        VStack {
//            Button(action: {
//                Carv1DataPair.shared.calibrateForce()
//            }){
//                Text("Calibrate")
//            }
//            Text(formatQuaternion(carv2DataPair.left.attitude.quaternion))
//            Text("paralell rotation angle \(carv2DataPair.yawingAngulerRateDiffrential * 10)")
//            Text("parallel angle \(ceil(parallelAngle()))")
//            Text("parallel angle2 \(ceil(parallelAngle2))")
//            Slider(
//                            value: $diffTargetAngle,
//                            in: 0.0...3.0,
//                            step: 0.05
//                        ) {
//                            Text("Adjustment")
//                        }
//                        
//                        Text("Current value: \(diffTargetAngle, specifier: "%.2f")")
//                            .padding()
//            Button(action: { conductor.data.isPlaying.toggle()}){
//                conductor.data.isPlaying ? Text("stop paralell tone") : Text("start paralell tone")
//            }
//            Button(action: { ble.scan() }) {
//                Text("Scan")
//            }
            Button(action: { ble.retrieveAndConnect() }) {
                Text("Retrieve and Connect")
            }
            .padding()
            List(ble.carvDeviceList) { device in
                
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
            zLabel.position = [0, 0, 0.3]

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
            arrowEntity.name = leftAnchorName
            worldAnchor.addChild(arrowEntity)
            worldAnchor.position.z = -2
            worldAnchor.name = "worldAnchor"
            return worldAnchor
        }
//        HStack{
//            GeometryReader { geometry in
//                ZStack {
//                    Color.blue // 背景色
//                    
//                    ForEach(0..<points.count, id: \.self) { index in
//                        let point = points[index]
//                        let size = min(geometry.size.width, geometry.size.height)
//                        let x = point.x * size
//                        let y = point.y * size
//                        Circle()
//                            .fill(Color(white: (Double(carv1DataPair.left.pressure[index]) / 60.0) ))
//                            .frame(width: size * 0.03, height: size * 0.03)
//                            .position(x: x, y: y)
//                    }
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//            GeometryReader { geometry in
//                ZStack {
//                    Color.blue // 背景色
//                    
//                    ForEach(0..<points.count, id: \.self) { index in
//                        let point = points[index]
//                        let size = min(geometry.size.width, geometry.size.height)
//                        let x = point.x * size
//                        let y = point.y * size
//                        Text(carv1DataPair.left.pressure[index].hex).position(x: x, y: y)
//                    }
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//        }
        HStack {
            //ARView
            RealityView { content in
                // カメラ設定（空間追跡有効化）
                content.camera = .spatialTracking
                let worldAnchor = AnchorEntity(.camera)
                let arrowEntity = createArrowEntity()
                arrowEntity.name = rightAnchorName
                arrowEntity.position.x = 0.5
                worldAnchor.addChild(arrowEntity)
                let arrowEntityleft = createArrowEntity()
                arrowEntityleft.name = leftAnchorName
                arrowEntityleft.position.x = -0.5
                worldAnchor.addChild(arrowEntityleft)
                worldAnchor.position.z = -2
                worldAnchor.name = "worldAnchor"
                content.add(worldAnchor)
            } update: { content in
                guard let arrowLeft = content.entities.first(where: {$0.name == "worldAnchor"})?.children.first(where: { $0.name == leftAnchorName }) else {
                    return }
                arrowLeft.setOrientation(
                    simd_quatf(Carv2DataPair.shared.left.rightRealityKitRotation
                                                                 ), relativeTo: nil)
                
                guard let arrowRight = content.entities.first(where: {$0.name == "worldAnchor"})?.children.first(where: { $0.name == rightAnchorName })else  { return }
                arrowRight.setOrientation(
                    simd_quatf(Carv2DataPair.shared.right.rightRealityKitRotation
                              ) , relativeTo: nil)
                
                
                DispatchQueue.main.async {
                    parallelAngle2 = Double(getSignedAngleBetweenQuaternions2(q1: arrowLeft.orientation(relativeTo: nil), q2: arrowRight.orientation(relativeTo: nil)))
                }

            }
            .frame(height: 800)
        }.onAppear {
            conductor.start()
            manager.startUpdates()
        }
        .onDisappear {
            timer?.invalidate()
            conductor.stop()
        }.onChange(of: carv2DataPair.yawingAngulerRateDiffrential) {
            if (-diffTargetAngle...diffTargetAngle).contains(carv2DataPair.yawingAngulerRateDiffrential ) {
                conductor.data.isPlaying = false
            } else {
                conductor.data.isPlaying = true
            }
            if carv2DataPair.yawingAngulerRateDiffrential > 0 {
                conductor.panner.pan = 1.0
                conductor.data.frequency = AUValue(ToneStep.lowToHigh(ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
                    
                conductor.changeWaveFormToSin()
            } else {
                conductor.panner.pan = -1.0
                conductor.changeWaveFormToTriangle()
                conductor.data.frequency = AUValue(ToneStep.hight(ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
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
