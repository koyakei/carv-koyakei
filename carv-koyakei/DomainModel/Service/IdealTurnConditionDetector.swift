//
//  IdealTurnConditionDetector.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/11/05.
//

import Foundation
import CoreMotion

struct IdealTurnConditionDetector {

    func ターン前半のすべての角速度とAttitudeが理想状態に一致しているか？(turnPhase:
            MovingPhaseProtocol) -> Bool {
        let 横回転: Double = turnPhase.absoluteRotationRate.z
        let roll: Double = turnPhase.absoluteRotationRate.y
        let pitch: Double = turnPhase.absoluteRotationRate.x
        return 横回転.sign == .plus //横回転が右回りだったら、
                && roll.sign == .plus // ロール角も右に倒れていっている
                && turnPhase.attitude.roll.sign == .plus //　現在のロール角も右
                && pitch.sign == .minus// ピッチングは下っていたらマイナス増えるはず
        // ねじれバーンだと　ピッチングがかなり左右非対称になる。
    }
}
