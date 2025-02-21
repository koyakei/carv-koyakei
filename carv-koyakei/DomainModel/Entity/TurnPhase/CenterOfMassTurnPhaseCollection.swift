//
// Created by koyanagi on 2021/11/19.
//

import Foundation


extension Collection where Element == CenterOfMassTurnPhase {

    func sortedByNearSkiPhase(skiTurnPhase: SkiTurnPhase) -> [Element] {
        self.sorted(by: {
            self.nearByPhase(
                    turnPhase: skiTurnPhase,
                    centerOfMassTurnPhase1: $0, centerOfMassTurnPhase2: $1)
        })
    }

    func filterByTimeStamp(startedAt: TimeInterval, endAt: TimeInterval) -> [CenterOfMassTurnPhase] {
        self.filter {
            startedAt <= $0.timeStampSince1970
                    && $0.timeStampSince1970 <= endAt
        }
    }

    // 近くのTurnPhaseをみつけて　fall line 方向を発見　加速度を計算して変換する


    func nearByPhase(turnPhase: SkiTurnPhase,
                     centerOfMassTurnPhase1: CenterOfMassTurnPhase,
                     centerOfMassTurnPhase2: CenterOfMassTurnPhase) -> Bool {
        abs(centerOfMassTurnPhase1.timeStampSince1970 - turnPhase.timeStampSince1970) <
                abs(centerOfMassTurnPhase2.timeStampSince1970 - turnPhase.timeStampSince1970)

    }
}
