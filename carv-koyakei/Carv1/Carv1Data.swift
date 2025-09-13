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
import SwiftUI
import Combine

public class Carv1Data {
    @MainActor var calibrationPressure = [UInt8](repeating: 0, count: 38)
    @Published var attitude: Rotation3D
    @Published var acceleration: SIMD3<Float>
    @Published var pressure: [UInt8] = [UInt8](repeating: 0xff, count: 38)
    @Published var rawPressure: [UInt8] = [UInt8](repeating: 0xff, count: 38)
    @Published var angularVelocity: SIMD3<Float> = .zero
    static func int16ToFloat(data: Data) -> Carv1MotionSensorData {
        guard data.count >= 19 else {
            fatalError("データ長が不足しています")
        }
        let pressures : [UInt8] = data.subdata(in: 1..<39).withUnsafeBytes { rawBuffer in
            rawBuffer.bindMemory(to: UInt8.self).map { UInt8($0)}
        }
        
        let intbyte :[Int16] = data.dropFirst(51).withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }
        let i = 0
        let quatx = Float(intbyte[i]) / 32768.0
        let quaty = Float(intbyte[i+1])  / 32768.0
        let quatz = Float(intbyte[i+2])  / 32768.0
        let ax = Float(intbyte[i+3])  / 32768.0  * 16 * 9.8
        let ay = Float(intbyte[i+4])  / 32768.0  * 16 * 9.8
        let az = Float(intbyte[i+5])  / 32768.0  * 16 * 9.8
        let wx = Float(intbyte[i+6])  / 32768.0
        let wy = Float(intbyte[i+7])  / 32768.0
        let wz = Float(intbyte[i+8])  / 32768.0
        
        return Carv1MotionSensorData(attitude: Rotation3D.init(eulerAngles: EulerAngles(x: Angle2D(radians: quatx), y: Angle2D(radians: quaty), z: Angle2D(radians: quatz), order: .xyz)), acceleration:  SIMD3<Float>(x: ax, y: ay, z: az), angularVelocity: SIMD3(x: wx, y: wy, z: wz), pressures: pressures)
    }
    
    @MainActor func calibrateForce(){
        calibrationPressure = self.pressure
    }
    
    @MainActor init(_ data: Data,) {
        let motionSensorData = Carv1Data.int16ToFloat(data: data)
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
        rawPressure = motionSensorData.pressures
        pressure = zip(motionSensorData.pressures, calibrationPressure).map { p, cp in
            p - cp
        }
        angularVelocity = motionSensorData.angularVelocity
        print(pressure)
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    
    public init () {
        attitude = .identity
        acceleration = .zero
    }
}

