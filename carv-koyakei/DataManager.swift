import Combine
import Foundation
import Spatial

@MainActor
final class DataManager :ObservableObject {
    let bluethoothCentralManager: BluethoothCentralManager
    private var cancellables = Set<AnyCancellable>()
    @Published var carv2DataPair: Carv2AnalyzedDataPair = .init()
    @Published var latestNotCompletedTurnCarv2AnalyzedDataPairs: [Carv2AnalyzedDataPair]  = []
    @Published var finishedTurnDataArray: [SingleFinishedTurnData] = []
    @Published var skytechMode: Bool = false
    
    private var lastFinishedTrunData: SingleFinishedTurnData {
        get {
            finishedTurnDataArray.last ?? .init(nuberOfTrun: 0, turnPhases: [])
        }
    }
    
    init(bluethoothCentralManager: BluethoothCentralManager) {
        self.bluethoothCentralManager = bluethoothCentralManager
        subscribe()
    }
    
    @Published var switchingAngluerRateDegree: Float = 15
    //スカイテックモードと通常モードを分けよう。
    func isTurnSwitchInNomal(carvDataPair: Carv2DataPair) -> Bool{
        if skytechMode {
            (Angle2DFloat(degrees: -switchingAngluerRateDegree).radians..<Angle2DFloat(degrees: switchingAngluerRateDegree).radians ~= carvDataPair.rollingAngulerRateDiffrential && carvDataPair.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.4)
        } else {
            (Angle2DFloat(degrees: -switchingAngluerRateDegree).radians..<Angle2DFloat(degrees: switchingAngluerRateDegree).radians ~= carvDataPair.unitedYawingAngle && carvDataPair.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.4)
        }
    }
    
    @Published var numberOfTurn = 0
    
    private func subscribe() {
        bluethoothCentralManager.$carv2DeviceLeft
            .combineLatest(bluethoothCentralManager.$carv2DeviceRight)
            .compactMap { left, right in
                left.flatMap { l in right.map { r in (l, r) } }
            }
            .flatMap { left, right in
                left.$data
                    .compactMap { $0 }
                    .combineLatest(right.$data.compactMap { $0 })
                    .map { leftData, rightData in
                        let carvDataPair = Carv2DataPair(left: Carv2Data(leftData), right: Carv2Data(rightData))
                        return Carv2AnalyzedDataPair(left: carvDataPair.left, right: carvDataPair.right, recordetTime: carvDataPair.recordedTime, isTurnSwitching: self.isTurnSwitchInNomal(carvDataPair: carvDataPair), percentageOfTurnsByAngle: abs((carvDataPair.unitedAttitude * self.lastFinishedTrunData.lastPhaseOfTune.unitedAttitude.inverse).angle.radians) / abs(self.lastFinishedTrunData.diffrencialAngleFromStartToEnd.radians), percentageOfTurnsByTime: abs((carvDataPair.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970) / self.lastFinishedTrunData.turnDuration))
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: ImmediateScheduler.shared)
            .sink { [weak self] (dataPair: Carv2AnalyzedDataPair) in
                guard let self = self else { return }
                self.carv2DataPair = dataPair
                self.latestNotCompletedTurnCarv2AnalyzedDataPairs.append(dataPair)
                if dataPair.isTurnSwitching {
                    self.finishedTurnDataArray.append(.init(nuberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurnCarv2AnalyzedDataPairs))
                    self.latestNotCompletedTurnCarv2AnalyzedDataPairs.removeAll()
                    self.numberOfTurn += 1
                }
            }
            .store(in: &cancellables)
        
//        $carv2DataPair.sink { (dataPair : Carv2AnalyzedDataPair) in
//            self.latestNotCompletedTurnCarv2AnalyzedDataPairs.append(dataPair)
//            if dataPair.isTurnSwitching{
//                self.finishedTurnDataArray.append(.init(nuberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurnCarv2AnalyzedDataPairs))
//                self.latestNotCompletedTurnCarv2AnalyzedDataPairs.removeAll()
//                self.numberOfTurn += 1
//            }
//        }
    }
    func expoert(){
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
//            encoder.outputFormatting = .prettyPrinted  整形JSONにしたい場合
              
            // データをJSONにエンコード
            let jsonData = try encoder.encode(finishedTurnDataArray)
            let df = DateFormatter()
                df.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        
            // 保存先URL (例: Documentsディレクトリ下のperson.json)
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            if let documentURL = urls.first {
                let fileURL = documentURL.appendingPathComponent("runData\(df.string(from: finishedTurnDataArray[safe: 0, default: SingleFinishedTurnData.init(nuberOfTrun: 0, turnPhases: [])].turnStartedTime)).json")
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
    
}


import Spatial

private struct EncodableTurnPhase: Encodable {
    let timestamp: Date
    let isTurnSwitching: Bool
    let percentageOfTurnsByAngle: Float
    let percentageOfTurnsByTime: TimeInterval
    // Fallback numeric snapshots for attitudes/angles if available; optional to avoid failures
    let unitedAttitudeAngleRadians: Float?

    init(from phase: Carv2AnalyzedDataPair) {
        self.timestamp = phase.recordetTime
        self.isTurnSwitching = phase.isTurnSwitching
        self.percentageOfTurnsByAngle = phase.percentageOfTurnsByAngle
        self.percentageOfTurnsByTime = phase.percentageOfTurnsByTime
        // Try to derive a single representative angle in radians if possible; if the type doesn't expose it, leave nil
        // Assuming `unitedAttitude.angle.radians` exists per usage above
        self.unitedAttitudeAngleRadians = Float(phase.unitedAttitude.angle.radians)
    }
}

struct SingleFinishedTurnData: Encodable {
    let nuberOfTrun: Int
    let turnPhases: [Carv2AnalyzedDataPair]

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
    var firstPhaseOfTune: Carv2AnalyzedDataPair {
        turnPhases[safe: 0, default: Carv2AnalyzedDataPair(left: .init(), right: .init(), recordetTime: Date(timeIntervalSince1970: 0), isTurnSwitching: true, percentageOfTurnsByAngle: 0, percentageOfTurnsByTime: 0)]
    }
    var lastPhaseOfTune: Carv2AnalyzedDataPair {
        turnPhases[safe: turnPhases.endIndex - 1, default: Carv2AnalyzedDataPair(left: .init(), right: .init(), recordetTime: Date(timeIntervalSince1970: 1), isTurnSwitching: true, percentageOfTurnsByAngle: 0, percentageOfTurnsByTime: 0)]
    }

    enum CodingKeys: String, CodingKey {
        case numberOfTrun
        case turnStartedTime
        case turnEndedTime
        case turnDuration
        case diffrencialAngleFromStartToEndRadians
        case phases
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nuberOfTrun, forKey: .numberOfTrun)
        try container.encode(turnStartedTime, forKey: .turnStartedTime)
        try container.encode(turnEndedTime, forKey: .turnEndedTime)
        try container.encode(turnDuration, forKey: .turnDuration)
        // Encode only the radians (Float) to avoid encoding non-Encodable angle type
        try container.encode(Float(diffrencialAngleFromStartToEnd.radians), forKey: .diffrencialAngleFromStartToEndRadians)
        // Map phases into encodable DTOs
        let encodablePhases = turnPhases.map { EncodableTurnPhase(from: $0) }
        try container.encode(encodablePhases, forKey: .phases)
    }
}

