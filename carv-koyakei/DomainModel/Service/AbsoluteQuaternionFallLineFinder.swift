//
// Created by koyanagi on 2021/11/30.
//

import Foundation
import CoreMotion
import simd

struct AbsoluteQuaternionFallLineFinder {
    struct AbsoluteQuaternionRecord: AbsoluteQuaternionProtocol {
        let quaternion: simd_quatd
        let timeStampSince1970: TimeInterval
    }

    var absoluteAttitudeRecords: [AbsoluteQuaternionRecord] = []

    mutating func handle(quaternion: simd_quatd, timeStampSince1970: TimeInterval, yawingPeriod: TimeInterval) -> simd_quatd {
        if absoluteAttitudeRecords.count > 500{
            absoluteAttitudeRecords.removeFirst()
        }
        absoluteAttitudeRecords.append(AbsoluteQuaternionRecord.init(quaternion: quaternion, timeStampSince1970: timeStampSince1970))
        return absoluteAttitudeRecords.yawYawingMovingAverage(yawingPeriod: yawingPeriod)
    }
}
