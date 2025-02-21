//
// Created by koyanagi on 2021/11/19.
//

import Foundation

struct RightTurn前半スキーが内にロールしていっている {
    static func handle(absoluteFallLineAttitude: Attitude,
                currentMovingPhase: MovingPhaseProtocol)
                    -> Bool{
        currentMovingPhase.absoluteRotationRate.y > .zero // rpll
//        右に倒れていく

    }
}
