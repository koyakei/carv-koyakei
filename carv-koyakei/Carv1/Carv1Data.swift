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

struct Carv1Data:Encodable{
    let attitude: Rotation3DFloat
    let acceleration: SIMD3<Float>
    let pressure: [Float]
    let angularVelocity: SIMD3<Float>
    let recordedTime: Date
    
    var amountOfPressure: Float {
        pressure.reduce(0, +)
    }
    
    var relavantPressureMap: [Float] {
        pressure.map { $0 - (pressure.min() ?? 0) }
    }

    
    init( rawData: Carv1RawData = Carv1RawData(), pressureOffset: [Float] ){
        attitude = rawData.attitude
        acceleration = rawData.acceleration
        pressure = zip(rawData.rawPressure, pressureOffset).map { p, cp in
            p - cp
        }
        angularVelocity = rawData.angularVelocity
        recordedTime = rawData.recordedTime
    }
}

