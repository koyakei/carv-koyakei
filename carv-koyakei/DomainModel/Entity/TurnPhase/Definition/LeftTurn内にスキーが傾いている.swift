//
// Created by koyanagi on 2021/11/19.
//

import Foundation

struct LeftTurn内にスキーが傾いている {
    static func handle(absoluteFallLineAttitude: Attitude,
                       currentMovingPhase: MovingPhaseProtocol)
                    -> Bool{
        !RightTurn内にスキーが傾いている.handle(absoluteFallLineAttitude:
                         absoluteFallLineAttitude, currentMovingPhase: currentMovingPhase)
    }
}
