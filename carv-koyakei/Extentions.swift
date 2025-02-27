//
//  Extentions.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/04.
//
import Foundation

extension Data {
    func toFloatArray(endianness: Endianness = .big) -> [Float]? {
//        guard self.count % MemoryLayout<Float>.size == 0 else {
//            print("Invalid data size: \(self.count) bytes")
//            return nil
//        }
        
        return self.withUnsafeBytes { rawBuffer -> [Float] in
            let uint32Buffer = rawBuffer.bindMemory(to: UInt32.self)
            return uint32Buffer.map { uint32 in
                let adjusted = endianness == .little ? uint32.littleEndian : uint32.bigEndian
                return Float(bitPattern: adjusted)
            }
        }
    }
}
enum Endianness {
    case little
    case big
}

import simd
extension simd_quatd {
    var formatQuaternion: String {
        let components = [self.real, self.imag.x, self.imag.y, self.imag.z]
        
        let rounded = components.map { value in
            String(format: "%.1f", round(value * 10) / 10)  // 四捨五入処理
        }
        
        return """
        simd_quatd(
            real: \(rounded[0]),
            ix: \(rounded[1]),
            iy: \(rounded[2]),
            iz: \(rounded[3])
        )
        """
    }
}

import SwiftUICore
extension simd_quatf {
    init(from double4: SIMD4<Double>) {
        self.init(
            ix: Float(double4.x),
            iy: Float(double4.y),
            iz: Float(double4.z),
            r: Float(double4.w)
        )
    }
    func getSignedAngleBetweenQuaternions2( q2: simd_quatf) -> Double {
        let dotProduct = simd_dot(self.vector, q2.vector)
        let angle = 2 * acos(min(abs(dotProduct), 1.0))
        let degree = Angle(radians: Double(angle)).degrees
        return dotProduct < 0 ? -degree : degree
    }
    
    func getSignedAngleBetweenQuaternions( q2: simd_quatf) -> Float {
        // 各クオータニオンで回転後のベクトルを取得
        let v1 = self.act(simd_float3(-1, 0, 0)) // 左右のブーツでｘ軸の向きが真逆なので、
        let v2 = q2.act(simd_float3(1, 0, 0))
        
        // YZ平面への投影
        let proj1 = simd_float3(0, v1.y, v1.z)
        let proj2 = simd_float3(0, v2.y, v2.z)
        
        // 正規化
        let norm1 = simd_normalize(proj1)
        let norm2 = simd_normalize(proj2)
        
        // ゼロベクトルチェック
        if norm1 == .zero || norm2 == .zero {
            return 0
        }
        
        // 内積と外積計算
        let dot = simd_dot(norm1, norm2)
        let cross = simd_cross(norm1, norm2)
        
        // 角度計算（符号付き）
        let angleRad = atan2(cross.x, dot)
        let angleDeg = angleRad * (180 / .pi)
        
        // 角度を-180°～180°に正規化
        return angleDeg.truncatingRemainder(dividingBy: 360) - (angleDeg > 180 ? 360 : 0) + (angleDeg < -180 ? 360 : 0)
    }
}

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
