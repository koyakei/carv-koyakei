//
//  OneTurnDiffrentialFinder.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import simd
import Foundation

struct OneTurnDiffrentialFinder {
    var lastTurnSwitchAngle: simd_quatf = simd_quatf.init()
    var oneTurnDiffrentialEuller: Float = Float(Measurement(value: 45.0, unit: UnitAngle.degrees)
        .converted(to: .radians).value)
    
    mutating func handle(isTurnSwitched: Bool ,currentTurnSwitchAngle: simd_quatf) -> Float{
        if (isTurnSwitched){
            oneTurnDiffrentialEuller = abs(QuaternionToEullerAngleDifferential.handle(base: lastTurnSwitchAngle, target: currentTurnSwitchAngle).z)
            lastTurnSwitchAngle = currentTurnSwitchAngle
        }
        return oneTurnDiffrentialEuller
    }
}
