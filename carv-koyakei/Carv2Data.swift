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

struct MotionSensorData{
    public let attitude: Rotation3D
    public let acceleration: SIMD3<Float>
    public let angularVelocity: SIMD3<Float> = .zero
}
public class Carv2Data :ObservableObject{
    public var attitude: Rotation3D
    public var acceleration: SIMD3<Float>
    
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
        attitude = Rotation3D(quaternion: simd_quatd(ix: -motionSensorData.attitude.vector.x,
                                          iy: -motionSensorData.attitude.vector.y,
                                          iz: motionSensorData.attitude.vector.z,
                                          r: motionSensorData.attitude.vector.w))
                     acceleration = motionSensorData.acceleration
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    
    public init(leftData data: Data){
        let motionSensorData = Carv2Data.int16ToFloat(data: data)
        attitude = motionSensorData.attitude
        acceleration = motionSensorData.acceleration
//        print("yaw: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees), pitch: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees), roll: \(Angle2D(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
    
    public init () {
        attitude = .identity
        acceleration = .zero
    }
}

public class Carv2DataPair :ObservableObject{
    @Published public var left: Carv2Data = Carv2Data.init()
    @Published public var right: Carv2Data = Carv2Data.init()
    var yawingSide: YawingSide = .straight
    
    func signedAngleBetweenUpVectors(q1: simd_quatd, q2: simd_quatd) -> Double {
        let baseUp = simd_double3(0, 1, 0)
        let rotatedUp1 = q1.act(baseUp)
        let rotatedUp2 = q2.act(baseUp)
        
        let cross = simd_cross(rotatedUp1, rotatedUp2)
        let sign = simd_dot(cross, baseUp) >= 0 ? 1.0 : -1.0
        return sign * angleBetweenUpVectors(q1: q1, q2: q2)
    }
    func angleBetweenUpVectors(q1: simd_quatd, q2: simd_quatd) -> Double {
        // 基準の上方向ベクトル
        let baseUp = simd_double3(0, 1, 0)
        
        // 各クォータニオンで回転後の上方向ベクトルを取得
        let rotatedUp1 = q1.act(baseUp)
        let rotatedUp2 = q2.act(baseUp)
        
        // 内積から角度を計算（0〜πラジアン）
        let dot = simd_dot(rotatedUp1, rotatedUp2)
        return acos(dot)
    }
    
    var yawingDiffrencial: Double {
        return signedAngleBetweenUpVectors(q1: left.attitude.quaternion, q2: right.attitude.quaternion)
//        let angle1 = yRotationAngle(from: left.attitude.quaternion)
//        let angle2 = yRotationAngle(from: right.attitude.quaternion)
//            let delta = angle2 - angle1
//            
//            // 角度差を[-π, π)の範囲に正規化
//            return atan2(sin(delta), cos(delta))
//        let baseYAxis = simd_double3(1, 0, 0)
//
//            // 各クォータニオンで回転させたY軸ベクトルを計算
//        let yAxis1 = left.attitude.quaternion.act(baseYAxis)
//            let yAxis2 = right.attitude.quaternion.act(baseYAxis)
//
//            // ベクトルの内積から角度を計算
//            let dotProduct = simd_dot(yAxis1, yAxis2)
////            let clampedDot = min(max(dotProduct, -1.0), 1.0) // 数値誤差対策
//            return acos(dotProduct)
    }
    
    
}

enum YawingSide {
    case straight
    case left
    case right
}
