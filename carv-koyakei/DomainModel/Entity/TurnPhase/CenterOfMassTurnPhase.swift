//
// Created by koyanagi on 2021/11/18.
//

import Foundation
import CoreMotion

struct CenterOfMassTurnPhase {
    let turnYawingSide: TurnYawingSide
    let turnSwitchingDirection: TurnSwitchingDirection
    let turnSideChangePeriod: TimeInterval
    let absoluteFallLineAttitude: Attitude
    let turnPhase: TurnPhaseByStartMaxEnd
    let fallLineOrthogonalAccelerationAndRelativeAttitude:
            TargetDirectionAccelerationAndRelativeAttitude
    let relativeAcceleration: CMAcceleration // 磁北偏差を直さない
    let timeStampSince1970: TimeInterval
    let relativeAttitude: Attitude
    let 磁北偏差: Double
    let fallLineAcceleration: Double
    let rotationRate: CMRotationRate
    let sensorLocation: CMDeviceMotion.SensorLocation
}
