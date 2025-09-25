//
//  Carv1RawDataPair.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/25.
//
import Foundation
import Spatial

struct Carv1RawDataPair {
    let left: Carv1RawData
    let right: Carv1RawData
    let recordedDate: Date
    init(left: Carv1RawData = .init(), right: Carv1RawData = .init(), recordedDate: Date = Date.now) {
        self.left = left
        self.right = right
        self.recordedDate = recordedDate
    }
    var unitedAttitude : Rotation3DFloat {
        Rotation3DFloat.slerp(from: left.attitude, to: right.attitude, t: 0.5)
    }
    var unitedYawingAngle : Float {
        left.angularVelocity.y + right.angularVelocity.y
    }
}
