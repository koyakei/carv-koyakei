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
    // ipad
    static let rightCharactaristicUUID = UUID(uuidString: "85A29A4C-09C3-C632-858A-3387339C67CF")
    static let leftCharactaristicUUID = UUID(uuidString:  "850D8BCF-3B03-1322-F51C-DD38E961FC1A")
    // iphone
//    static let rightCharactaristicUUID = UUID(uuidString: "85E2946B-0D18-FA01-E1C9-0393EDD9013A")
//    static let leftCharactaristicUUID = UUID(uuidString:  "57089C67-2275-E220-B6D3-B16E2639EFD6")
    
    static let periferalName = "CARV 2"
    @Published var left:  Carv2Data = Carv2Data.init()
    @Published var right: Carv2Data = Carv2Data.init()
    private var isRecordingCSV = false
    private let  csvExporter = CSVExporter()
    private var numberOfTurn : Int = 0
    public static let shared: Carv2DataPair = .init()
    @Published var currentTurn: [Carv2AnalyzedDataPair] = []
    @Published var beforeTurn: [Carv2AnalyzedDataPair] = []
    
    func turnDiffrencial(){
        beforeLastTurnSwitchingUnitedAttitude.inverse * lastTurnSwitchingUnitedAttitude
    }
    //ターン後半30%で内筒しているかどうか
    func isInclineInEndOfTurn(standardTurn: [any OutsideSkiRollAngle] = []) -> Bool {
        return self.currentTurn.last?.isTurnSwitching ?? false
    }
    
    
    func receive(data: Carv2AnalyzedDataPair){
        currentTurn.append(data)
        if currentTurn.count > 200 { // 20fps * 3 が最大だろう　２００は楽勝
            currentTurn.removeFirst()
        }
        
        if data.isTurnSwitching {
            self.beforeTurn = self.currentTurn
            self.currentTurn = []
        }
    }
    
    var yawingSide: TurnYawingSide {
        get{
            switch unitedYawingAngle {
            case -.infinity..<Float(Angle2D(degrees: -1).radians):
                return TurnYawingSide.RightYawing
            case Float(Angle2D(degrees: 1).radians)...Float.infinity:
                return TurnYawingSide.LeftYawing
            default:
                return TurnYawingSide.Straight
            }
        }
    }
    
    var leftSingleTurnSequence: [Carv2AnalyzedData] = []
    var rightSingleTurnSequence: [Carv2AnalyzedData] = []
    var analyzedDataPair : Carv2AnalyzedDataPair = .init(left: .init(attitude: .identity, acceleration: .one, angularVelocity: .one), right: .init(attitude: .identity, acceleration: .one, angularVelocity: .one), isTurnSwitching: false,percentageOfTurnsByAngle: .zero, percentageOfTurnsByTime: Date.now.timeIntervalSince1970, numberOfTurns: .zero, recordetTime: Date.now.timeIntervalSince1970)
    var turnSideChangingPeriodFinder: TurnSideChangingPeriodFinder =
            TurnSideChangingPeriodFinder.init()
    var turnSwitchingDirectionFinder: TurnSwitchingDirectionFinder = TurnSwitchingDirectionFinder.init()
    var turnSwitchingTimingFinder: TurnSwitchingTimingFinder = TurnSwitchingTimingFinder.init()
    var lastTurnSwitchingUnitedAttitude: Rotation3D = .identity
    var beforeLastTurnSwitchingUnitedAttitude: Rotation3D = .identity
    var oneTurnDiffreentialFinder: OneTurnDiffrentialFinder = OneTurnDiffrentialFinder.init()
    var turnPhaseByTime:TurnPhaseByTime = TurnPhaseByTime.init()
    var unitedAttitude:Rotation3D {
        Rotation3D.slerp(from: left.leftRealityKitRotation, to: right.rightRealityKitRotation, t: 0.5)
    }
    var yawingAngulerRateDiffrential: Float { Float(right.angularVelocity.y - left.angularVelocity.y)}
    // ローリングの方向を　realitykit 用の変換コードを一つの行列変換で表現したやつを掛けて揃えなきゃいけないんだけど、やってない。
    // ここでサボると加速度の変換がおかしなことになる。
    var rollingAngulerRateDiffrential: Float { Float(right.angularVelocity.x + left.angularVelocity.x)}
    // ２つのヨーイング角速度を合計したもの　最新のフレームのみなのか？それとも平均でいくのか？　とりあえず最新フレーム
    var unitedYawingAngle : Float {
        left.angularVelocity.y + right.angularVelocity.y
    }
    
    func startCSVRecording() {
        isRecordingCSV = true
        csvExporter.open( CSVExporter.makeFilePath(fileAlias: "carv2_raw_data"))
        numberOfTurn = 0
    }
    func stopCSVRecording() {
        csvExporter.close()
        isRecordingCSV = false
        numberOfTurn = 0
    }
    var currentTurnPhaseByTime: Double = 0
//     同じやつをここに移植
    lazy var  parallelAngleByAttitude = Double(
                    left.leftRealityKitRotation.quaternion.simd_quatf.getSignedAngleBetweenQuaternions2(q2: right.rightRealityKitRotation.quaternion.simd_quatf))
    func receive(left data: Carv2Data)  -> Carv2AnalyzedDataPair {
        self.left = data
        let isTurnSwitching: Bool = turnSwitchingTimingFinder.handle(zRotationAngle: Double(unitedYawingAngle), timeInterval: data.recordetTime)
        let oneTurnDiffAngleEuller = oneTurnDiffreentialFinder.handle(isTurnSwitched: isTurnSwitching, currentTurnSwitchAngle: analyzedDataPair.unitedAttitude.quaternion.simd_quatf)
        let turnPhasePercantageByAngle =  FindTurnPhaseBy100.init().handle(currentRotationEullerAngleFromTurnSwitching: CurrentDiffrentialFinder.init().handle(lastTurnSwitchAngle: lastTurnSwitchingUnitedAttitude.quaternion.simd_quatf, currentQuaternion: analyzedDataPair.unitedAttitude.quaternion.simd_quatf), oneTurnDiffrentialAngle: oneTurnDiffAngleEuller)
        if isTurnSwitching {
            leftSingleTurnSequence.removeAll()
            rightSingleTurnSequence.removeAll()
            beforeLastTurnSwitchingUnitedAttitude = lastTurnSwitchingUnitedAttitude
            lastTurnSwitchingUnitedAttitude = unitedAttitude
            numberOfTurn = numberOfTurn + 1
            turnPhaseByTime.turnSwitched(currentTime: data.recordetTime)
        }
        analyzedDataPair.left = Carv2AnalyzedData(attitude: data.attitude, acceleration: data.acceleration, angularVelocity: data.angularVelocity)
        analyzedDataPair.numberOfTurns = numberOfTurn
        analyzedDataPair.percentageOfTurnsByAngle = Float(turnPhasePercantageByAngle)
        analyzedDataPair.percentageOfTurnsByTime = turnPhaseByTime.handle(currentTime: data.recordetTime, currentAttitude: data.leftRealityKitRotation)
        analyzedDataPair.recordetTime = data.recordetTime
        analyzedDataPair.isTurnSwitching = isTurnSwitching
        if isRecordingCSV {
            csvExporter.write(analyzedDataPair)
        }
        receive(data: analyzedDataPair)
        return analyzedDataPair
    }
    
    func receive(right data: Carv2Data)  -> Carv2AnalyzedDataPair {
        self.right = data
        let isTurnSwitching: Bool = turnSwitchingTimingFinder.handle(zRotationAngle: Double(unitedYawingAngle), timeInterval: data.recordetTime)
        let oneTurnDiffAngleEuller = oneTurnDiffreentialFinder.handle(isTurnSwitched: isTurnSwitching, currentTurnSwitchAngle: analyzedDataPair.unitedAttitude.quaternion.simd_quatf)
        let turnPhasePercantageByAngle =  FindTurnPhaseBy100.init().handle(currentRotationEullerAngleFromTurnSwitching: CurrentDiffrentialFinder.init().handle(lastTurnSwitchAngle: lastTurnSwitchingUnitedAttitude.quaternion.simd_quatf, currentQuaternion: analyzedDataPair.unitedAttitude.quaternion.simd_quatf), oneTurnDiffrentialAngle: oneTurnDiffAngleEuller)
        if isTurnSwitching {
            leftSingleTurnSequence.removeAll()
            rightSingleTurnSequence.removeAll()
            beforeLastTurnSwitchingUnitedAttitude = lastTurnSwitchingUnitedAttitude
            lastTurnSwitchingUnitedAttitude = unitedAttitude
            numberOfTurn = numberOfTurn + 1
            turnPhaseByTime.turnSwitched(currentTime: data.recordetTime)
        }
        analyzedDataPair.right = Carv2AnalyzedData(attitude: data.attitude, acceleration: data.acceleration, angularVelocity: data.angularVelocity)
        analyzedDataPair.numberOfTurns = numberOfTurn
        analyzedDataPair.percentageOfTurnsByAngle = Float(turnPhasePercantageByAngle)
        analyzedDataPair.percentageOfTurnsByTime = turnPhaseByTime.handle(currentTime: data.recordetTime, currentAttitude: data.rightRealityKitRotation)
        analyzedDataPair.recordetTime = data.recordetTime
        analyzedDataPair.isTurnSwitching = isTurnSwitching
        if isRecordingCSV {
            csvExporter.write(analyzedDataPair)
        }
        receive(data: analyzedDataPair)
        return analyzedDataPair
    }
}




    

