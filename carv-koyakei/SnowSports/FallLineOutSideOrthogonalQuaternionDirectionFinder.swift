//
// Created by koyanagi on 2021/11/25.
//

import Foundation
import simd

struct FallLineOutSideOrthogonalAttitudeFinder {
    let fallLineAttitude: Attitude
    let turnYawingSide: TurnYawingSide

    // absolute attitude
    func handle() -> Attitude {
        return Attitude.init(roll: .zero,
                             yaw:
                                fallLineAttitude.yaw + Measurement(value: Double(turnYawingSide.shiftAngle()) , unit: UnitAngle.degrees)
                                .converted(to: .radians).value,
                             pitch: .zero)
    }
}

struct FallLineOutSideOrthogonalQuaternionDirectionFinder {
    let fallLineAttitude: simd_quatd
    let turnYawingSide: TurnYawingSide

    // absolute attitude
    func handle() -> simd_quatd {
        return simd_normalize(fallLineAttitude * AngleShifter.yawRotation(Double(turnYawingSide.shiftAngle())))
    }
}
