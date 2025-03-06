//
//  Carv2Data.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/04.
//

import Foundation
import Spatial
import simd
import SwiftUICore
import Combine

   
class Carv2Data {
    // クォータニオンから回転行列への変換
    func quaternionToRotationMatrix(_ q: simd_quatf) -> matrix_float3x3 {
        let norm = simd_normalize(q)
        let x = norm.vector.x
        let y = norm.vector.y
        let z = norm.vector.z
        let w = norm.vector.w
        
        return matrix_float3x3(rows: [
            simd_float3(
                1 - 2*y*y - 2*z*z,
                2*x*y + 2*z*w,
                2*x*z - 2*y*w
            ),
            simd_float3(
                2*x*y - 2*z*w,
                1 - 2*x*x - 2*z*z,
                2*y*z + 2*x*w
            ),
            simd_float3(
                2*x*z + 2*y*w,
                2*y*z - 2*x*w,
                1 - 2*x*x - 2*y*y
            )
        ])
    }
    func convertToWorldAcceleration(sensorAccel: SIMD3<Float>,
                                   quaternion: simd_quatf) -> SIMD3<Float> {
        let rotationMatrix = quaternionToRotationMatrix(quaternion)
        let worldAccel = rotationMatrix * sensorAccel
        
        // センサー特性に応じた符号反転（必要に応じて調整）
        return SIMD3<Float>(-worldAccel.x, -worldAccel.y, -worldAccel.z)
    }
    
    var attitude: Rotation3D
    var acceleration: SIMD3<Float>
    var angularVelocity : SIMD3<Float>
    let recordetTime: TimeInterval = Date.now.timeIntervalSince1970
    var leftRealityKitAcceleration : Vector3D {
        let v = simd_dot(
            simd_quatf(from:  (simd_quatd(angle: 0, axis: [0,0,1]) * leftRealityKitRotation.quaternion
                              ).vector).axis
            ,
                simd_float3(acceleration.x, acceleration.y,
                                 acceleration.z)
        )
        return Vector3D(x: v, y: 0, z: 0)
//        Vector3D(acceleration).applying(AffineTransform3D(rotation: leftRealityKitRotation.inverse))
    }
    var leftRealityKitAngularVelocity : Vector3D {
        Vector3D(convertToWorldAcceleration(sensorAccel: acceleration, quaternion: leftRealityKitRotation.quaternion.inverse.simd_quatf))
    }
    
    var rightRealityKitRotation: Rotation3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [-1.0,-1.0,1.0]).normalized))
        return Rotation3D.init(simd_quatd(vector:p.matrix * attitude.vector)).rotated(by: Rotation3D(angle: Angle2D(radians: .pi/2), axis: RotationAxis3D(vector: [0,1,0])))
    }
    
    var leftRealityKitRotation: Rotation3D {
        let p = ProjectiveTransform3D(scale: Size3D(vector: [-1,-1,-1]),rotation: Rotation3D(simd_quatd(real: 1, imag: [-1.0,1.0,-1.0]).normalized))
        return Rotation3D.init(simd_quatd(vector:p.matrix * attitude.vector)).rotated(by: Rotation3D(angle: Angle2D(radians: .pi), axis: RotationAxis3D(vector: [1,0,0])))
    }
  
    
    static private func int16ToFloat(data: Data) -> MotionSensorData {

        let intbyte :[Int16] = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }
        let i = 0
        let quatx = Float(intbyte[i]) / 32768.0
        let quaty = Float(intbyte[i+1])  / 32768.0
        let quatz = Float(intbyte[i+2])  / 32768.0
        let quatw = Float(intbyte[i+3])  / 32768.0
        let ax = Float(intbyte[i+4])  / 32768.0  * 16 * 9.8
        let ay = Float(intbyte[i+5])  / 32768.0  * 16 * 9.8
        let az = Float(intbyte[i+6])  / 32768.0  * 16 * 9.8
                let intbyte3 : [Float] = data.dropFirst(14).withUnsafeBytes { buffer in
                    guard let baseAddress = buffer.baseAddress else { return [] }
                    let count = buffer.count / MemoryLayout<Float32>.stride
                    return [Float32](UnsafeBufferPointer(
                        start: baseAddress.bindMemory(to: Float32.self, capacity: count),
                        count: count
                    )).map { Float32($0) }
                }
        
        return MotionSensorData(attitude: Rotation3D.init(simd_quatf(vector: simd_float4(quatx, quaty, quatz, quatw))), acceleration:  SIMD3<Float>(x: ax, y: ay, z: az),angularVelocity: SIMD3<Float>(x: intbyte3[safe:0, default: 0], y: intbyte3[safe: 1, default: 0] , z: intbyte3[safe: 2,default: 0 ]))
    }
    
    public init(rightData data: Data) {
        let motionSensorData = Carv2Data.int16ToFloat(data: data.dropFirst(1))
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
        angularVelocity = motionSensorData.angularVelocity
    }
    
    public init(leftData data: Data){
        let motionSensorData = Carv2Data.int16ToFloat(data: data.dropFirst(1))
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
        angularVelocity = motionSensorData.angularVelocity
    }
    public init () {
        attitude = .identity
        acceleration = .zero
        angularVelocity = .zero
    }
}

