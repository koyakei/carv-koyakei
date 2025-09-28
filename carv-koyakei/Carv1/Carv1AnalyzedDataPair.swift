//
//  Carv1Data.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//

//
//  Untitled.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//
import Foundation
import Observation
import Spatial
import simd
import SwiftUI

class Carv1AnalyzedDataPair: Encodable{
    let left: Carv1Data
    let right: Carv1Data
    
    let recordetTime: Date
    let isTurnSwitching: Bool
    
    let percentageOfTurnsByAngle: Float
    let percentageOfTurnsByTime: TimeInterval
    
    
    init(left: Carv1RawData = .init(), right: Carv1RawData = .init(), recordetTime: Date = Date.now, isTurnSwitching: Bool = false, percentageOfTurnsByAngle: Float = 0, percentageOfTurnsByTime: TimeInterval = 0, leftPressureOffset: [Float] =  [Float](repeating: 0, count: 23), rightPressureOffset: [Float] = [Float](repeating: 0, count: 23)) {
        self.left = Carv1Data(rawData: left, pressureOffset: leftPressureOffset)
        self.right = Carv1Data(rawData: right, pressureOffset: rightPressureOffset)
        self.recordetTime = recordetTime
        self.isTurnSwitching = isTurnSwitching
        self.percentageOfTurnsByAngle = percentageOfTurnsByAngle
        self.percentageOfTurnsByTime = percentageOfTurnsByTime
    }
    
    
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
    
    var outsideSki: Carv1Data {
        if yawingSide == .LeftYawing {
            return left
        } else {
            return right
        }
    }
    
    var insideSki: Carv1Data {
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
    var rollingAngulerRateDiffrential: Float { Float(right.angularVelocity.x + left.angularVelocity.x)}
    var 外足荷重されているか: Bool {
        switch yawingSide {
        case .LeftYawing, .RightYawing:
            return outsideSki.amountOfPressure > insideSki.amountOfPressure
        case .Straight:
            return true
        }
    }
}


