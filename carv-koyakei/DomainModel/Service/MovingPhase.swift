//
//  TurnPhase.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/10/29.
//

import Foundation
import CoreMotion
import simd

public struct AirPodMovingPhase: MovingPhaseProtocol {
    let absoluteAttitude: Attitude
    let 磁北偏差: Double
    let attitude: Attitude
    let absoluteUserAcceleration: CMAcceleration
    let timeStampSince1970: TimeInterval
    let absoluteRotationRate: CMRotationRate
    let sensorLocation: CMDeviceMotion.SensorLocation
    let timeStamp: Date

    init(_ motion: CMDeviceMotion,
         _ timeStampSince1970: TimeInterval,
         _ 磁北偏差: Double) {
        absoluteRotationRate = motion.rotationRate
        absoluteUserAcceleration = motion.userAcceleration
        self.timeStampSince1970 = timeStampSince1970
        absoluteAttitude = Attitude.init(roll: motion.attitude.roll, yaw: motion.attitude.yaw + 磁北偏差, pitch: motion.attitude.pitch)
        timeStamp = Date(timeIntervalSince1970: timeStampSince1970)
        sensorLocation = motion.sensorLocation
        attitude = Attitude.init(roll: motion.attitude.roll, yaw: motion.attitude.yaw, pitch: motion.attitude.pitch)
        self.磁北偏差 = 磁北偏差
    }
}

public struct MovingPhase: MovingPhaseProtocol {
    let attitude: Attitude
    let absoluteUserAcceleration: CMAcceleration
    let timeStampSince1970: TimeInterval
    let absoluteRotationRate: CMRotationRate
    let timeStamp: Date
    let sensorLocation: CMDeviceMotion.SensorLocation
    let quaternion: simd_quatd
    let gravity: CMAcceleration

    init(_ motion: CMDeviceMotion,
         _ timeStampSince1970: TimeInterval) {
        absoluteRotationRate = motion.rotationRate
        absoluteUserAcceleration = motion.userAcceleration
        self.timeStampSince1970 = timeStampSince1970
        attitude = Attitude.init(roll: motion.attitude.roll, yaw: motion.attitude.yaw, pitch: motion.attitude.pitch)
//        let o = simd_double3(x: motion.attitude.quaternion.x,
//                            y: motion.attitude.quaternion.y, z: motion.attitude.quaternion.z)
//        let q = simd_quatd(angle: motion.heading * -1,
//                           axis: simd_double3(x: 0,
//                                             y: 0,
//                                             z: 1))
//        let rot = q.act(o)
        quaternion = simd_quatd(ix: motion.attitude.quaternion.x,
                                iy: motion.attitude.quaternion.y,
                                iz: motion.attitude.quaternion.z,
                                r: motion.attitude.quaternion.w)
        timeStamp = Date(timeIntervalSince1970: timeStampSince1970)
        sensorLocation = motion.sensorLocation
        gravity = motion.gravity
    }
}
