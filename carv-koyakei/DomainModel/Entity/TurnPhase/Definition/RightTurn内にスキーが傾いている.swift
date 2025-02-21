//
// Created by koyanagi on 2021/11/19.
//

import Foundation

struct RightTurn内にスキーが傾いている {
    static func handle(absoluteFallLineAttitude: Attitude,
                currentMovingPhase: MovingPhaseProtocol)
                    -> Bool{
        currentMovingPhase.attitude.roll > .zero // 内に倒れている
    }
}
