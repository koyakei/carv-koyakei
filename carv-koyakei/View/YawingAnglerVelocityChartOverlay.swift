import SwiftUI
import Charts
import AVFoundation

struct YawingAnglerVelocityChartOverlay: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    @State var carv2DataPair: Carv2DataPair = Carv2DataPair.shared
    
    
    var body: some View {
        ZStack {
            // カメラプレビュー
            CameraPreview(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
            Text(carv2DataPair.currentTurn.count.description).foregroundStyle(.green)
            // チャートオーバーレイ
            VStack {
                
                Chart {
                    // 前回ターン（青い折れ線）
                    
                    // 現在ターン（赤いポイント）
                    ForEach(carv2DataPair.currentTurn) { data in
                        PointMark(
                            x: .value("フェーズ", data.percentageOfTurnsByTime),
                            y: .value("角度", data.yawingAngulerRateDiffrential)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.red)
                    }
                    
                    ForEach(carv2DataPair.currentTurn) { data in
                        PointMark(
                            x: .value("フェーズ", data.percentageOfTurnsByTime),
                            y: .value("角度",  data.unifiedDiffrentialAttitudeFromLeftToRight.eulerAngles(order: .xyz).angles.z / .pi * 4)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)
                    }
                }
                .chartXScale(domain: 0...1)
                .chartXAxis {
                    
                    AxisMarks(values: [0, 0.2, 0.4, 0.6, 0.8, 1.0]) { value in
                        AxisGridLine().foregroundStyle(.green)
                        AxisTick().foregroundStyle(.green)
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(doubleValue, format: .number.precision(.fractionLength(2)))").font(.system(size: 12, weight: .bold))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [-1.0, -0.5 ,0, 0.5, 1.0]) { value in
                        AxisGridLine().foregroundStyle(.green)
                        AxisTick().foregroundStyle(.green)
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(doubleValue, format: .number.precision(.fractionLength(2)))").font(.system(size: 12, weight: .bold))
                            }
                        }
                    }
                }
                .chartYScale(domain: -1...1)
                .frame(height: 200)
                .padding()
                .cornerRadius(10)
                .padding(.bottom)
            }
        }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
}
