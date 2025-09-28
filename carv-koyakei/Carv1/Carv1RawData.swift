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
    let fordebug: [Double]
    let recordedAtFromBootDevice: TimeInterval
    
    init(){
        attitude = .identity
        acceleration = .zero
        rawPressure = [Float](repeating: 0, count: 34)
        angularVelocity = .zero
        fordebug = []
        recordedAtFromBootDevice = 0
    }
    
    @MainActor init(_ data: Data) {
        guard data.count >= 19 else {
            fatalError("データ長が不足しています")
        }
        self.rawPressure = data.subdata(in: 35..<50).withUnsafeBytes { rawBuffer in
            rawBuffer.bindMemory(to: UInt8.self).map { Float(~$0)}
        }
        let intbyte :[Float] = data.dropFirst(1)
//            .subdata(in: 2..<13)
            .withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }.map { Float($0) / (Float(Int16.max) + 1) }
        
        
        let test = data
            .subdata(in: 31..<36)
            .withUnsafeBytes {
            Array(UnsafeBufferPointer<Int32>(start: $0.baseAddress?.assumingMemoryBound(to: Int32.self), count: data.count / MemoryLayout<Int32>.stride))
        }[0]
        
        fordebug = [Double(test),Double(test) / 1000
        ]
        recordedAtFromBootDevice = Double(Float(test) / 1000)
        attitude =
        Rotation3DFloat.init(simd_quatf(vector: simd_float4(intbyte[safe:25,default: 0], intbyte[safe:26,default: 0], intbyte[safe:27,default: 0], intbyte[safe:28,default: 0])))
        acceleration = SIMD3<Float>(x: intbyte[safe:29,default: 0] * 16, y: intbyte[safe:30,default: 0]  * 16, z: intbyte[safe:31,default: 0] * 16)
        angularVelocity = SIMD3<Float>(x: intbyte[safe:32,default: 0] * .pi * 500, y: intbyte[safe:33,default: 0]  * .pi * 500, z: intbyte[safe:34,default: 0] * .pi * 500)
    }
    
}

