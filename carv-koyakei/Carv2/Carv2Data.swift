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
    // ipad
//    static let rightCharactaristicUUID = UUID(uuidString: "85A29A4C-09C3-C632-858A-3387339C67CF")
//    static let leftCharactaristicUUID = UUID(uuidString:  "850D8BCF-3B03-1322-F51C-DD38E961FC1A")
    // iphone
    static let rightCharactaristicUUID = UUID(uuidString: "85E2946B-0D18-FA01-E1C9-0393EDD9013A")
    static let leftCharactaristicUUID = UUID(uuidString:  "57089C67-2275-E220-B6D3-B16E2639EFD6")
    var realityKitRotation4: Rotation3D {
        let attitude = self.attitude
        // クォータニオン取得（CM → SIMD変換）
        let cmQuat = attitude.quaternion
        let deviceQuat = simd_quatd(ix: cmQuat.vector.x,
                                    iy: cmQuat.vector.y,
                                    iz: cmQuat.vector.z,
                                    r: cmQuat.vector.w)
        return Rotation3D( deviceQuat)
    }
    
    var realityKitRotation3: Rotation3D {
        let attitude = self.attitude
        
        // クォータニオン取得（CM → SIMD変換）
        let cmQuat = attitude.quaternion
        let deviceQuat = simd_quatd(ix: cmQuat.vector.x,
                                    iy: cmQuat.vector.z,
                                    iz: cmQuat.vector.y,
                                    
                                    r: cmQuat.vector.w)
        
    return Rotation3D( deviceQuat)
        }
    var rightRealityKitRotation: Rotation3D {
        let attitude = self.attitude
        
        // クォータニオン取得（CM → SIMD変換）
        let cmQuat = attitude.quaternion
    let deviceQuat = simd_quatd(ix: cmQuat.vector.z,
                                iy: cmQuat.vector.x,
                                iz: cmQuat.vector.y,
                                r: -cmQuat.vector.w)
        
    return Rotation3D( deviceQuat)
        }
    var leftRealityKitRotation: Rotation3D {
            let attitude = self.attitude
            // クォータニオン取得（CM → SIMD変換）
            let cmQuat = attitude.quaternion
        let deviceQuat = simd_quatd(ix: -cmQuat.vector.z,
                                    iy: cmQuat.vector.x,
                                    iz: -cmQuat.vector.y,
                                    r: -cmQuat.vector.w)
        
        return Rotation3D( deviceQuat  )
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
        return MotionSensorData(attitude: Rotation3D.init(simd_quatf(ix: quatx, iy: quaty, iz: quatz, r: quatw)), acceleration:  SIMD3<Float>(x: ax, y: ay, z: az),angularVelocity: SIMD3<Float>(x: intbyte3[safe:0, default: 0], y: intbyte3[safe: 1, default: 0] , z: intbyte3[safe: 2,default: 0 ]))
    }
    public init(rightData data: Data) {
        let motionSensorData = Carv2Data.int16ToFloat(data: data)
        attitude = motionSensorData.attitude
                     acceleration = motionSensorData.acceleration
        angularVelocity = motionSensorData.angularVelocity
    }
    
    public init(leftData data: Data){
        let motionSensorData = Carv2Data.int16ToFloat(data: data)
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



