//
// Created by koyanagi on 2021/11/05.
// CMAttitude が init できないので

import Foundation

protocol AttitudeProtocol{
    var roll: Double {get}
    var yaw: Double{get}
    var pitch: Double{get}
}
struct Attitude : AttitudeProtocol{
    let roll: Double
    let yaw: Double
    let pitch: Double
}
