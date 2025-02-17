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
    // ipad
    static let rightCharactaristicUUID = UUID(uuidString: "8359EA93-4503-E6E0-4B65-65E281678DC3")
    static let leftCharactaristicUUID = UUID(uuidString:  "50556BC5-022C-57BC-6A90-9EA9EC7DACA7")
//    // iphone
//    static let rightCharactaristicUUID = UUID(uuidString: "85E2946B-0D18-FA01-E1C9-0393EDD9013A")
//    static let leftCharactaristicUUID = UUID(uuidString:  "57089C67-2275-E220-B6D3-B16E2639EFD6")
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
    
    func calibrateForce(){
        Carv1DataPair.leftCalibrationPressure = self.pressure
        Carv1DataPair.rightCalibrationPressure = self.pressure
    }
    
    public init(rightData data: Data) {
        let motionSensorData = Carv1Data.int16ToFloat(data: data)
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
        rawPressure = motionSensorData.pressures
        pressure = zip(motionSensorData.pressures, Carv1DataPair.rightCalibrationPressure).map { p, cp in
            p - cp
        }
        angularVelocity = motionSensorData.angularVelocity
        print(pressure)
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    
    public init(leftData data: Data){
        let motionSensorData = Carv1Data.int16ToFloat(data: data)
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
        pressure = zip(motionSensorData.pressures, Carv1DataPair.leftCalibrationPressure).map { p, cp in
            let (result, overflow) = cp.subtractingReportingOverflow(p)
            return overflow ? 0 : result
        }
        angularVelocity = motionSensorData.angularVelocity
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    
    public init () {
        attitude = .identity
        acceleration = .zero
    }
}


