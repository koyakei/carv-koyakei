//
//  OneTurnDiffrentialFinder.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import simd
import Foundation
import SceneKit
import Spatial
struct OneTurnDiffrentialFinder {
    var lastTurnSwitchAngle: Rotation3DFloat = .init()
    var oneTurnDiffrentialEuller : Float = Angle2DFloat(degrees: 45.0).radians
    
    mutating func handle(isTurnSwitched: Bool ,currentTurnSwitchAngle: Rotation3DFloat) -> Float{
        
        if (isTurnSwitched){
            oneTurnDiffrentialEuller = QuaternionToEullerAngleDifferential.handle(base: lastTurnSwitchAngle, target: currentTurnSwitchAngle).eulerAngles(order: .xyz).angles.z
            lastTurnSwitchAngle = currentTurnSwitchAngle
        }
        return oneTurnDiffrentialEuller
    }
}
