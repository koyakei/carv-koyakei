//
// Created by koyanagi on 2021/11/19.
//

import Foundation
import CoreMotion
import Spatial
extension CMRotationRate {
    var yawingSide: TurnYawingSide {
        get{
            switch z {
            case -.infinity..<Angle2D(degrees: -1).radians:
                return TurnYawingSide.RightYawing
            case Angle2D(degrees: 1).radians...Double.infinity:
                return TurnYawingSide.LeftYawing
            default:
                return TurnYawingSide.Straight
            }
        }
    }
}
