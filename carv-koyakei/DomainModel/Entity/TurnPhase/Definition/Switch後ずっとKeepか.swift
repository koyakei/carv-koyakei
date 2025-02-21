//
// Created by koyanagi on 2021/11/19.
//

import Foundation

struct Switch後ずっとKeepか {
    var lastPhase: TurnSwitchingDirection = TurnSwitchingDirection.Keep
    var isPureTurning: Bool = false

    mutating func handle(now: TurnSwitchingDirection) -> Bool {
        // turn switch が来て そのあとずっと keep ならずっと同じターンしてますよ
        // turn switchのあとkeep 以外に来ていないかどうか？ TODO: よく考える
        if now == .Keep {
            isPureTurning = true
        }
        lastPhase = now
        return isPureTurning
    }
}