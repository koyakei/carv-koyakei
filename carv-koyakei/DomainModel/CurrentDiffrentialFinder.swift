//
//  CurrentDiffrentialFinder.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//

struct CurrentDiffrentialFinder{
    func handle(lastTurnSwitchAngle: simd_quatf, currentQuaternion: simd_quatf) -> Float{
        return abs(QuaternionToEullerAngleDifferential.handle(base: lastTurnSwitchAngle, target: currentQuaternion).z)
    }
}
