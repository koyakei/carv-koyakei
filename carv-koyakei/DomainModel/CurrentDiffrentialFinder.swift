//
//  CurrentDiffrentialFinder.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import simd
import SceneKit
import Spatial
struct CurrentDiffrentialFinder{
    func handle(lastTurnSwitchAngle: Rotation3DFloat, currentQuaternion: Rotation3DFloat) -> Float{
        return abs(QuaternionToEullerAngleDifferential.handle(base: lastTurnSwitchAngle, target: currentQuaternion).eulerAngles(order: .xyz).angles.y)
    }
}
