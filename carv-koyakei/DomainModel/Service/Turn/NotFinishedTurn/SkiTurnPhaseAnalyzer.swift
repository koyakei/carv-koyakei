//
//  IdealTurnConditionDetector.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/11/01.
//

import Foundation
import CoreMotion
import simd
import SceneKit
import CoreMotion
import Spatial


extension simd_quatd {
    
    public static func + (lhs: simd_quatd, rhs: simd_quatf) -> simd_quatf{
        return simd_quatf(  lhs) + rhs
    }
    
    public static func - (lhs: simd_quatd, rhs: simd_quatf) -> simd_quatf{
        return simd_quatf(  lhs) - rhs
    }
}

extension simd_quatf {
    public init(_ val: simd_quatd){
        self.init(ix: Float(val.vector.x), iy: Float(val.vector.y), iz: Float(val.vector.z), r: Float(val.vector.w) )
    }
    
    public static func + (lhs: simd_quatf, rhs: simd_quatd) -> simd_quatf{
        return simd_quatf( rhs) + lhs
    }
    
    public static func - (lhs: simd_quatf, rhs: simd_quatd) -> simd_quatf{
        return simd_quatf( rhs) - lhs
    }
}

