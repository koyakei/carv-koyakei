//
//  Carv1Data.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//

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

public class Carv1Data :ObservableObject{
    @Published var attitude: Rotation3D
    @Published var acceleration: SIMD3<Float>
    
    static func int16ToFloat(data: Data) -> MotionSensorData {
//        let intbyte : [Float] = data.withUnsafeBytes { rawBuffer in
//            rawBuffer.bindMemory(to: Int16.self).map { Float($0 << 16)}
//        }
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
        return MotionSensorData(attitude: Rotation3D.init(simd_quatf(ix: quatx, iy: quaty, iz: quatz, r: quatw)), acceleration:  SIMD3<Float>(x: ax, y: ay, z: az), angularVelocity: .zero)
    }
    public init(rightData data: Data) {
        let motionSensorData = Carv1Data.int16ToFloat(data: data)
        attitude = Rotation3D(quaternion: simd_quatd(ix: -motionSensorData.attitude.vector.x,
                                          iy: -motionSensorData.attitude.vector.y,
                                          iz: motionSensorData.attitude.vector.z,
                                          r: motionSensorData.attitude.vector.w))
                     acceleration = motionSensorData.acceleration
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    
    public init(leftData data: Data){
        let motionSensorData = Carv1Data.int16ToFloat(data: data)
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    
    public init () {
        attitude = .identity
        acceleration = .zero
    }
}


