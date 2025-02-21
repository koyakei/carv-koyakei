//
//  UWBScaling.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/09/01.
//

import Foundation
import simd
import NearbyInteraction
import SceneKit
import Spatial
struct UMBScaling {
    
    let forwardFloat3 : simd_quatf = simd_quatf(Rotation3D())
    let n = SCNNode()
    // 前との角度差を計測 degreeでかえす
    func yawDiff(hipDir: simd_quatf) -> Float{
        n.simdOrientation = simd_normalize(hipDir * forwardFloat3.inverse)
        return Float(abs(Measurement(value: Double(n.eulerAngles.z), unit: UnitAngle.radians)
            .converted(to: .degrees).value))
    }
}

struct UMBDirDistance{
    let dir: simd_float3
    let distance: Float
    let timeStamp: TimeInterval
    func point()-> Point3D{
        Point3D.init(vector: Vector3D.init(dir).uniformlyScaled(by: Double(distance)).vector)
    }
}

struct hipOrientation{
    let rightHip: UMBDirDistance
    let leftHip: UMBDirDistance
    
    func yawDegreeDiffrencial() -> Double {
        return (Rotation3D(position: rightHip.point(), target: leftHip.point(),up: Vector3D.up)).angle.degrees
    }
    // 右腰と左腰の位置がわかる　それを結んだ線のヨーイング方向にを出力する
    func handle()-> Vector3D {
        (Vector3D.init(leftHip.dir).uniformlyScaled(by: Double(leftHip.distance))  -  Vector3D.init(rightHip.dir).uniformlyScaled(by: Double(rightHip.distance))).rotated(by: Rotation3D.init(angle: Angle2D(degrees: -90), axis: RotationAxis3D.z))
    }
}

struct 内倒{
    let centerOfMass: Point3D
    let centerOfPressure: Point3D
    let currentSkiDir: simd_quatf
    let fallLine: simd_quatf
    let mass = 75000 //gram
    
    //鉛直方向に起き上がった距離
//    func liftDistanceAgainstGravity()-> Float{
//        
//    }
    // グラビティーヨーイング方向だけ？　そうではないな。　斜面考慮するｋ
    func フォールラインとスキーのなす角度()-> Float{
        Float((Rotation3D.init(fallLine).inverse * Rotation3D.init(currentSkiDir)).angle.degrees)
    }
    func フォールライン方向への内倒角度と距離を計算(){
        
    }
}
