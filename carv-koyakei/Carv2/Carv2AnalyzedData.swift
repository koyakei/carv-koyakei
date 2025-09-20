//
//  Carv2AnalyzedData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import Spatial
import Foundation


struct Carv2AnalyzedDataPair:Encodable {
    var left: Carv2Data
    var right: Carv2Data
    
    var recordetTime: Date
    var isTurnSwitching: Bool
    
    var percentageOfTurnsByAngle: Float
    var percentageOfTurnsByTime: TimeInterval
    
    init(left: Carv2Data = .init(), right: Carv2Data = .init(), recordetTime: Date = Date.now, isTurnSwitching: Bool = false, percentageOfTurnsByAngle: Float = 0, percentageOfTurnsByTime: TimeInterval = 0) {
        self.left = left
        self.right = right
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
    // ローリングの方向を　realitykit 用の変換コードを一つの行列変換で表現したやつを掛けて揃えなきゃいけないんだけど、やってない。
    // ここでサボると加速度の変換がおかしなことになる。
    var rollingAngulerRateDiffrential: Float { Float(right.angularVelocity.x + left.angularVelocity.x)}
}
