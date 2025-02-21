//
// Created by koyanagi on 2021/11/25.
//

import Foundation
import CoreMotion
import simd

struct FallLineOrthogonalAccelerationCalculator{
    // 絶対　north true absolute fallLine
    // absoluteUserAttitude true north
    // userAcceleration も absolute
    static func handle(
        absoluteFallLineAttitude: Attitude,
        absoluteFallLineQuaternion: simd_quatd,
                       turnYawingSide : TurnYawingSide,
                       userAcceleration: CMAcceleration,
                       userQuaternion: simd_quatd,
        userAttitude: Attitude
    ) -> TargetDirectionAccelerationAndRelativeAttitude{
        let targetQAttitude = FallLineOutSideOrthogonalQuaternionDirectionFinder.init(fallLineAttitude: absoluteFallLineQuaternion, turnYawingSide: turnYawingSide).handle()
        let targetAttitude : Attitude = FallLineOutSideOrthogonalAttitudeFinder.init(fallLineAttitude: absoluteFallLineAttitude, turnYawingSide: turnYawingSide).handle()
        return TargetDirectionAccelerationAndRelativeAttitude.init(targetDirectionAcceleration: AccelerationForTargetAngle.getAcceleration(userAcceleration: userAcceleration,                                                        userAttitude: userQuaternion, targetAttitude: targetQAttitude, rotation: simd_quatd(
            angle: Measurement(value: Double(turnYawingSide.shiftAngle()), unit: UnitAngle.degrees)
                    .converted(to: .radians).value,
            axis: simd_double3(1 , 0 ,0))
                       ), relativeQuaternion: targetQAttitude, attitude: targetAttitude)
    }
}

struct TargetDirectionAccelerationAndRelativeAttitude {
    let targetDirectionAcceleration: Double
    let relativeQuaternion: simd_quatd // 実は絶対を返している
    let attitude: Attitude
}
