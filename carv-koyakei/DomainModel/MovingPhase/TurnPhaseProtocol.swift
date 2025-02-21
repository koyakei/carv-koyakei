//
// Created by koyanagi on 2021/11/05.
//

import Foundation

protocol TurnPhaseProtocol: MovingPhaseProtocol {
    var rotationRateAverage: Double { get }
    var fallLineAcceleration: Double { get }
    var fallLineOrthogonalAcceleration: Double { get }
    var fallLineOrthogonalRelativeAttitude: Attitude { get }
}


