import Combine
import Foundation
import Spatial

@MainActor
final class DataManager :ObservableObject {
    let bluethoothCentralManager: BluethoothCentralManager
    private var cancellables = Set<AnyCancellable>()
    @Published var carv2DataPair : Carv2DataPair
    @Published var latestCompletedTurnCarv2AnalyzedDataPairs: [Carv2AnalyzedDataPair]  = []
    @Published var finishedTurnDataArray: [SingleFinishedTurnData] = []
    var lastFinishedTrunData: SingleFinishedTurnData {
        get {
            finishedTurnDataArray.last ?? .init(nuberOfTrun: 0, turnSwitchedAngle: Angle2DFloat(), turnStartedTime: Date.now, turnEndedTime: Date.now, turnPhases: [])
        }
    }
    
    
    init(bluethoothCentralManager: BluethoothCentralManager,carv2DataPair: Carv2DataPair) {
        self.bluethoothCentralManager = bluethoothCentralManager
        self.carv2DataPair = carv2DataPair
        subscribe()
    }
    
    func subscribe() {
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
                        Carv2DataPair(left: Carv2Data(leftData), right: Carv2Data(rightData))
                    }
                    .eraseToAnyPublisher()
            }.map{
                Carv2AnalyzedDataPair(left: $0.left, right: $0.right, recordetTime: $0.recordedTime, isTurnSwitching: (Angle2DFloat(degrees: -15).radians..<Angle2DFloat(degrees: 15).radians ~= $0.unitedYawingAngle
                                                                                                                       && $0.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.4), percentageOfTurnsByAngle:
                                        abs(($0.unitedAttitude * self.lastFinishedTrunData.lastPhaseOfTune.unitedAttitude.inverse).angle.radians) / abs(self.lastFinishedTrunData.diffrencialAngleFromStartToEnd.radians), percentageOfTurnsByTime: abs(($0.recordedTime.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970) / self.lastFinishedTrunData.turnDuration))
            }
            .receive(on: RunLoop.main)
            .assign(to: \.carv2DataPair, on: self)
            .store(in: &cancellables)
    }
    
}

import Spatial
struct SingleFinishedTurnData {
    let nuberOfTrun: Int
    let turnSwitchedAngle: Angle2DFloat
    let turnStartedTime: Date
    let turnEndedTime: Date

    let turnPhases: [Carv2AnalyzedDataPair]
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
