//
// Created by koyanagi on 2021/11/18.
//

import Foundation
import CoreMotion
import simd
struct UnifiedTurnPhase {

    var skiFallLineOrthogonalAcceleration: simd_double3
    let bodyFallLineOrthogonalAcceleration: simd_double3
    var skiFallLineAcceleration: simd_double3
    var bodyFallLineAcceleration: simd_double3
    var skiRotationRate: CMRotationRate
    let turnYawingSideDirection: TurnYawingSide
    let bodyAttitudeTrueNorth: simd_quatd
    let skiAttitudeTrueNorth: Attitude
    let skiAbsoluteFallLineAttitude: Attitude
    let bodySensorLocation: CMDeviceMotion.SensorLocation
    let skiAbsoluteAcceleration: simd_double3
    let skiTimeStampSince1970: TimeInterval
    let bodyTimeStampSince1970: TimeInterval
    let skiTurnChronologicalPhase: TurnPhaseByStartMaxEnd

//    init(skiTurnPhase: SkiTurnPhase,
//         centerOfMassTurnPhase: CenterOfMassTurnPhase
//    ) {
//        skiFallLineOrthogonalAcceleration = skiTurnPhase.orthogonalAccelerationAndRelativeAttitude.targetDirectionAcceleration
//        bodyFallLineOrthogonalAcceleration = FallLineOrthogonalAccelerationCalculato
//        skiFallLineAcceleration = skiTurnPhase.fallLineAcceleration
//        bodyFallLineAcceleration =
//                AccelerationForTargetAngle.handle(
//                        userAcceleration: centerOfMassTurnPhase.relativeAcceleration, // TODO : 絶対加速度に直すと計算量が上がりそうなのえここをどうにかする
//                        userAttitude: centerOfMassTurnPhase.relativeAttitude,
//                        targetAttitude: skiTurnPhase.absoluteFallLineAttitude
//                ).targetDirectionAcceleration
//        skiRotationRate = skiTurnPhase.rotationRate
//        turnYawingSideDirection = skiTurnPhase.turnYawingSide
//        bodyAttitudeTrueNorth = centerOfMassTurnPhase.relativeAttitude
//        skiAttitudeTrueNorth = skiTurnPhase.absoluteAttitude
//        skiAbsoluteFallLineAttitude = skiTurnPhase.absoluteFallLineAttitude
//        bodySensorLocation = centerOfMassTurnPhase.sensorLocation
//        skiAbsoluteAcceleration = skiTurnPhase.absoluteAcceleration
//        skiTimeStampSince1970 = skiTurnPhase.timeStampSince1970
//        bodyTimeStampSince1970 = centerOfMassTurnPhase.timeStampSince1970
//        skiTurnChronologicalPhase = skiTurnPhase.turnPhase
//    }

    var fallLineOrthogonalRelativeAttitude: Attitude {
        get {
            switch turnYawingSideDirection {
            case TurnYawingSide.RightYawing:
                return Attitude.init(roll: 0, yaw: AngleShifter.handle(currentAngle: skiAbsoluteFallLineAttitude.yaw, shiftAngle: (Double.pi / 2 * -1)), pitch: 0)
            case TurnYawingSide.LeftYawing:
                return Attitude.init(roll: 0, yaw: AngleShifter.handle(currentAngle: skiAbsoluteFallLineAttitude.yaw, shiftAngle: Double.pi / 2), pitch: 0)// 右９０度
            case .Straight:
                return Attitude.init(roll: 0, yaw: skiAbsoluteFallLineAttitude.yaw, pitch: 0)
            }
        }
    }

    //    {
    //        get {
    ////            AccelerationForTargetAngle.handle(
    ////                    userAcceleration: userAcceleration,
    ////                    userAttitude: attitude, targetAttitude: Attitude.init(roll: 0,
    ////                                                                          yaw: yawRotationRateMovingAverage, pitch: 0)
    ////            ).targetDirectionAcceleration
    //        }
    //    }


    //    init(movingPhaseProtocol: MovingPhaseProtocol, movingAverageYawAngle: Double,
    //         turnFinished: Bool,
    //         turnSideDirectionChanged: Bool,
    //         isTurnMax: Bool,
    //         yawRotationRateMovingAverage: Double,
    //         fallLineOrthogonalAcceleration: Double,
    //         fallLineOrthogonalRelativeAttitude: Attitude
    //    ) {
    //        self.movingAverageYawAngle = movingAverageYawAngle
    //        attitude = movingPhaseProtocol.attitude
    //        userAcceleration = movingPhaseProtocol.userAcceleration
    //        timeStampSince1970 = movingPhaseProtocol.timeStampSince1970
    //        rotationRate = movingPhaseProtocol.rotationRate
    //        self.turnFinished = turnFinished
    //        self.turnSideDirectionChanged = turnSideDirectionChanged
    //        self.isTurnMax = isTurnMax
    //        self.yawRotationRateMovingAverage = yawRotationRateMovingAverage
    //        rotationRate = movingPhaseProtocol.rotationRate
    //    }

}

extension Collection where Element == UnifiedTurnPhase {
    func filterTurnInitialize() -> [Element] {
        return self.filter{
            $0.skiTurnChronologicalPhase == TurnPhaseByStartMaxEnd.SwitchToMax
        }

    }

    func filterTurnEnd() -> [Element] {
        self.filter{
            $0.skiTurnChronologicalPhase == TurnPhaseByStartMaxEnd.MaxToSwitch
        }
    }
}
