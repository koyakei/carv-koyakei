//
//  SkiTurnPhaseFinder.swift
//  skiBodyAttitudeTeacheer
//
//  Created by keisuke koyanagi on 2024/10/22.
//

import Foundation

struct SkiTurnPhaseByAngleFinder{
    var lastTurnSiwtchedTimeInterval = Date.now.timeIntervalSince1970
    let minimumTurnPeriod : TimeInterval = 0.7
    let turnPaseRange: Range<Double> = 0.45..<0.55
    mutating func handle(currentTurnAnglePhasePercentage: Double , currentTimeStamp : TimeInterval)-> Bool{
        if  turnPaseRange ~= currentTurnAnglePhasePercentage && (Date.now.timeIntervalSince1970 - lastTurnSiwtchedTimeInterval) > minimumTurnPeriod {
            lastTurnSiwtchedTimeInterval = currentTimeStamp
            return true
        }
        return false
    }
}
