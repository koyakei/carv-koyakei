//
//   MotionSensorData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//

import Foundation
import Spatial
import simd
import SwiftUI

struct MotionSensorData{
    public let attitude: Rotation3D
    public let acceleration: SIMD3<Float>
    public let angularVelocity: SIMD3<Float>
}

struct Carv1MotionSensorData{
    public let attitude: Rotation3D
    public let acceleration: SIMD3<Float>
    public let angularVelocity: SIMD3<Float>
    public var pressures: [UInt8]
}
