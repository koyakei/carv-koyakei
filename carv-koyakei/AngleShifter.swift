//
// Created by koyanagi on 2021/11/11.
//　180 to -180　の範囲内で角度を変更
// 170 + 20  =  -170  になる

import Foundation
import simd
struct AngleShifter {

    static func handle(currentAngle: Double, shiftAngle: Double)-> Double{
        let shiftedAngle = (currentAngle + shiftAngle)
        switch shiftedAngle{
        case Double.pi...Double.infinity:
            return Double.pi + (shiftedAngle - Double.pi)
        case (Double.infinity * -1)...(-1 * Double.pi):
            return Double.pi + (shiftedAngle + Double.pi)
        default:
            return shiftedAngle
        }
    }
    
    static func yawRotation(_ degree: Double) -> simd_quatd {
        simd_quatd(
                angle: Measurement(value: degree, unit: UnitAngle.degrees)
                        .converted(to: .radians).value,
                axis: simd_double3(x: 0, y: 1, z: 0))
    }
}
