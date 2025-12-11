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
    
    struct PressureWithForeAfrerWeight{
        let pressure: Float
        let foreAfrerWeight: Float// 0 が真ん中　1が一番前　-1が一番うしろ
        
        var wieghtedPressure: Float {
            pressure * foreAfrerWeight
        }
    }
    
    var pressureWithForeAfrerWeight: [PressureWithForeAfrerWeight] {
        [PressureWithForeAfrerWeight(pressure: pressure[0], foreAfrerWeight: 1),PressureWithForeAfrerWeight(pressure: pressure[1], foreAfrerWeight: 1),PressureWithForeAfrerWeight(pressure: pressure[2], foreAfrerWeight: 1)]
    }
    //0 で中間とする　pressure はオフセットがかかっているから　キャリブレーション後の変化をとれる
    var foreAfterBalanceOfPressure: Float {
        pressureWithForeAfrerWeight.map( \.wieghtedPressure).reduce(0, +) / Float(pressureWithForeAfrerWeight.count)
    }
    
    var relavantPressureMap: [Float] {
        pressure.map { $0 - (pressure.min() ?? 0) }
    }

    
    init( rawData: Carv1RawData = Carv1RawData(), pressureOffset: [Float] ){
        attitude = rawData.attitude
        acceleration = rawData.acceleration
        let zipped = zip(rawData.rawPressure, pressureOffset)
        let calibratedPressures = zipped.map { p, cp in
            p - cp
       }
        let minRawPressure = calibratedPressures.min() ?? 0
        let maxRawPressure = calibratedPressures.max() ?? 255
        let pressureFromMax = rawData.rawPressure.map {
            (maxRawPressure - $0)
        }
        
        pressure = calibratedPressures
        angularVelocity = rawData.angularVelocity
        recordedTime = rawData.recordedTime
    }
}

