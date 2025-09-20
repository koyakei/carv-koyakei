//
//  Carv2AnalyzedData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import Spatial
import Foundation


struct Carv2AnalyzedDataPair {
    var left: Carv2Data
    var right: Carv2Data
    
    var recordetTime: Date
    var isTurnSwitching: Bool
    
    var percentageOfTurnsByAngle: Float
    var percentageOfTurnsByTime: TimeInterval
    
    var yawingSide: TurnYawingSide {
        get{
            switch unitedYawingAngle {
            case -.infinity..<Float(Angle2D(degrees: -1).radians):
                return TurnYawingSide.RightYawing
            case Float(Angle2D(degrees: 1).radians)...Float.infinity:
                return TurnYawingSide.LeftYawing
            default:
                return TurnYawingSide.Straight
            }
        }
    }
    var outsideSkiRollAngle: Float {
        return outsideSki.rollAngle + Float(Angle2D(degrees: 90).radians)
    }
    
    var outsideSki: Carv2Data {
        if yawingSide == .LeftYawing {
            return left
        } else {
            return right
        }
    }
    
    var insideSki: Carv2Data {
        if yawingSide == .RightYawing {
            return right
        } else {
            return left
        }
    }
    
    var unitedAttitude : Rotation3DFloat {
        Rotation3DFloat.slerp(from: left.attitude, to: right.attitude, t: 0.5)
    }
    var unitedYawingAngle : Float {
        left.angularVelocity.y + right.angularVelocity.y
    }
    var yawingAngulerRateDiffrential: Float { Float(right.angularVelocity.y - left.angularVelocity.y)}
    var unifiedDiffrentialAttitudeFromLeftToRight: Rotation3DFloat {
        left.attitude.inverse * right.attitude
    }
}
