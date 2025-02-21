//
// Created by koyanagi on 2021/11/19.
//

import Foundation

struct LeftTurn後半Phase {
    static func handle(absoluteFallLineAttitude: Attitude,
                       currentMovingPhase: MovingPhaseProtocol)
                    -> Bool {
        // これらを一度でも満たして、 なおかつangle がターンマックスを過ぎたら
        LeftTurn内にスキーが傾いている.handle(absoluteFallLineAttitude:
                                   absoluteFallLineAttitude,
                                   currentMovingPhase:
                                   currentMovingPhase) &&
                LeftTurn前半内にロールしていっている.handle(absoluteFallLineAttitude:
                                              absoluteFallLineAttitude,
                                              currentMovingPhase:
                                              currentMovingPhase)

    }
}
