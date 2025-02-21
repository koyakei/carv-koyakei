//
// Created by koyanagi on 2021/11/19.
//

import Foundation

struct RightTurn後半Phase {
    static func handle(absoluteFallLineAttitude: Attitude,
                       currentMovingPhase: MovingPhaseProtocol)
                    -> Bool{
        // これらを一度でも満たして、 なおかつangle がターンマックスを過ぎたら
        RightTurn内にスキーが傾いている.handle(absoluteFallLineAttitude:
                         absoluteFallLineAttitude,
                         currentMovingPhase:
                         currentMovingPhase) &&
                RightTurn後半スキーのロール角が起き上がってきている.handle(absoluteFallLineAttitude:
                                   absoluteFallLineAttitude,
                                   currentMovingPhase:
                                   currentMovingPhase)
    }
}
