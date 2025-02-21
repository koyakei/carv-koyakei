//
// Created by koyanagi on 2021/11/05.
//

import Foundation
import CoreMotion
import simd

struct SkiTurnPhase : TooMuchInsideAngleFinderProtocol{
    let turnYawingSide: TurnYawingSide
    let turnSwitchingDirection: TurnSwitchingDirection
    let turnSideChangePeriod: TimeInterval
    let absoluteFallLineAttitude: simd_quatd
    let fallLineAcceleration: Double
    let orthogonalAccelerationAndRelativeAttitude: TargetDirectionAccelerationAndRelativeAttitude
    let absoluteAttitude: Attitude
    let timeStampSince1970: TimeInterval
    let absoluteAcceleration: CMAcceleration
    let rotationRate: CMRotationRate
    let fallLineAttitude: Attitude
    let turnPhaseBy100: Double
    let lastSwitchedTurnAngle : simd_quatf
    let currentAttitude: simd_quatd
    let currentVelocityToSkiTop : Double
    let yawingDiffrencialFromIdealYaw: Double // z の理想とのち外 外すぎ + 内すぎ -
    let turnPhasePercentageByTime: Double
    let currentOrthogonalVelocityRatioToStartOfTurnMinimumOrthogonalVelocity: Double
//    let beforeTurnYawDiffrencial: Double
}

struct ElapsedTimeAndV{
    let elapsedTime : Double
    let velocity: Double
}
extension Collection where Element == SkiTurnPhase{
    

    func firstAndLastTimeStamp()-> (TimeInterval,TimeInterval){
        let v = self.sorted(by:
        {$0.timeStampSince1970 > $1.timeStampSince1970}
        )
        return  (v.last?.timeStampSince1970 ?? Date.now.timeIntervalSince1970,
                      v.first?.timeStampSince1970 ?? Date.now.timeIntervalSince1970)
    }

}


