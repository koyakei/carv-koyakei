//
//  ARView.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/26.
//

import SwiftUI
import RealityKit
import Charts
import AVFoundation

struct ARBootsView: View {
    @ObservedObject var carv2DataPair = Carv2DataPair.shared
    @StateObject private var chartDataManager = ChartDataManager()
    @State private var currentScale: CGFloat = 3.0
    @State private var initialScale: CGFloat = 3.0
    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    let leftAnchorName = "leftAnchor"
    let rightAnchorName = "rightAnchor"
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
    
    func zoomIn() {
        do {
            try device?.lockForConfiguration()
            let targetZoom: CGFloat = 3.0
            let duration: TimeInterval = 0.25
            
            // レート計算（変化量/時間）
            let rate = (targetZoom - (device?.videoZoomFactor ?? 0)) / duration
            device?.ramp(toVideoZoomFactor: targetZoom, withRate: Float(rate))
            
            device?.unlockForConfiguration()
        } catch {
            print("ズーム設定エラー: \(error)")
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
                worldAnchor.position.z = -2
                worldAnchor.name = "worldAnchor"
                content.add(worldAnchor)
            } update: { content in
                guard let arrowLeft = content.entities.first(where: {$0.name == "worldAnchor"})?.children.first(where: { $0.name == leftAnchorName }) else {
                    return }
                arrowLeft.setOrientation(
                    simd_quatf(Carv2DataPair.shared.left.leftRealityKitRotation
                              ), relativeTo: nil)
                guard let arrowRight = content.entities.first(where: {$0.name == "worldAnchor"})?.children.first(where: { $0.name == rightAnchorName })else  { return }
                arrowRight.setOrientation(
                    simd_quatf(Carv2DataPair.shared.right.rightRealityKitRotation
                              ) , relativeTo: nil)
            }
            .gesture(magnificationGesture)
            .overlay(alignment: .bottom){
                Button(action: zoomIn){
                    Text("zoom")
                }
//                chartOverlay
//                                .background(
//                                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
//                                        .opacity(0.9)
//                                        .cornerRadius(12)
//                                )
//                                .padding(.horizontal, 20)
//                                .padding(.bottom, 10)
            }
            
                            
        }
    }
    private var magnificationGesture: some Gesture {
            MagnificationGesture()
                .onChanged { value in
                    let newScale = self.initialScale * value
                    self.currentScale = min(max(newScale, 0.3), 3.0)
                }
                .onEnded { _ in
                    self.initialScale = self.currentScale
                }
        }
    
    private var chartOverlay: some View {
        VStack(alignment: .leading) {
            Text("リアルタイム回転角度")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            Chart(chartDataManager.dataPoints) { data in
                LineMark(
                    x: .value("時間", data.timestamp),
                    y: .value("角度", data.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue)
                
                AreaMark(
                    x: .value("時間", data.timestamp),
                    y: .value("角度", data.value)
                )
                .foregroundStyle(LinearGradient(
                    colors: [.blue.opacity(0.2), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: Decimal.FormatStyle.number.precision(.fractionLength(0)))
                }
            }
            .chartYScale(domain: 0...(.pi))
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: Double.pi/2)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(doubleValue, format: .number.precision(.fractionLength(2)))π")
                        }
                    }
                }
            }
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
    ARBootsView(carv2DataPair: Carv2DataPair())
}
