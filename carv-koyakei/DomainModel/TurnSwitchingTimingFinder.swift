//
//  TurnSwitchingTimingFinder.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import Foundation
import Spatial
import SwiftUI
import Combine
class TurnSwitchingTimingFinder:ObservableObject{
    let minimumTurnPeriod : TimeInterval = 0.4
    let rotationNoizeRange : Range<Float> = Angle2DFloat(degrees: -15).radians..<Angle2DFloat(degrees: 15).radians
    
    func handle(zRotationAngle: Float, timeInterval : TimeInterval,currentFrameTime: TimeInterval ,lastTurnSiwtchedTimeInterval : TimeInterval)-> Bool{
        rotationNoizeRange ~= zRotationAngle
            && (currentFrameTime - lastTurnSiwtchedTimeInterval) > minimumTurnPeriod
    }
}
