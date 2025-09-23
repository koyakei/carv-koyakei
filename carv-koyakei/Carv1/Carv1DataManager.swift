import Combine
import Foundation
import Spatial

@MainActor
final class Carv1DataManager :ObservableObject {
    let bluethoothCentralManager: Carv1BluethoothCentralManager
    private var cancellables = Set<AnyCancellable>()
    @Published var carvDataPair: Carv1AnalyzedDataPair = .init()
    @Published var latestNotCompletedTurnCarvAnalyzedDataPairs: [Carv1AnalyzedDataPair]  = []
    @Published var finishedTurnDataArray: [Carv1SingleFinishedTurnData] = []
    @Published var skytechMode: Bool = false
    @Published var calibration基準値Right :[Float] = [Float](repeating: 0, count: 38)
    @Published var calibration基準値Left :[Float] = [Float](repeating: 0, count: 38)
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
        $carvDataPair.buffer(size: 15, prefetch: .byRequest, whenFull: .dropOldest)
            .map { data in
                data.left.pressure
            }.reduce([Float](repeating: 0, count: 38), +)
            .map { data in
                data.map{ Float($0) / 15}
            }.assign(to: \.calibration基準値Right, on: self)
//            .sink { [weak self] averagedArray in
//                self?.calibration基準値Right = averagedArray
//            }
            .store(in: &cancellables)
    }
    
    @Published var switchingAngluerRateDegree: Float = 15
    //スカイテックモードと通常モードを分けよう。
    func isTurnSwitchInNomal(carvDataPair: Carv1DataPair) -> Bool{
        if skytechMode {
            (Angle2DFloat(degrees: -switchingAngluerRateDegree).radians..<Angle2DFloat(degrees: switchingAngluerRateDegree).radians ~= carvDataPair.rollingAngulerRateDiffrential && carvDataPair.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.4)
        } else {
            (Angle2DFloat(degrees: -switchingAngluerRateDegree).radians..<Angle2DFloat(degrees: switchingAngluerRateDegree).radians ~= carvDataPair.unitedYawingAngle && carvDataPair.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.4)
        }
    }
    
    @Published var numberOfTurn = 0
    
    private func percentageOfTurnsByAngle(_ carvDataPair: Carv1DataPair)-> Float{
        abs((carvDataPair.unitedAttitude * self.lastFinishedTrunData.lastPhaseOfTune.unitedAttitude.inverse).angle.radians) / abs(self.lastFinishedTrunData.diffrencialAngleFromStartToEnd.radians)
    }
    private func percentageOfTurnsByTime(_ carvDataPair: Carv1DataPair)-> Double{
        abs((carvDataPair.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970) / self.lastFinishedTrunData.turnDuration)
    }
    private func subscribe() {
        bluethoothCentralManager.$carv1DeviceLeft
            .combineLatest(bluethoothCentralManager.$carv1DeviceRight)
            .compactMap { (left: Carv1DevicePeripheral?, right: Carv1DevicePeripheral?) -> (Carv1DevicePeripheral, Carv1DevicePeripheral)? in
                guard let l = left, let r = right else { return nil }
                return (l, r)
            }
            .flatMap { [unowned self] (left: Carv1DevicePeripheral, right: Carv1DevicePeripheral) -> AnyPublisher<Carv1AnalyzedDataPair, Never> in
                left.$data
                    .compactMap { (leftData: Data?) -> Data? in leftData }
                    .combineLatest(
                        right.$data.compactMap { (rightData: Data?) -> Data? in rightData }
                    )
                    .map { (leftData: Data, rightData: Data) -> Carv1AnalyzedDataPair in
                        let carvDataPair = Carv1DataPair(left: Carv1Data(leftData, self.calibration基準値Left), right: Carv1Data(rightData, self.calibration基準値Right))
                        return Carv1AnalyzedDataPair(
                            left: carvDataPair.left,
                            right: carvDataPair.right,
                            recordetTime: carvDataPair.recordedTime,
                            isTurnSwitching: self.isTurnSwitchInNomal(carvDataPair: carvDataPair),
                            percentageOfTurnsByAngle: self.percentageOfTurnsByAngle(carvDataPair),
                            percentageOfTurnsByTime: self.percentageOfTurnsByTime(carvDataPair)
                        )
                    }
                    .eraseToAnyPublisher()
            }
//            .receive(on: ImmediateScheduler.shared)
//            .sink { [weak self] (dataPair: Carv1AnalyzedDataPair) in
//                guard let self = self else { return }
//                self.carvDataPair = dataPair
//                self.latestNotCompletedTurnCarvAnalyzedDataPairs.append(dataPair)
//                if dataPair.isTurnSwitching {
//                    self.finishedTurnDataArray.append(.init(numberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurnCarvAnalyzedDataPairs))
//                    self.latestNotCompletedTurnCarvAnalyzedDataPairs.removeAll()
//                    self.numberOfTurn += 1
//                }
//            }
//            .store(in: &cancellables)
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

