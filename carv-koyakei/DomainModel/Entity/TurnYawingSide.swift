//
//  TurnYawingSide.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/10/03.
//

import Foundation
import SwiftData

enum TurnYawingSide : String, Codable {
    case RightYawing = "Right"
    case LeftYawing = "Left"
    case Straight = "Straight"
}

extension TurnYawingSide {
    func shiftAngle() -> Int{
        switch self {
        case .RightYawing:
            return -90
        case .LeftYawing:
            return 90  // - はこっち
        case .Straight:
            return 90
        }
    }
    
    func turnsideToSign()-> Int{
        switch self{
        case .RightYawing:
            return 1
        case .LeftYawing:
            return -1
        case .Straight:
            return 1
        }
            
    }
}
