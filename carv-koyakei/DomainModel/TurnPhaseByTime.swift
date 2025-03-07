//
//  TurnPhaseByTime.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/03/07.
//
import Spatial
import Foundation

class TurnPhaseByTime {
    var lastTurnSwitchingTime: TimeInterval = 0.0
    var lastTurnTimeDuration: TimeInterval = 0.0
    
    func handle(currentTime: TimeInterval,currentAttitude:Rotation3D)-> Double {
        abs((currentTime - lastTurnSwitchingTime) / lastTurnTimeDuration)
    }
    
    func turnSwitched(currentTime: TimeInterval) {
        lastTurnTimeDuration = currentTime - lastTurnSwitchingTime
        lastTurnSwitchingTime = currentTime
    }
}
