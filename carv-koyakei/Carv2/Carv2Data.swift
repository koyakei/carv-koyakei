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
extension Array {
    subscript(safe index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index >= 0, index < endIndex else {
            return defaultValue()
        }
        return self[index]
    }
}
extension simd_quatf{
    init (deviceQuat: simd_quatd){
        self.init(
            ix: Float(0),
            iy: Float(-deviceQuat.axis.y),
            iz: Float(deviceQuat.axis.z),
            r: Float(deviceQuat.angle)
        )
    }
}
   
class Carv2Data {
    var attitude: Rotation3D
    var acceleration: SIMD3<Float>
    var angularVelocity : SIMD3<Float>
    let recordetTime: TimeInterval = Date.now.timeIntervalSince1970
  
    var realityKitRotation4: Rotation3D {
        let attitude = self.attitude
        let cmQuat = attitude.quaternion
        let deviceQuat = simd_quatd(ix: -cmQuat.vector.z,
                                    iy: -cmQuat.vector.x,
                                    iz: -cmQuat.vector.y,
                                    r: cmQuat.vector.w).normalized
    return Rotation3D( deviceQuat)
    }
    
    var realityKitRotation3: Rotation3D {
        let attitude = self.attitude.invertXYRotation().rotated(by: Rotation3D(angle: Angle2D(degrees: 180), axis: RotationAxis3D(x: 0, y: 1, z: 0)))
        let cmQuat = attitude.quaternion
            var modifiedQuat = cmQuat
        
        let deviceQuat = simd_quatd(ix: modifiedQuat.vector.z,
                                    iy: -modifiedQuat.vector.x,
                                    iz: modifiedQuat.vector.y,
                                    r: modifiedQuat.vector.w).normalized
        
    return Rotation3D(deviceQuat)
        }
    var rightRealityKitRotation: Rotation3D {
        let attitude = self.attitude
        let cmQuat = attitude.quaternion
        let deviceQuat = simd_quatd(ix: cmQuat.vector.z,
                                    iy: -cmQuat.vector.x,
                                    iz: cmQuat.vector.y,
                                    r: cmQuat.vector.w).normalized
    return Rotation3D( deviceQuat).rotated(by: Rotation3D(angle: Angle2D(degrees: -90), axis: RotationAxis3D(x: 0, y: 1, z: 0)))
    }
    var leftRealityKitRotation: Rotation3D {
        let attitude = self.attitude
        let cmQuat = attitude.quaternion
        let deviceQuat = simd_quatd(ix: cmQuat.vector.z,
                                    iy: -cmQuat.vector.x,
                                    iz: cmQuat.vector.y,
                                    r: cmQuat.vector.w).normalized
    return Rotation3D( deviceQuat)
        }
    
//                                        x: cmQuat.imag.z, y: -cmQuat.imag.y, z: -cmQuat.imag.x)
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
        attitude = motionSensorData.attitude.invertXYRotation().rotated(by: Rotation3D(angle: Angle2D(degrees: 180), axis: RotationAxis3D(x: 0, y: 1, z: 0)))
        acceleration = motionSensorData.acceleration
        angularVelocity = motionSensorData.angularVelocity
    }
    
    public init(leftData data: Data){
        let motionSensorData = Carv2Data.int16ToFloat(data: data.dropFirst(1))
       
        attitude = motionSensorData.attitude
            
        acceleration = motionSensorData.acceleration
        angularVelocity = motionSensorData.angularVelocity
    }
    private var cancellables = Set<AnyCancellable>()
    public init () {
        attitude = .identity
        acceleration = .zero
        angularVelocity = .zero
    }
}



extension Rotation3D {
    func invertXYRotation() -> Rotation3D {
        var modifiedQuat = self.quaternion
        modifiedQuat.vector.x *= -1  // X軸回転反転
        modifiedQuat.vector.y *= -1  // Y軸回転反転
        modifiedQuat.vector.z *= -1
        modifiedQuat.vector.w *= -1
        return Rotation3D(modifiedQuat.normalized)
    }
}
