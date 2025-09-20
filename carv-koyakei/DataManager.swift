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
    
    var numberOfTurn = 0
    
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
            .assign(to: \.carv2DataPair, on: self)
            .store(in: &cancellables)
        
        $carv2DataPair.sink { (dataPair) in
            self.latestNotCompletedTurnCarv2AnalyzedDataPairs.append(dataPair)
            if dataPair.isTurnSwitching{
                self.finishedTurnDataArray.append(.init(nuberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurnCarv2AnalyzedDataPairs))
                self.latestNotCompletedTurnCarv2AnalyzedDataPairs.removeAll()
                self.numberOfTurn += 1
            }
        }
    }
    func expoert(){
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 整形JSONにしたい場合
              
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
        } catch {
            print("エクスポートに失敗しました: \(error)")
        }
    }
    
}



import Spatial
struct SingleFinishedTurnData :Encodable{
    let nuberOfTrun: Int
    let turnPhases: [Carv2AnalyzedDataPair]
    var turnStartedTime: Date{
        firstPhaseOfTune.recordetTime
    }
    var turnEndedTime: Date{
        lastPhaseOfTune.recordetTime
    }
    
    var turnDuration: TimeInterval{
        turnEndedTime.timeIntervalSince(turnStartedTime)
    }
    var diffrencialAngleFromStartToEnd: Angle2DFloat{
        (lastPhaseOfTune.unitedAttitude * firstPhaseOfTune.unitedAttitude.inverse).angle
    }
    var firstPhaseOfTune: Carv2AnalyzedDataPair{
        turnPhases[safe: 0, default: Carv2AnalyzedDataPair(left: .init(), right: .init(), recordetTime: Date.now, isTurnSwitching: true, percentageOfTurnsByAngle: 0, percentageOfTurnsByTime: 0)]
    }
    var lastPhaseOfTune: Carv2AnalyzedDataPair{
        turnPhases[safe: turnPhases.endIndex - 1 , default: Carv2AnalyzedDataPair(left: .init(), right: .init(), recordetTime: Date.now, isTurnSwitching: true, percentageOfTurnsByAngle: 0, percentageOfTurnsByTime: 0)]
    }
}
