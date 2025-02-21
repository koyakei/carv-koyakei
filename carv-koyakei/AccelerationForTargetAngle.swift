//
// Created by koyanagi on 2021/11/11.
//　指定した方向への加速度と現在の姿勢からの相対角度を取得

import Foundation
import CoreMotion
import simd
struct AccelerationForTargetAngle {
    
    
    
    static func getAcceleration(userAcceleration: CMAcceleration, userAttitude: simd_quatd, targetAttitude: simd_quatd, rotation: simd_quatd = // デフォルト y軸前向き
                                simd_quatd(
        angle: Measurement(value: 90, unit: UnitAngle.degrees)
                .converted(to: .radians).value,
        axis: simd_double3(0 , 1 ,0)))-> Double{
        simd_dot(
            simd_axis(targetAttitude * simd_inverse(
                               userAttitude))
            ,
                    simd_double3(userAcceleration.x, userAcceleration.y,
                                                          userAcceleration.z)
        )
    }

    static func getMatrix(userAcceleration: CMAcceleration, userAttitude: simd_quatd, targetAttitude: simd_quatd)
                    -> simd_double3 {
  //絶対目標 -  絶対 筐体姿勢 割ると　ほんとに差が出るの？
        simd_axis(
                targetAttitude * simd_inverse(
                           userAttitude) * simd_quatd(
                angle: Measurement(value: 90, unit: UnitAngle.degrees)
                        .converted(to: .radians).value,
                axis: simd_double3(0 , 1 ,0))// y 方向
        ) *
                simd_double3(userAcceleration.x, userAcceleration.y,
                             userAcceleration.z)

    }
}



