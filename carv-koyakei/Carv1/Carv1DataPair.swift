//
//  Carv1Data.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//

//
//  Untitled.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//
import Foundation
import Observation
import Spatial
import simd
import SwiftUI

@MainActor
struct Carv1DataPair {
    let left : Carv1Data
    let right : Carv1Data
    let recordedTime : Date
    
    init(left: Carv1Data, right: Carv1Data) {
        self.left = left
        self.right = right
        self.recordedTime = left.recordedTime > right.recordedTime ? left.recordedTime : right.recordedTime
    }
    
    var unitedAttitude : Rotation3DFloat {
        Rotation3DFloat.slerp(from: left.attitude, to: right.attitude, t: 0.5)
    }
    var unitedYawingAngle : Float {
        left.angularVelocity.y + right.angularVelocity.y
    }
    var yawingAngulerRateDiffrential: Float { Float(right.angularVelocity.y - left.angularVelocity.y)}
    // ここでサボると加速度の変換がおかしなことになる。
    var rollingAngulerRateDiffrential: Float { Float(right.angularVelocity.x + left.angularVelocity.x)}

}

