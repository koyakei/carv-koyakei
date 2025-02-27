//
//  TurnSideChangingPeriodFinder.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/27.
//
import Foundation

struct TurnSideChangingPeriodFinder {
    var lastSwitchedTurnSideTimeStamp: TimeInterval = Date.now.timeIntervalSince1970
    

    mutating func handle
    (currentTimeStampSince1970: TimeInterval, isTurnSwitching: Bool) -> TimeInterval {
        let period = currentTimeStampSince1970 - lastSwitchedTurnSideTimeStamp
       if (isTurnSwitching)  {
            lastSwitchedTurnSideTimeStamp = currentTimeStampSince1970
        }
        return period
    }
}
