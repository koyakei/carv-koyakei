//
//  SingleFinishedTurnProtocol.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/11/14.
//

import Spatial
import Foundation

protocol SingleFinishedTurn{
    init(numberOfTrun: Int, turnPhases: [SkateBoardAnalysedData])
    var numberOfTrun: Int { get  }
    var turnPhases: [SkateBoardAnalysedData] { get }
}
extension SingleFinishedTurn{
    var yawingSide: TurnYawingSide {
        switch turnPhases.map(\.angulerVelocity.z).reduce(0,+){
        case let x where x < 0:
            return .RightYawing
        case let x where x > 0:
            return .LeftYawing
        default:
            return .Straight
        }
    }
    var turnStartedTime: Date {
        turnPhases.firstPhase.timestamp
    }
    
    var turnEndedTime: Date {
        turnPhases.lastPhase.timestamp
    }
    
    var turnDuration: TimeInterval {
        turnEndedTime.timeIntervalSince(turnStartedTime)
    }
    
    var fallLineDirection: Rotation3DFloat{
        Rotation3DFloat(quaternion: turnPhases.map{ $0.attitude.quaternion}.reduce(simd_quatf(ix: 0, iy: 0, iz: 0, r: 0), +).normalized)
    }
    
    var diffrencialAngleFromStartToEnd: Angle2DFloat {
        (turnPhases.lastPhase.attitude * turnPhases.firstPhase.attitude.inverse).angle
    }
    var firstPhaseOfTune: SkateBoardAnalysedData {
        turnPhases.firstPhase
    }
    var lastPhaseOfTune: SkateBoardAnalysedData {
        turnPhases.lastPhase
    }
}

extension Array where Element == SkateBoardAnalysedData{
    
    var lastPhase: SkateBoardAnalysedData {
        self.last ?? SkateBoardAnalysedData()
    }
    
    var firstPhase: SkateBoardAnalysedData {
        self.last ?? SkateBoardAnalysedData()
    }
}
