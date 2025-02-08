import SwiftUI
import Combine
import CoreBluetooth
import Spatial
import SceneKit

import RealityKit
import Spatial
import simd


struct Arrow3DRealityView: View {
    @StateObject var ble: BluethoothCentralManager
    var body: some View {
            RealityView { content in
                // 矢印エンティティの作成と追加
                let arrowEntity = createArrowEntity()
                content.add(arrowEntity)
                // カメラと照明の設定（検索結果[5][10]を参考）
                let cameraAnchor = AnchorEntity(.camera)
                let camera = PerspectiveCamera()
                camera.look(at: [0, 0, 0], from: [0, 0, 2], relativeTo: nil)
                cameraAnchor.addChild(camera)
                content.add(cameraAnchor)
                
                let directionalLight = DirectionalLight()
                directionalLight.light.intensity = 1000
                directionalLight.look(at: [0, 0, 0], from: [1, 1, 2], relativeTo: nil)
                content.add(directionalLight)
            }
        }
        
        private func createArrowEntity() -> ModelEntity {
            let shaftMesh = MeshResource.generateCylinder(height: 1.0, radius: 0.02)
            let headMesh = MeshResource.generateCone(height: 0.3, radius: 0.08)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            
            let shaftEntity = ModelEntity(mesh: shaftMesh, materials: [material])
            let headEntity = ModelEntity(mesh: headMesh, materials: [material])
            
            shaftEntity.position.y = 0.5
            headEntity.position.y = 1.0
            
            let arrowEntity = ModelEntity()
            arrowEntity.addChild(shaftEntity)
            arrowEntity.addChild(headEntity)
            arrowEntity.name = "mainArrow"
            
            return arrowEntity
        }
}


struct ContentView: View {
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
        
        HStack {
            RealityView { content in
                            // 立方体の生成
                let arrowEntity = ModelEntity()

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

                // 全パーツを追加
                arrowEntity.addChild(mainShaft)
                arrowEntity.addChild(arrowHead)
                arrowEntity.addChild(xMarker)
                arrowEntity.addChild(zMarker)
                arrowEntity.addChild(basePlate)
                        // コンテンツ追加
                        
                Carv2DataPair.shared.left.attitude // これで与えられた姿勢に　arrowEntity　を向ける
                // 姿勢更新ハンドラ
                let controller = RotationController(entity: arrowEntity)
                    content.add(arrowEntity)
                
                    // Combineによる更新
                Carv2DataPair.shared.$left
                    .map(\.realityKitRotation)
                        .eraseToAnyPublisher() // 型変換を明示化
                        .sink { rotation in
                            controller.bind(rotationPublisher: Just(rotation).eraseToAnyPublisher())
                        }
                        .store(in: &controller.cancellables)
                content.add(arrowEntity)
            }
            .frame(height: 400)
            RealityView { content in
                            // 立方体の生成
                let arrowEntity = ModelEntity()

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

                // 全パーツを追加
                arrowEntity.addChild(mainShaft)
                arrowEntity.addChild(arrowHead)
                arrowEntity.addChild(xMarker)
                arrowEntity.addChild(zMarker)
                arrowEntity.addChild(basePlate)
                        // コンテンツ追加
                // 姿勢更新ハンドラ
                let controller = RotationController(entity: arrowEntity)
                    content.add(arrowEntity)
                
                    // Combineによる更新
                Carv2DataPair.shared.$left
                    .map(\.realityKitRotation2)
                        .eraseToAnyPublisher() // 型変換を明示化
                        .sink { rotation in
                            controller.bind(rotationPublisher: Just(rotation).eraseToAnyPublisher())
                        }
                        .store(in: &controller.cancellables)
                content.add(arrowEntity)
            }
            .frame(height: 400)
            RealityView { content in
                            // 立方体の生成
                let arrowEntity = ModelEntity()

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

                // 全パーツを追加
                arrowEntity.addChild(mainShaft)
                arrowEntity.addChild(arrowHead)
                arrowEntity.addChild(xMarker)
                arrowEntity.addChild(zMarker)
                arrowEntity.addChild(basePlate)
                        // コンテンツ追加
                // 姿勢更新ハンドラ
                let controller = RotationController(entity: arrowEntity)
                    // Combineによる更新
                Carv2DataPair.shared.$left
                    .map(\.realityKitRotation3)
                        .eraseToAnyPublisher() // 型変換を明示化
                        .sink { rotation in
                            controller.bind(rotationPublisher: Just(rotation).eraseToAnyPublisher())
                        }
                        .store(in: &controller.cancellables)
                content.add(arrowEntity)
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




struct DeviceRow: View {
    @ObservedObject var device: CarvDevice
    let ble: BluethoothCentralManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(device.id.uuidString)
                .font(.headline)
            Text("State: \(device.connectionState.rawValue)")
                .font(.subheadline)
            Text(device.peripheral.name ?? "(unknown)")
//            Text(device.carv2DataPaird.right.attitude.description)
            HStack {
                Button(action: { ble.connect(carvDevice: device) }) {
                    Text("Connect")
                }
                .disabled(device.connectionState == .connected)
                
                
                if let service = device.services.first {
                    Button(action: { ble.subscribe(servece: service) }) {
                        Text("Subscribe")
                    }
                }
            }
            
            if !device.services.isEmpty {
                            Text("Services:")
                                .font(.headline)
                
                            ForEach(device.services, id: \.uuid) { service in
                                Text(service.uuid.uuidString)
                                    .font(.caption)
                                Button(action: {
                                    device.subscribeAttitude()
                                }) {
                                    Text("Subscribe")
                                }
//                                .disabled(
//                                    device.connectionState != .connected
//                                )
                                
//                                Button(action: { device.unsubscribeAttitude() }) {
//                                    Text("Unsubscribe")
//                                }
//                                .disabled(device.connectionState == .connected)
                            }
                        }
        }
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
