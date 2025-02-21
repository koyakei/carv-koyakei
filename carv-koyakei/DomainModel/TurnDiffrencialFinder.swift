//
//  TurnDiffrencialFinder.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2022/10/27.
//

import Foundation
import simd
import Accelerate

struct TurnDiffrencialFinder{
    var beforeTurnSwitchedAngle: simd_quatd = simd_quatd()
    var beforebeforeTurnSwitchedAngle: simd_quatd = simd_quatd()
    var beforeTurnSwitchedUnixTime: TimeInterval = 0
    var beforebeforeTurnSwitchedUnixTime: TimeInterval = 0
    
    mutating func turnswitchedRecive(movingPhase: MovingPhase){
        beforebeforeTurnSwitchedUnixTime = beforeTurnSwitchedUnixTime
        beforeTurnSwitchedUnixTime = movingPhase.timeStampSince1970
        beforebeforeTurnSwitchedAngle = beforeTurnSwitchedAngle
        beforeTurnSwitchedAngle = movingPhase.quaternion
    }
    

    
    func idealTurnAnglePercentageByOneTurn(currentTimeDurationPercentageByOneTurn: Double)-> Double{
        sig(alpha: 2.5, x: (currentTimeDurationPercentageByOneTurn - 0.5) * 4)
    }
    

    func currentTimeDurationPercentage(currentTime: TimeInterval)-> Double{
        abs(currentTime - beforeTurnSwitchedUnixTime) / beforeTurnDiffrencialTime()
    }
    
    
    func sig(alpha: Double,x :Double)-> Double{
        (tanh(x * alpha/2) + 1)/2
    }
    
    
    func beforeTurnDiffrencialTime() -> TimeInterval {
        beforeTurnSwitchedUnixTime - beforebeforeTurnSwitchedUnixTime
    }

}
