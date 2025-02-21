//
//  Untitled.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//
import Foundation
import Spatial
import simd
import SwiftUICore

class Carv2DataPair : ObservableObject{
    static let periferalName = "CARV 2"
    @Published var left:  Carv2Data = Carv2Data.init(){
        didSet {
            analyze(oldValue)
        }
    }
    @Published var right: Carv2Data = Carv2Data.init() {
        didSet {
            analyze(oldValue)
        }
    }
    
    @State private var isRecordingCSV = false
    private let  csvExporter = CSVExporter()
    public static let shared: Carv2DataPair = .init()
    var yawingSide: YawingSide = .straight
    var leftSingleTurnSequence: [Carv2AnalyzedData] = []
    var rightSingleTurnSequence: [Carv2AnalyzedData] = []
    var analyzedDataPair : Carv2AnalyzedDataPair = .init(left: .init(attitude: .identity, acceleration: .one, angularVelocity: .one, turnPercentageByAngle: .zero), right: .init(attitude: .identity, acceleration: .one, angularVelocity: .one, turnPercentageByAngle: .zero))
    var turnSideChangingPeriodFinder: TurnSideChangingPeriodFinder =
            TurnSideChangingPeriodFinder.init()
    var turnSwitchingDirectionFinder: TurnSwitchingDirectionFinder = TurnSwitchingDirectionFinder.init()
    var turnSwitchingTimingFinder: TurnSwitchingTimingFinder = TurnSwitchingTimingFinder.init()
    var lastTurnSwitchingAngle: simd_quatf = simd_quatf.init()
    var oneTurnDiffreentialFinder: OneTurnDiffrentialFinder = OneTurnDiffrentialFinder.init()
    // ipad
    static let rightCharactaristicUUID = UUID(uuidString: "85A29A4C-09C3-C632-858A-3387339C67CF")
    static let leftCharactaristicUUID = UUID(uuidString:  "850D8BCF-3B03-1322-F51C-DD38E961FC1A")
    // iphone
//    static let rightCharactaristicUUID = UUID(uuidString: "85E2946B-0D18-FA01-E1C9-0393EDD9013A")
//    static let leftCharactaristicUUID = UUID(uuidString:  "57089C67-2275-E220-B6D3-B16E2639EFD6")

    var yawingAngulerRateDiffrential: Float { Float(right.angularVelocity.y - left.angularVelocity.y)}
    // ２つのヨーイング角速度を合計したもの　最新のフレームのみなのか？それとも平均でいくのか？　とりあえず最新フレーム
    var unitedYawingAngle : Float {
        left.angularVelocity.y + right.angularVelocity.y
    }
    func startCSVRecording() {
        csvExporter.open( CSVExporter.makeFilePath(fileAlias: "carv2_raw_data"))
        isRecordingCSV = true
    }
    func stopCSVRecording() {
        csvExporter.close()
        isRecordingCSV = false
    }
    private func analyze(_ data : Carv2Data) {
        let isTurnSwitching: Bool = turnSwitchingTimingFinder.handle(zRotationAngle: Double(unitedYawingAngle), timeInterval: data.recordetTime)
        let oneTurnDiffAngleEuller = oneTurnDiffreentialFinder.handle(isTurnSwitched: isTurnSwitching, currentTurnSwitchAngle: data.attitude.quaternion.simd_quatf)
        let turnPhasePercantageByAngle =  FindTurnPhaseBy100.init().handle(currentRotationEullerAngleFromTurnSwitching: CurrentDiffrentialFinder.init().handle(lastTurnSwitchAngle: lastTurnSwitchingAngle, currentQuaternion: data.attitude.quaternion), oneTurnDiffrentialAngle: oneTurnDiffAngleEuller) // 左右の統合が必要そう
        if isTurnSwitching {
            leftSingleTurnSequence.removeAll()
            rightSingleTurnSequence.removeAll()
            lastTurnSwitchingAngle = simd_quatf(data.attitude.quaternion)
        }
    }// 左右を配列で知らせる　CSVには外足内足で並べる
    
    func receive(left data: Carv2Data)  -> Carv2AnalyzedDataPair {
        self.left = data
//        leftSingleTurnSequence.append(
//            Carv2AnalyzedData(attitude: data.attitude, acceleration: data.acceleration, angularVelocity: data.angularVelocity, turnPercentageByAngle: turnPhasePercantageByAngle)
//        ) // これをｃSVにしゅつりょくしたい
        if self.isRecordingCSV {
            self.csvExporter.write(analyzedDataPair)
        }
        return analyzedDataPair
    }
    func receive(right data: Carv2Data) -> Carv2AnalyzedDataPair  {
        self.right = data
        if self.isRecordingCSV {
            self.csvExporter.write(analyzedDataPair)
        }
        return analyzedDataPair
    }
}


struct TurnSideChangingPeriodFinder {
    var lastSwitchedTurnSideTimeStamp: TimeInterval = Date.now.timeIntervalSince1970
    

    mutating func handle
    (currentTimeStampSince1970: TimeInterval, isTurnSwitching: Bool) -> TimeInterval {
        let period = currentTimeStampSince1970 - lastSwitchedTurnSideTimeStamp
       if (isTurnSwitching)  {
            lastSwitchedTurnSideTimeStamp = currentTimeStampSince1970
        }
        return period
    }
}
