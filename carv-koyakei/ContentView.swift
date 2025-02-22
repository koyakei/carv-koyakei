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
    @ObservedObject var carv2DataPair = Carv2DataPair.shared
    @ObservedObject var carv1DataPair = Carv1DataPair.shared
    @State private var parallelAngle2 : Double = 0
    @State private var diffTargetAngle : Float = 1.5
    
    private let leftAnchorName: String = "leftAnchor"
    private let rightAnchorName: String = "rightAnchor"
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
    
    @ObservedObject var ble = BluethoothCentralManager()
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
            HStack{
                Text(carv2DataPair.left.attitude.quaternion.formatQuaternion)
                Text(carv2DataPair.right.attitude.quaternion.formatQuaternion)
            }
            Button(action: {
                ble.carv2DataPair.startCSVRecording()
            }){
                Text("start csv")
            }
            Button(action: {
                ble.carv2DataPair.stopCSVRecording()
            }){
                Text("stop csv")
            }
            
//            Text("paralell rotation angle \(carv2DataPair.yawingAngulerRateDiffrential * 10)")
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
                    parallelAngle2 = Double(
                        arrowLeft.orientation(relativeTo: nil).getSignedAngleBetweenQuaternions2(q2: arrowRight.orientation(relativeTo: nil)))
                }

            }
            .frame(height: 800)
        }.onAppear {
            conductor.start()
            manager.startUpdates()
        }
        .onDisappear {
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



#Preview {
    ContentView()
}



