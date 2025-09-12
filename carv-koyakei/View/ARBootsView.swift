//
//  ARView.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/26.
//

import SwiftUI
import RealityKit
import Charts
import Spatial

struct ARBootsView: View {
    @ObservedObject var carv2DataPair : Carv2DataPair = Carv2DataPair.shared
    @StateObject private var cameraManager = CameraManager()
    var carv2AnalyzedDataPairManager = Carv2AnalyzedDataPairManager.init(carv2DataPair: Carv2DataPair.shared)
    @State private var currentScale: CGFloat = 3.0
    @State private var initialScale: CGFloat = 3.0
    let leftAnchorName = "leftAnchor"
    let rightAnchorName = "rightAnchor"
    let unifiedAnchorName = "unifiedAnchor"
    private static func createAxisLabel(text: String, color: UIColor) -> ModelEntity {
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
    
    var body: some View {
        ZStack {
            RealityView { content in
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
                let arrowEntityUnified = createArrowEntity()
                arrowEntityUnified.name = unifiedAnchorName
                worldAnchor.addChild(arrowEntityUnified)
                worldAnchor.position.z = -2
                worldAnchor.name = "worldAnchor"
                content.add(worldAnchor)
            } update: { content in
                guard let arrowLeft = content.entities.first(where: {$0.name == "worldAnchor"})?.children.first(where: { $0.name == leftAnchorName }) else {
                    return }
                arrowLeft.setOrientation(
                    simd_quatf(carv2DataPair.left.leftRealityKitRotation
                              ), relativeTo: nil)
                guard let arrowRight = content.entities.first(where: {$0.name == "worldAnchor"})?.children.first(where: { $0.name == rightAnchorName })else  { return }
                arrowRight.setOrientation(
                    simd_quatf(carv2DataPair.right.rightRealityKitRotation
                              ) , relativeTo: nil)
                
                guard let arrowUnified = content.entities.first(where: {$0.name == "worldAnchor"})?.children.first(where: { $0.name == unifiedAnchorName })else  { return }
                arrowUnified.setOrientation(
                    simd_quatf(Carv2DataPair.shared.unifiedDiffrentialAttitudeFromRightToLeft
                              ) , relativeTo: nil)
                
            }
            .gesture(magnificationGesture)
            .overlay(alignment: .bottom){
//                chartOverlay
//                                .background(
//                                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
//                                        .opacity(0.9)
//                                        .cornerRadius(12)
//                                )
//                                .padding(.horizontal, 20)
//                                .padding(.bottom, 10)
                HStack{
                    VStack{
                        Text( carv2DataPair.angulerVelocityDiffrencialForTelemarkLeftSideFont.x.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.angulerVelocityDiffrencialForTelemarkLeftSideFont.y.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.angulerVelocityDiffrencialForTelemarkLeftSideFont.z.formatted(.number.precision(.fractionLength(1))))
                    }
                    VStack{
                        Text( carv2DataPair.左側基準の右足の角速度.x.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.左側基準の右足の角速度.y.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.左側基準の右足の角速度.z.formatted(.number.precision(.fractionLength(1))))
                    }
                    
                    VStack{
                        Text( carv2DataPair.angulerVelocityDiffrencialForTelemarkRightSideFont.x.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.angulerVelocityDiffrencialForTelemarkRightSideFont.y.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.angulerVelocityDiffrencialForTelemarkRightSideFont.z.formatted(.number.precision(.fractionLength(1))))
                    }
                    VStack{
                        Text( carv2DataPair.右側基準の左足の角速度.x.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.右側基準の左足の角速度.y.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.右側基準の左足の角速度.z.formatted(.number.precision(.fractionLength(1))))
                    }
                    VStack{
                        Text( carv2DataPair.初期姿勢に対しての角速度8.x.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.初期姿勢に対しての角速度8.y.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.初期姿勢に対しての角速度8.z.formatted(.number.precision(.fractionLength(1))))
                    }
                    
                    VStack{
                        Text( carv2DataPair.left.angularVelocity.x.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.left.angularVelocity.y.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.left.angularVelocity.z.formatted(.number.precision(.fractionLength(1))))
                    }
                    VStack{
                        Text( carv2DataPair.right.angularVelocity.x.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.right.angularVelocity.y.formatted(.number.precision(.fractionLength(1))))
                        Text( carv2DataPair.right.angularVelocity.z.formatted(.number.precision(.fractionLength(1))))
                    }
                }
            }
            
                            
        }
    }
    private var magnificationGesture: some Gesture {
            MagnificationGesture()
                .onChanged { value in
                    cameraManager.handleZoomChange(scale: value)
                }
                .onEnded { _ in
                    cameraManager.resetZoomTracking()
                }
        }
    
    // 外足のロール角度を重ねて表示
    private var chartOverlay: some View {
        VStack(alignment: .leading) {
            Text("ロール角比較")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    Chart {
                        // 前回ターン（青い折れ線）
                        ForEach(carv2DataPair.beforeTurn) { data in
                            PointMark(
                                x: .value("フェーズ", abs(data.percentageOfTurnsByTime)),
                                y: .value("角度", abs(data.outsideSkiRollAngle))
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.blue)
                        }
                        
                        // 現在ターン（赤いポイント）
                        ForEach(carv2DataPair.currentTurn) { data in
                            PointMark(
                                x: .value("フェーズ", data.percentageOfTurnsByTime),
                                y: .value("角度", abs(data.outsideSkiRollAngle))
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.red)
                        }
                    }
                    .chartXScale(domain: 0...1)
                    .chartXAxis {
                        AxisMarks(values: [0, 0.2, 0.4, 0.6, 0.8, 1.0]) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text("\(doubleValue, format: .number.precision(.fractionLength(2)))")
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [0, Double.pi/6, Double.pi/3, Double.pi/2]) { value in
                                AxisValueLabel {
                                    if let doubleValue = value.as(Double.self) {
                                        if doubleValue == 0 {
                                            Text("0°")
                                        } else if doubleValue == Double.pi/6 {
                                            Text("30°")
                                        } else if doubleValue == Double.pi/3 {
                                            Text("60°")
                                        } else if doubleValue == Double.pi/2 {
                                            Text("90°")
                                        }
                                    }
                                }
                            }
                    }
                    .chartYScale(domain: 0...(Double.pi/2))
                    .frame(width: 300, height: 150)
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

#Preview {
    ARBootsView()
}
