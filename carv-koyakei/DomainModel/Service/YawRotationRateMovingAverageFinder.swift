//
// Created by koyanagi on 2021/11/20.
//

import Foundation
import CoreMotion

struct RotationRateRecord: RotationRateRecordProtocol {
    
    let absoluteRotationRate: CMRotationRate
    let timeStampSince1970: TimeInterval
}
