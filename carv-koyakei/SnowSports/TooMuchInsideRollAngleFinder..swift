//
//  TooMuchInsideRollAngleFinder..swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/12/10.
//

import Foundation
import CoreMotion

protocol TooMuchInsideAngleFinderProtocol{
    var rotationRate: CMRotationRate {get}
    var turnYawingSide: TurnYawingSide {get}
}

