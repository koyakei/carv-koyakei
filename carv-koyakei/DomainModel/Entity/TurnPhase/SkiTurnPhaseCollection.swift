//
// Created by koyanagi on 2021/11/19.
//

import Foundation
extension Collection where Element == SkiTurnPhase {

//    func filterLastTurnSwitchToTurnMax() -> [SkiTurnPhase] {
//        self.filter {
////            self.filter {
////                $0.turnSideDirectionChanged == true
////            }.last!.timeStampSince1970 < $0.timeStampSince1970
////                    && $0.timeStampSince1970 < self.filter {
////                $0.isTurnMax == true
////            }.last!.timeStampSince1970
//        }
//    }

    // ターンマックスのときにこれを使う
    // 今ターンマックス
    // 最後のターンマックスからもう一つ前のターンマックスから最後の切り替えまで
//    func filterLastTurnMaxToTurnSwitchWhenPhaseIsTurnMax() -> [SkiTurnPhase] {
//        self.filter {
//            self.filter {
//                $0.isTurnMax == true
//            }[self.count - 2].timeStampSince1970 < $0.timeStampSince1970
//                    && $0.timeStampSince1970 < self.filter {
//                $0.turnSideDirectionChanged == true
//            }.last!.timeStampSince1970
//        }
//    }
}