//
//  QuaternionToEullerAngleDiffrencial.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2022/06/09.
//

import Foundation
import SpriteKit
import SceneKit
import Spatial
struct QuaternionToEullerAngleDifferential{
    static func handle(base : Rotation3DFloat, target: Rotation3DFloat) -> Rotation3DFloat  {
        return target * base.inverse
    }
    
    static func matrixDoubleToFloat(val : simd_quatd) -> simd_quatf{
        return simd_quatf(ix: Float(val.vector.x), iy: Float(val.vector.y), iz: Float(val.vector.z), r: Float(val.vector.w) )
    }

}
