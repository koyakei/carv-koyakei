//
//  TurnSwitchingTimingFinder.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import Foundation
import Spatial
struct TurnSwitchingTimingFinder{
    var lastTurnSiwtchedTimeInterval = Date.now.timeIntervalSince1970
    let minimumTurnPeriod : TimeInterval = 0.7
    let rotationNoizeRange: Range<Double> = (Measurement(value: -10
                                            , unit: UnitAngle.degrees)
                                    .converted(to: .radians).value)..<Measurement(value: 10
                                                                                  , unit: UnitAngle.degrees)
                                                                          .converted(to: .radians).value
    mutating func handle(zRotationAngle: Double, timeInterval : TimeInterval)-> Bool{
        if rotationNoizeRange ~= zRotationAngle
            && (Date.now.timeIntervalSince1970 - lastTurnSiwtchedTimeInterval) > minimumTurnPeriod {
            lastTurnSiwtchedTimeInterval = timeInterval
            return true
        }
        return false
    }
}
import simd

extension simd_quatd{
    var simd_quatf: simd_quatf{
        return simd.simd_quatf(
            ix: Float(self.vector.x),
            iy: Float(self.vector.y),
            iz: Float(self.vector.z),
            r: Float(self.vector.w)
        )
    }
}
