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

extension simd_quatf{
    init (deviceQuat: simd_quatd){
        self.init(
            ix: Float(deviceQuat.axis.x),
            iy: Float(deviceQuat.axis.y),
            iz: Float(deviceQuat.axis.z),
            r: Float(deviceQuat.angle)
        )
    }
}
   
class Carv2Data {
    var attitude: Rotation3D
    var acceleration: SIMD3<Float>
    static let rightCharactaristicUUID = UUID(uuidString: "85A29A4C-09C3-C632-858A-3387339C67CF")
    static let leftCharactaristicUUID = UUID(uuidString:  "850D8BCF-3B03-1322-F51C-DD38E961FC1A")

    
    var realityKitRotation: Rotation3D {
            let attitude = self.attitude
            
            // クォータニオン取得（CM → SIMD変換）
            let cmQuat = attitude.quaternion
            var deviceQuat = simd_quatd(
                ix: attitude.vector.x,
                iy: attitude.vector.y,
                iz: attitude.vector.z,
                r: attitude.vector.w
            ).normalized
//        if deviceQuat.axis.z < 0 {
//            deviceQuat = simd_quatf(
//                    ix: Float(-cmQuat.axis.x),
//                    iy: Float(-cmQuat.axis.y),
//                    iz: Float(cmQuat.axis.z),
//                    r: Float(cmQuat.angle)
//                )
//            }
            
            // 座標系変換（Z-up → Y-up）
            let coordinateTransform = simd_quatd(angle: .pi, axis: [0, 0, 1])
            let adjustedQuat =  deviceQuat
//            // 右手系補正（必要に応じて追加）
//            let rightHandedQuat = simd_quatf(
//                ix: -adjustedQuat.vector.x,
//                iy: -adjustedQuat.vector.y,
//                iz: adjustedQuat.vector.z,
//                r: adjustedQuat.vector.w
//            )
        return Rotation3D( coordinateTransform * deviceQuat * coordinateTransform.inverse  )
        }
    static private func int16ToFloat(data: Data) -> MotionSensorData {
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
        return MotionSensorData(attitude: Rotation3D.init(simd_quatf(ix: quatx, iy: quaty, iz: quatz, r: quatw)), acceleration:  SIMD3<Float>(x: ax, y: ay, z: az))
    }
    public init(rightData data: Data) {
        let motionSensorData = Carv2Data.int16ToFloat(data: data)
        attitude = Rotation3D(quaternion: simd_quatd(ix: motionSensorData.attitude.vector.x,
                                          iy: motionSensorData.attitude.vector.y,
                                          iz: motionSensorData.attitude.vector.z,
                                          r: motionSensorData.attitude.vector.w))
                     acceleration = motionSensorData.acceleration
    }
    
    public init(leftData data: Data){
        let motionSensorData = Carv2Data.int16ToFloat(data: data)
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    private var cancellables = Set<AnyCancellable>()
    public init () {
        attitude = .identity
        acceleration = .zero
    }
}



