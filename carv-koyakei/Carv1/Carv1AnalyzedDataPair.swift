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

struct Carv1AnalyzedDataPair:Encodable {
    var left: Carv1Data
    var right: Carv1Data
    
    var recordetTime: Date
    var isTurnSwitching: Bool
    
    var percentageOfTurnsByAngle: Float
    var percentageOfTurnsByTime: TimeInterval
    
    init(left: Carv1Data = .init(), right: Carv1Data = .init(), recordetTime: Date = Date.now, isTurnSwitching: Bool = false, percentageOfTurnsByAngle: Float = 0, percentageOfTurnsByTime: TimeInterval = 0) {
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
    // ローリングの方向を　realitykit 用の変換コードを一つの行列変換で表現したやつを掛けて揃えなきゃいけないんだけど、やってない。
    // ここでサボると加速度の変換がおかしなことになる。
    var rollingAngulerRateDiffrential: Float { Float(right.angularVelocity.x + left.angularVelocity.x)}
}


