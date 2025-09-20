//
//  Untitled.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//
import Foundation
import Spatial
import simd
import SwiftUI
import Combine
import AudioKit

extension Array where Element == Carv2AnalyzedDataPair {
    var fallLineAttitude: Rotation3DFloat {
        Rotation3DFloat(self.map { $0.unitedAttitude.quaternion}.reduce(simd_quatf(), +).normalized)
    }
}

@MainActor
class Carv2DataPair :ObservableObject{
    let left: Carv2Data
    let right: Carv2Data
    let recordedTime: Date
    init(left : Carv2Data = .init() , right: Carv2Data = .init(), recordedTime: Date = .init()){
        self.left = left
        self.right = right
        self.recordedTime = recordedTime
    }
    
    private var numberOfTurn : Int = 0
    public static let shared: Carv2DataPair = .init()
    
    var currentTurn: [Carv2AnalyzedDataPair] = []
    var beforeTurn: [Carv2AnalyzedDataPair] = []
    
    var turnDiffrencial: Rotation3DFloat{
        beforeLastTurnSwitchingUnitedAttitude.inverse * lastTurnSwitchingUnitedAttitude
    }
    //ターン後半30%で内倒しているかどうか
    func isInclineInEndOfTurn(standardTurn: [any OutsideSkiRollAngle] = []) -> Bool {
        return self.currentTurn.last?.isTurnSwitching ?? false
    }
   
    // z がヨーイング角速度の同調　左足前テレマークでの　parallel ski
    var angulerVelocityDiffrencialForTelemarkLeftSideFont: Vector3DFloat {
        return 左側基準の右足の角速度 - Vector3DFloat.init(x: left.angularVelocity.x, y: left.angularVelocity.z, z: -left.angularVelocity.y)
    }
    
    var 左側基準の右足の角速度 : Vector3DFloat {
        return Vector3DFloat.init(x: right.angularVelocity.x, y: -right.angularVelocity.z, z: -right.angularVelocity.y).rotated(by: unifiedDiffrentialAttitudeFromLeftToRight)
    }
    
    // z yaw x roll y pitch
    var angulerVelocityDiffrencialForTelemarkRightSideFont: Vector3DFloat {
        return 右側基準の左足の角速度 - Vector3DFloat.init(x: right.angularVelocity.x, y: right.angularVelocity.z, z: right.angularVelocity.y)
    }
    
    var 右側基準の左足の角速度 : Vector3DFloat {
        return Vector3DFloat.init(x: -left.angularVelocity.x, y: -left.angularVelocity.z, z: left.angularVelocity.y).rotated(by: unifiedDiffrentialAttitudeFromRightToLeft)
    }
    
    var yawingSide: TurnYawingSide {
        get{
            switch unitedYawingAngle {
            case -.infinity..<Angle2DFloat(degrees: -1).radians:
                return TurnYawingSide.RightYawing
            case Angle2DFloat(degrees: 1).radians...Float.infinity:
                return TurnYawingSide.LeftYawing
            default:
                return TurnYawingSide.Straight
            }
        }
    }
    var turnSideChangingPeriodFinder: TurnSideChangingPeriodFinder =
            TurnSideChangingPeriodFinder.init()
    var turnSwitchingDirectionFinder: TurnSwitchingDirectionFinder = TurnSwitchingDirectionFinder.init()
    var turnSwitchingTimingFinder: TurnSwitchingTimingFinder = TurnSwitchingTimingFinder.init()
    var lastTurnSwitchingUnitedAttitude: Rotation3DFloat = .identity
    var beforeLastTurnSwitchingUnitedAttitude: Rotation3DFloat = .identity
    var oneTurnDiffreentialFinder: OneTurnDiffrentialFinder = OneTurnDiffrentialFinder.init()
    var turnPhaseByTime:TurnPhaseByTime = TurnPhaseByTime.init()
    var unitedAttitude:Rotation3DFloat {
        Rotation3DFloat.slerp(from: left.leftRealityKitRotation, to: right.rightRealityKitRotation, t: 0.5)
    }
    var yawingAngulerRateDiffrential: Float { Float(right.angularVelocity.y - left.angularVelocity.y)} 
    // ローリングの方向を　realitykit 用の変換コードを一つの行列変換で表現したやつを掛けて揃えなきゃいけないんだけど、やってない。
    // ここでサボると加速度の変換がおかしなことになる。
    var rollingAngulerRateDiffrential: Float { Float(right.angularVelocity.x + left.angularVelocity.x)}
    // ２つのヨーイング角速度を合計したもの　最新のフレームのみなのか？それとも平均でいくのか？　とりあえず最新フレーム
    var unitedYawingAngle : Float {
        left.angularVelocity.y + right.angularVelocity.y
    }
    
//    func startCSVRecording() {
//        isRecordingCSV = true
//        csvExporter.open( CSVExporter.makeFilePath(fileAlias: "carv2_raw_data"))
//        numberOfTurn = 0
//    }
//    func stopCSVRecording() {
//        csvExporter.close()
//        isRecordingCSV = false
//        numberOfTurn = 0
//    }
    var currentTurnPhaseByTime: Double = 0
    
    var unifiedDiffrentialAttitudeFromRightToLeft: Rotation3DFloat {
        right.rightRealityKitRotation.inverse * left.leftRealityKitRotation
    }
    
    var unifiedDiffrentialAttitudeFromLeftToRight: Rotation3DFloat {
        left.leftRealityKitRotation.inverse * right.rightRealityKitRotation
    }
    
    var rightAngularVelocityProjectedToLeft: Vector3DFloat {
        Vector3DFloat(right.angularVelocity).rotated(by: unifiedDiffrentialAttitudeFromRightToLeft)
    }
    
//     同じやつをここに移植
    func parallelAngleByAttitude() -> Angle2DFloat{
        return (left.leftRealityKitRotation.inverse * right.rightRealityKitRotation).angle
    }
}

