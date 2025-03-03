import SwiftUI
import RealityKit
import Charts

// データ管理用クラス
class ChartDataManager: ObservableObject {
    @Published var dataPoints: [ChartData] = []
    private var startTime = Date()
    
    func addDataPoint(value: Float) {
        let elapsedTime = Date().timeIntervalSince(startTime)
        let newData = ChartData(timestamp: elapsedTime, value: Double(value))
        dataPoints.append(newData)
        
        // データ数を200件に制限
        if dataPoints.count > 200 {
            dataPoints.removeFirst()
        }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let timestamp: TimeInterval
    let value: Double
}
