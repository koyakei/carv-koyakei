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

final class Carv1RawData:Encodable{
    let attitude: Rotation3DFloat
    //重力の影響を除いた加速度
    let acceleration: SIMD3<Float>
    let rawPressure: [Float]
    let angularVelocity: SIMD3<Float>
    let recordedTime: Date = Date.now
    let fordebug: [Float]
    let recordedAtFromBootDevice: TimeInterval
    let debugString: String
    init(){
        attitude = .identity
        acceleration = .zero
        rawPressure = [Float](repeating: 0, count: 34)
        angularVelocity = .zero
        fordebug = []
        recordedAtFromBootDevice = 0
        debugString = ""
    }
    
    @MainActor init(_ data: Data) {
        guard data.count >= 19 else {
            fatalError("データ長が不足しています")
        }
        self.rawPressure = data.subdata(in: 35..<51).withUnsafeBytes { rawBuffer in
            rawBuffer.bindMemory(to: UInt8.self).map { Float(~$0)}
        }
        let intbyte :[Float] = data.dropFirst(1)
//            .subdata(in: 2..<13)
            .withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }.map { Float($0) / (Float(Int16.max) + 1) }
        
        
        let test = data.subdata(in: 35..<63).withUnsafeBytes { rawBuffer in
            rawBuffer.bindMemory(to: UInt8.self).map { Int($0)}
        }
        // 各バイトを16進数2桁の文字列に変換し連結
        let hexString = test.map { String(format: "%02X", $0) }.joined()
        debugString = hexString
        // 16進数1桁ずつ文字列から整数に変換し配列化
        let hexDigitsAsInts = hexString.compactMap { Float(Int(String($0), radix: 16) ?? 0 )}
        
//        let calibrated = test.map {Float($0) - (test.min() ?? 0)  }
        fordebug = Carv1RawData.splitDataInto3BitArray(data: data.subdata(in: 35..<63)).map{Float($0)}
        recordedAtFromBootDevice = Double(Float(255 - (test.min() ?? 0) ))
        attitude =
        Rotation3DFloat.init(simd_quatf(vector: simd_float4(intbyte[safe:25,default: 0], intbyte[safe:26,default: 0], intbyte[safe:27,default: 0], intbyte[safe:28,default: 0])))
        acceleration = SIMD3<Float>(x: intbyte[safe:29,default: 0] * 16, y: intbyte[safe:30,default: 0]  * 16, z: intbyte[safe:31,default: 0] * 16)
        angularVelocity = SIMD3<Float>(x: intbyte[safe:32,default: 0] * .pi * 500, y: intbyte[safe:33,default: 0]  * .pi * 500, z: intbyte[safe:34,default: 0] * .pi * 500)
    }
    
    static func splitDataInto3BitArray(data: Data) -> [UInt8] {
        var bitBuffer: UInt64 = 0
        var bitCount = 0
        var result = [UInt8]()

        for byte in data {
            bitBuffer = (bitBuffer << 8) | UInt64(byte)
            bitCount += 8

            while bitCount >= 3 {
                let shift = bitCount - 3
                let value = UInt8((bitBuffer >> shift) & 0b111)
                result.append(value)
                bitCount -= 3
                bitBuffer &= (1 << bitCount) - 1
            }
        }

        // 残りのビットがあれば3ビットに満たなくても追加
        if bitCount > 0 {
            let value = UInt8(bitBuffer << (3 - bitCount))
            result.append(value)
        }

        return result
    }

}

