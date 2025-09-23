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

final class Carv1Data:Encodable{
    let attitude: Rotation3DFloat
    let acceleration: SIMD3<Float>
    let pressure: [Float] //= [UInt8](repeating: 0xff, count: 38)
    let rawPressure: [Float] //= [UInt8](repeating: 0xff, count: 38)
    let angularVelocity: SIMD3<Float>
    let recordedTime: Date = Date.now
    
    init(){
        attitude = .identity
        acceleration = .zero
        pressure = [Float](repeating: 0xff, count: 38)
        rawPressure = pressure
        angularVelocity = .zero
    }
    
    @MainActor init(_ data: Data, _ calibrationPressure:[Float]) {
        guard data.count >= 19 else {
            fatalError("データ長が不足しています")
        }
        
        self.rawPressure = data.subdata(in: 1..<39).withUnsafeBytes { rawBuffer in
            rawBuffer.bindMemory(to: UInt8.self).map { Float($0)}
        }
        let intbyte :[Float] = data.dropFirst(51).withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }.map { Float($0) / (Float(Int16.max) + 1) }
        pressure = zip(self.rawPressure, calibrationPressure).map { p, cp in
            p - cp
        }
        attitude = Rotation3DFloat.init(simd_quatf(vector: simd_float4(intbyte[safe:1,default: 0], intbyte[safe:2,default: 0], intbyte[safe:3,default: 0], intbyte[safe:4,default: 0])))
        acceleration = SIMD3<Float>(x: intbyte[safe:5,default: 0] * 16, y: intbyte[safe:6,default: 0]  * 16, z: intbyte[safe:7,default: 0] * 16)
        angularVelocity = SIMD3<Float>(x: intbyte[safe:8,default: 0], y: intbyte[safe:9,default: 0] , z: intbyte[safe:10,default: 0])
    }
    
}

