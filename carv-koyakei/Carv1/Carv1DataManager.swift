import Combine
import Foundation
import Spatial
import SwiftUI

@MainActor
final class Carv1DataManager :ObservableObject {
    let bluethoothCentralManager: Carv1BluethoothCentralManager
    private var cancellables = Set<AnyCancellable>()
    @Published var carvRawDataPair:Carv1RawDataPair = .init()
    @Published var carvDataPair: Carv1AnalyzedDataPair = .init(leftPressureOffset: [Float](repeating: 0, count: 14), rightPressureOffset: [Float](repeating: 0, count: 14))
    @Published var latestNotCompletedTurnCarvAnalyzedDataPairs: [Carv1AnalyzedDataPair]  = []
    @Published var finishedTurnDataArray: [Carv1SingleFinishedTurnData] = []
    @Published var skytechMode: Bool = false
    @Published var calibration基準値Right :[Float] = [Float](repeating: 0, count: 14)
    @Published var calibration基準値Left :[Float] = [Float](repeating: 0, count: 14)
    private var lastFinishedTrunData: Carv1SingleFinishedTurnData {
        get {
            finishedTurnDataArray.last ?? .init(numberOfTrun: 0, turnPhases: [])
        }
    }
    
    init(bluethoothCentralManager: Carv1BluethoothCentralManager) {
        self.bluethoothCentralManager = bluethoothCentralManager
        subscribe()
    }
    
    func calibratePressureLeft(){
        // Collect 15 left rawPressure arrays, average them element-wise, then store as calibration baseline
        $carvRawDataPair
            .map { $0.left.rawPressure }
            .collect(25)
            .map {
                arrays -> [Float] in
                guard let first = arrays.first else { return [] }
                var sum = [Float](repeating: 0, count: first.count)
                for arr in arrays {
                    for i in 0..<first.count {
                        sum[i] += arr[i]
                    }
                }
                let count = Float(arrays.count)
                return sum.map { $0 / count }
            }.first()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] avg in
                self?.calibration基準値Left = avg
            })
            .store(in: &cancellables)
    }
    
    @Published var switchingAngluerRateDegree: Float = 15
    //スカイテックモードと通常モードを分けよう。
    func isTurnSwitchInNomal(recordedTime: Date) -> Bool{
        let range = Angle2DFloat(degrees: -switchingAngluerRateDegree).radians ..< Angle2DFloat(degrees: switchingAngluerRateDegree).radians
        if skytechMode {
            return range ~= carvDataPair.rollingAngulerRateDiffrential &&
            (recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970) > 0.4
        } else {
            return range ~= carvDataPair.unitedYawingAngle &&
            (recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970) > 0.4
        }
    }
    
    @Published var numberOfTurn = 0
    private func percentageOfTurnsByAngle(_ carvDataPair: Carv1RawDataPair)-> Float{
        abs((carvDataPair.unitedAttitude * self.lastFinishedTrunData.lastPhaseOfTune.unitedAttitude.inverse).angle.radians) / abs(self.lastFinishedTrunData.diffrencialAngleFromStartToEnd.radians)
    }
    private func percentageOfTurnsByTime(_ carvDataPair: Carv1RawDataPair)-> Double{
        abs((carvDataPair.recordedDate.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970) / self.lastFinishedTrunData.turnDuration)
    }
    private func subscribe() {
        bluethoothCentralManager.$carv1DeviceLeft
            .combineLatest(bluethoothCentralManager.$carv1DeviceRight)
            .compactMap { left, right in
                left.flatMap { l in right.map { r in (l, r) } }
            }
            .flatMap {  (left: Carv1DevicePeripheral, right: Carv1DevicePeripheral) in
                left.$data
                    .compactMap { (leftData: Data?) -> Data? in leftData }
                    .combineLatest(
                        right.$data.compactMap { (rightData: Data?) -> Data? in rightData }
                    ).filter{ leftData, rightData in
                        leftData.first == 0x0A && rightData.first == 0x0A}
                    .map { (leftData: Data, rightData: Data)  in
                        return Carv1RawDataPair(left: Carv1RawData(leftData), right: Carv1RawData(rightData))
                    }
            }
            .assign(to: \.carvRawDataPair, on: self)
            .store(in: &cancellables)
        
        $carvRawDataPair.map {
            let recordedDate: Date = $0.left.recordedTime.timeIntervalSince1970 > $0.right.recordedTime.timeIntervalSince1970 ? $0.left.recordedTime : $0.right.recordedTime
                                    return Carv1AnalyzedDataPair(
                                        left: $0.left,
                                        right: $0.right,
                                        recordetTime: recordedDate,
                                        isTurnSwitching: self.isTurnSwitchInNomal(recordedTime: recordedDate),
                                        percentageOfTurnsByAngle: self.percentageOfTurnsByAngle($0),
                                        percentageOfTurnsByTime: self.percentageOfTurnsByTime($0)
                                    )
        }
            .sink { [weak self] (dataPair: Carv1AnalyzedDataPair) in
                guard let self = self else { return }
                self.carvDataPair = dataPair
                self.latestNotCompletedTurnCarvAnalyzedDataPairs.append(dataPair)
                if dataPair.isTurnSwitching {
                    self.finishedTurnDataArray.append(.init(numberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurnCarvAnalyzedDataPairs))
                    self.latestNotCompletedTurnCarvAnalyzedDataPairs.removeAll()
                    self.numberOfTurn += 1
                }
            }
            .store(in: &cancellables)
    }
    
    // To convert:
    func flatten(turnData: Carv1SingleFinishedTurnData) -> [Carv1TurnPhase] {
        return turnData.turnPhases.map { Carv1TurnPhase(numberOfTurn: turnData.numberOfTrun, turnPhase: $0) }
    }
    
    func expoert(){
        do {
            let iso8601Formatter: ISO8601DateFormatter = {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter
            }()
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
            encoder.dateEncodingStrategy = .custom { date, encoder in
                var container = encoder.singleValueContainer()
                let dateString = iso8601Formatter.string(from: date)
                try container.encode(dateString)
            }
              
            // データをJSONにエンコード
            let jsonData = try encoder.encode(finishedTurnDataArray.map{flatten(turnData: $0)}.flatMap(\.self))
            let df = DateFormatter()
                df.dateFormat = "yyyy年MM月dd日HH:mm:ss"
        
            // 保存先URL (例: Documentsディレクトリ下のperson.json)
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            if let documentURL = urls.first {
                let fileURL = documentURL.appendingPathComponent("runData\(df.string(from: finishedTurnDataArray[safe: 1, default: Carv1SingleFinishedTurnData.init(numberOfTrun: 0, turnPhases: [])].turnStartedTime)).json")
                // ファイルへ書き込み
                try jsonData.write(to: fileURL)
                print("JSONファイルを保存しました: \(fileURL)")
            }
        } catch let EncodingError.invalidValue(value, context) {
            print("エンコード失敗 (invalidValue): value=\(value), codingPath=\(context.codingPath.map(\.stringValue).joined(separator: ".")), debug=\(context.debugDescription)")
        } catch {
            // より詳細なファイル書き込みエラーのログ
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain {
                switch CocoaError.Code(rawValue: nsError.code) {
                case .fileWriteNoPermission:
                    print("ファイル書き込み失敗: 権限がありません。詳細=\(nsError.localizedDescription)")
                case .fileWriteOutOfSpace:
                    print("ファイル書き込み失敗: 空き容量が不足しています。詳細=\(nsError.localizedDescription)")
                case .fileWriteFileExists:
                    print("ファイル書き込み失敗: 同名のファイルが既に存在します。詳細=\(nsError.localizedDescription)")
                case .fileNoSuchFile, .fileReadNoSuchFile:
                    print("ファイル書き込み失敗: ディレクトリ/ファイルが見つかりません。詳細=\(nsError.localizedDescription)")
                case .fileWriteInvalidFileName:
                    print("ファイル書き込み失敗: 無効なファイル名です。詳細=\(nsError.localizedDescription)")
                case .fileWriteUnknown:
                    print("ファイル書き込み失敗: 不明な理由で失敗しました。詳細=\(nsError.localizedDescription)")
                default:
                    print("ファイル書き込み失敗: CocoaError(\(nsError.code)) 詳細=\(nsError.localizedDescription)")
                }
            } else {
                print("エクスポートに失敗しました: \(error.localizedDescription)")
            }
        }
    }
    class DevicePair: ObservableObject {
        @Published var left: Carv1DevicePeripheral?
        @Published var right: Carv1DevicePeripheral?
        init(left: Carv1DevicePeripheral? = nil, right: Carv1DevicePeripheral? = nil) {
            self.left = left
            self.right = right
        }
    }

}


import Spatial


struct Carv1EncodableTurnPhase: Encodable {
    let timestamp: Date
    let isTurnSwitching: Bool
    let percentageOfTurnsByAngle: Float
    let percentageOfTurnsByTime: TimeInterval
    // Fallback numeric snapshots for attitudes/angles if available; optional to avoid failures
    let unitedAttitudeAngleRadians: Float?

    init(from phase: Carv1AnalyzedDataPair) {
        self.timestamp = phase.recordetTime
        self.isTurnSwitching = phase.isTurnSwitching
        self.percentageOfTurnsByAngle = phase.percentageOfTurnsByAngle
        self.percentageOfTurnsByTime = phase.percentageOfTurnsByTime
        // Try to derive a single representative angle in radians if possible; if the type doesn't expose it, leave nil
        // Assuming `unitedAttitude.angle.radians` exists per usage above
        self.unitedAttitudeAngleRadians = phase.unitedAttitude.angle.radians
    }
}


struct Carv1TurnPhase : Encodable{
    let numberOfTurn: Int
    let turnPhase: Carv1AnalyzedDataPair
}


@MainActor
struct Carv1SingleFinishedTurnData: Encodable {
    let numberOfTrun: Int
    let turnPhases: [Carv1AnalyzedDataPair]

    var turnStartedTime: Date {
        firstPhaseOfTune.recordetTime
    }
    var turnEndedTime: Date {
        lastPhaseOfTune.recordetTime
    }
    var turnDuration: TimeInterval {
        turnEndedTime.timeIntervalSince(turnStartedTime)
    }
    var diffrencialAngleFromStartToEnd: Angle2DFloat {
        (lastPhaseOfTune.unitedAttitude * firstPhaseOfTune.unitedAttitude.inverse).angle
    }
    var firstPhaseOfTune: Carv1AnalyzedDataPair {
        turnPhases[safe: 0, default: Carv1AnalyzedDataPair(left: .init(), right: .init(), recordetTime: Date(timeIntervalSince1970: 0), isTurnSwitching: true, percentageOfTurnsByAngle: 0, percentageOfTurnsByTime: 0)]
    }
    
    var lastPhaseOfTune: Carv1AnalyzedDataPair {
        turnPhases[safe: turnPhases.endIndex - 1, default: Carv1AnalyzedDataPair(left: .init(), right: .init(), recordetTime: Date(timeIntervalSince1970: 1), isTurnSwitching: true, percentageOfTurnsByAngle: 0, percentageOfTurnsByTime: 0)]
    }

    enum CodingKeys: String, CodingKey {
        case numberOfTrun
        case turnStartedTime
        case turnEndedTime
        case turnDuration
        case diffrencialAngleFromStartToEndRadians
        case phases
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(numberOfTrun, forKey: .numberOfTrun)
        try container.encode(turnStartedTime, forKey: .turnStartedTime)
        try container.encode(turnEndedTime, forKey: .turnEndedTime)
        try container.encode(turnDuration, forKey: .turnDuration)
        // Encode only the radians (Float) to avoid encoding non-Encodable angle type
        try container.encode(Float(diffrencialAngleFromStartToEnd.radians), forKey: .diffrencialAngleFromStartToEndRadians)
        // Map phases into encodable DTOs
        let encodablePhases = turnPhases.map { Carv1EncodableTurnPhase(from: $0) }
        try container.encode(encodablePhases, forKey: .phases)
    }
}

