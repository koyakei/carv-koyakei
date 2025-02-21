//
//  MovingPhasesProtocol.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/11/05.
//

import Foundation
import CoreMotion

protocol MovingPhaseProtocol: RotationRateRecordProtocol, AbsoluteAttitudeProtocol {
    var absoluteUserAcceleration: CMAcceleration { get }
    var sensorLocation: CMDeviceMotion.SensorLocation{get}
}

extension Collection where Element == MovingPhaseProtocol {

    func recentNSecondsFilter(seconds: Int) -> [Element] {
        self.filter {
            $0.timeStampSince1970 >
                    Calendar.current.date(
                            byAdding: .second,
                            value: Int(seconds), to: Date())!.timeIntervalSince1970
        }
    }

}
