//
// Created by koyanagi on 2021/11/19.
//

import Foundation

struct RightTurn前半Phase {
    static func handle(absoluteFallLineAttitude: Attitude,
                currentMovingPhase: MovingPhaseProtocol)
                    -> Bool{
        // これらを一度でも満たして、 なおかつangle がターンマックスを過ぎたら
        RightTurn内にスキーが傾いている.handle(absoluteFallLineAttitude:
                         absoluteFallLineAttitude,
                         currentMovingPhase:
                         currentMovingPhase) &&
                RightTurn前半スキーが内にロールしていっている.handle(absoluteFallLineAttitude:
                                   absoluteFallLineAttitude,
                                   currentMovingPhase:
                                   currentMovingPhase)

    }
}
