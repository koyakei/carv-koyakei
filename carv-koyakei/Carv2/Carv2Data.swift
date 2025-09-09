//
//  Carv2Data.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/04.
//
import Foundation
import Spatial
import simd
import SwiftUI
import Combine
class Carv2Data{
    let attitude: Rotation3D
    let acceleration: SIMD3<Float>
    let angularVelocity : SIMD3<Float>
    let recordetTime: TimeInterval = Date.now.timeIntervalSince1970
    init(){
        attitude = .identity
        acceleration = .zero
        angularVelocity = .zero
    }

    // 右側　x 前上　+ 　後上ー 　左は逆
    // y  上々　＋　下下　ー
    // 右側　z 内上＋　外上ー　多分左は逆
    //
    var gravityAccel : Vector3D {
        // Rの筐体上の方向を　Yマイナス１として姿勢を正しく認識　Yが縦だからこれが正しいはず
        //前方向を植えにすると　Z　マイナス１ roll がZなのでこれも正しいはず
        // 外を植えにするとXマイナス１
        let v = Vector3D(x: 1, y: 0, z: 0).rotated(by: attitude)
        return Vector3D(x: -v.z, y: v.y, z: v.x)
    }
    
    // without gravity 左右共有
    var userAcceleration : Vector3D {
        Vector3D(gravityAccel.vector - Vector3D(acceleration).vector)
    }
    
    var leftRealityKitAngularVelocity : Vector3D {
        Vector3D(angularVelocity)
    }
    
    var 初期姿勢に対しての角速度Right : Vector3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [1.0,1.0,1.0]).normalized))
        return Vector3D.init(x: angularVelocity.x, y: angularVelocity.z, z: -angularVelocity.y).rotated(by: Rotation3D.init(simd_quatd(vector:p.matrix * attitude.vector)).rotated(by: Rotation3D(angle: Angle2D(radians: -.pi), axis: RotationAxis3D(vector: [0,1,0]))))
       
    }
    
    var 初期姿勢に対しての角速度2 : Vector3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [1.0,1.0,1.0]).normalized))
        return Vector3D.init(x: 0, y: 1, z: 0).rotated(by: Rotation3D.init(simd_quatd(vector:p.matrix * attitude.vector)).rotated(by: Rotation3D(angle: Angle2D(radians: -.pi), axis: RotationAxis3D(vector: [0,1,0]))))
    }
    
    var 初期姿勢に対しての角速度3 : Vector3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [1.0,1.0,1.0]).normalized))
        return Vector3D.init(x: 0, y: 0, z: 1).rotated(by: Rotation3D.init(simd_quatd(vector:p.matrix * attitude.vector)).rotated(by: Rotation3D(angle: Angle2D(radians: -.pi), axis: RotationAxis3D(vector: [0,1,0]))))
    }
    
    var 初期姿勢に対しての角速度4 : Vector3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [1.0,1.0,1.0]).normalized))
        return Vector3D.init(x: 1, y: 0, z: 0).rotated(by: Rotation3D.init(simd_quatd(vector:p.matrix * attitude.vector)).rotated(by: Rotation3D(angle: Angle2D(radians: -.pi), axis: RotationAxis3D(vector: [0,1,0]))))
    }
    
    var 初期姿勢に対しての角速度5 : Vector3D {
        return Vector3D.init(x: 1, y: 0, z: 0).rotated(by: attitude.inverse)
    }
    
    var 初期姿勢に対しての角速度6 : Vector3D {
        return Vector3D.init(x: 0, y: 1, z: 0).rotated(by: attitude.inverse)
    }
    
    var 初期姿勢に対しての角速度7 : Vector3D {
        return Vector3D.init(x: 0, y: 0, z: 1).rotated(by: attitude.inverse)
    }
    
    
    
    var worldAcceleration0 : Vector3D {
        let v = Vector3D(acceleration).rotated(by: attitude)
        return Vector3D(x: -v.z, y: v.y, z: v.x)
    }
    // 東西南北を固定したワールド座標系に対する加速度
    var worldAcceleration : Vector3D {
        worldAcceleration0.projected(.init(x: 1, y: 1, z: 1).rotated(by: attitude)).rotated(by: attitude)
    }
    
    var rightRealityKitRotation: Rotation3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [1.0,1.0,1.0]).normalized))
        return Rotation3D.init(simd_quatd(vector:p.matrix * attitude.vector))
//            .rotated(by: Rotation3D(angle: Angle2D(radians: .pi), axis: RotationAxis3D(vector: [0,1,0])))
    }
    
    var leftRealityKitRotation: Rotation3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [-1.0,1.0,1.0]).normalized))
        return Rotation3D.init(simd_quatd(vector: attitude.vector * p.matrix ))
            .rotated(by: Rotation3D(angle: Angle2D(radians: .pi), axis: RotationAxis3D(vector: [1,0,0])))
            .rotated(by: Rotation3D(angle: Angle2D(radians: -.pi), axis: RotationAxis3D(vector: [0,1,0])))
    }
    var rightRealityKitRotation2: Rotation3D {
        return attitude.rotated(by: Rotation3D(eulerAngles: EulerAngles(x: Angle2D(radians: .pi / 2), y: Angle2D(radians: .pi / 2), z: Angle2D(radians: .pi), order: .xyz)))
    }
    var leftRealityKitRotation2: Rotation3D {
        return attitude.rotated(by: Rotation3D(eulerAngles: EulerAngles(x: Angle2D(radians: 0), y: Angle2D(radians: 0), z: Angle2D(radians: .pi), order: .xyz)))
    }
    var leftRealityKitRotation3: Rotation3D {
        
        return attitude.rotated(by: Rotation3D(eulerAngles: EulerAngles(x: Angle2D(radians: .pi), y: Angle2D(radians: 0), z: Angle2D(radians: .pi), order: .xyz)))
    }
    
    static func floatArray(from data: Data) -> [Float] {
        let count = data.count / MemoryLayout<Float>.size
        return data.withUnsafeBytes {
            let buffer = $0.bindMemory(to: Float.self)
            return Array(buffer.prefix(count))
        }.map { $0 }
    }
    
    static private func int16ToFloat(data: Data) -> MotionSensorData {

        let intbyte :[Float] = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }.map { Float($0)/32768.0 }

        let intbyte3 : [Float] = floatArray(from: data.dropFirst(16))
//        intbyte[safe:５,default: 0] これがTimeinterval ぽいぞ　なんとか
        return MotionSensorData(attitude: Rotation3D.init(simd_quatf(vector: simd_float4(intbyte[safe:1,default: 0], intbyte[safe:2,default: 0], intbyte[safe:3,default: 0], intbyte[safe:4,default: 0]))), acceleration:  SIMD3<Float>(x: intbyte[safe:5,default: 0] * 16, y: intbyte[safe:6,default: 0]  * 16, z: intbyte[safe:7,default: 0] * 16),angularVelocity: SIMD3<Float>(x: intbyte3[safe:0,default: 0], y: intbyte3[safe:1,default: 0] , z: intbyte3[safe:2,default: 0]))
    }
    
    public init(_ data: Data) {
        let motionSensorData = Carv2Data.int16ToFloat(data: data.dropFirst(1))
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
        angularVelocity = motionSensorData.angularVelocity
    }
}

