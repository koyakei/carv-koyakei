//
//  Carv2AnalyzedData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import Spatial
import Foundation

struct Carv2AnalyzedData {
    var attitude: Rotation3D
    var acceleration: SIMD3<Float>
    var angularVelocity : SIMD3<Float>
    let recordetTime: TimeInterval = Date.now.timeIntervalSince1970
    let turnPercentageByAngle: Float // 100%
//    let turnNumber: Int
}

struct Carv2AnalyzedDataPair {
    let left: Carv2AnalyzedData
    let right: Carv2AnalyzedData
}
