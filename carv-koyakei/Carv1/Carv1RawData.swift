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
    let acceleration: SIMD3<Float>
    let rawPressure: [Float]
    let angularVelocity: SIMD3<Float>
    let recordedTime: Date = Date.now
    
    init(){
        attitude = .identity
        acceleration = .zero
        rawPressure = [Float](repeating: 0, count: 32)
        angularVelocity = .zero
    }
    
    @MainActor init(_ data: Data) {
        guard data.count >= 19 else {
            fatalError("データ長が不足しています")
        }
        
        
        self.rawPressure = data.subdata(in: 32..<68).withUnsafeBytes { rawBuffer in
            rawBuffer.bindMemory(to: UInt8.self).map { Float($0)}
        }
        let intbyte :[Float] = data
//            .subdata(in: 2..<70)
            .withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }.map { Float($0) / (Float(Int16.max) + 1) }
        
        attitude = Rotation3DFloat.init(simd_quatf(vector: simd_float4(intbyte[safe:1,default: 0], intbyte[safe:2,default: 0], intbyte[safe:3,default: 0], intbyte[safe:4,default: 0])))
        acceleration = SIMD3<Float>(x: intbyte[safe:5,default: 0] * 16, y: intbyte[safe:6,default: 0]  * 16, z: intbyte[safe:7,default: 0] * 16)
        angularVelocity = SIMD3<Float>(x: intbyte[safe:8,default: 0], y: intbyte[safe:9,default: 0] , z: intbyte[safe:10,default: 0])
    }
    
}

