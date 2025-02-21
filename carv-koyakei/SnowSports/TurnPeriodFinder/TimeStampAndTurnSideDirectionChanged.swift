//
// Created by koyanagi on 2021/11/18.
//

import Foundation

struct TimeStampAndTurnSideDirectionChanged {
    let turnSideDirectionChanged: Bool
    let timeStampSince1970: Double
}

extension Collection where Element == TimeStampAndTurnSideDirectionChanged {
    func yawRotationRateDirectionChangePeriod() -> Double {
        let last2 = self.filter {
            $0.turnSideDirectionChanged == true
        }[self.count - 2...self.count - 1]
        return last2.last!.timeStampSince1970 - last2.first!.timeStampSince1970
    }
}