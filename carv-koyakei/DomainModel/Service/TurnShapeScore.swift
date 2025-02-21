//
//  TurnShapeScore.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2022/10/26.
//

import Foundation
struct IdealYawingDegreeOfTurn{
    
    let oneTurnDiffrencialAngle: Double
    let oneTurnTimeDurationSinceStartOfTurn: TimeInterval
    /**
    理想の角度を計算
     */
    func idealDegree(timeIntervalSinceStartOfTurn: TimeInterval)-> Double{
        oneTurnDiffrencialAngle / oneTurnTimeDurationSinceStartOfTurn * timeIntervalSinceStartOfTurn
    }
}

protocol ActualPhaseDegreeProtocol{
    var timeIntervalSinceStartOfTurn: TimeInterval{ get}
    var actualDiffrencialAngleSinceStartOfTurn: Double{ get}
}

struct ActualPhaseDegree: ActualPhaseDegreeProtocol{
    let timeIntervalSinceStartOfTurn: TimeInterval
    let actualDiffrencialAngleSinceStartOfTurn: Double
}


struct YawingShapeScore {
    let actualPhaseDegreeList: [ActualPhaseDegree]
    let oneTurnDiffrencial: Double
    let oneTurnTimeDuration: TimeInterval
    
    func handle() -> Double{
        let idealYawing = IdealYawingDegreeOfTurn(oneTurnDiffrencialAngle: oneTurnDiffrencial
                                                           , oneTurnTimeDurationSinceStartOfTurn: oneTurnDiffrencial)
        return TurnScore(phaseDegreeCollection: actualPhaseDegreeList
                  , idealYawingDegreeOfTurn: idealYawing,
                  turnPhaseDegrees: actualPhaseDegreeList.map{
            (
                TurnPhaseDegree(idealDiffrencialAngleFromStartOfTurn: idealYawing.idealDegree(timeIntervalSinceStartOfTurn: $0.timeIntervalSinceStartOfTurn),
                                timeIntervalSinceStartOfTurn: $0.timeIntervalSinceStartOfTurn , actualDiffrencialAngleSinceStartOfTurn: $0.actualDiffrencialAngleSinceStartOfTurn)
            )
        }).handle()
    }
}

struct TurnScore{
    let phaseDegreeCollection: [ActualPhaseDegreeProtocol]
    let idealYawingDegreeOfTurn: IdealYawingDegreeOfTurn
    let turnPhaseDegrees : [TurnPhaseDegree]
    func handle() -> Double{
        turnPhaseDegrees.diffrencial() / Double(phaseDegreeCollection.count) * idealYawingDegreeOfTurn.oneTurnDiffrencialAngle / 2
    }
}

struct TurnPhaseDegree : TurnPhaseDegreeProtocol{
    let idealDiffrencialAngleFromStartOfTurn: Double
    let timeIntervalSinceStartOfTurn: TimeInterval
    let actualDiffrencialAngleSinceStartOfTurn: Double
}

protocol TurnPhaseDegreeProtocol : ActualPhaseDegreeProtocol{
    var idealDiffrencialAngleFromStartOfTurn: Double{ get }
}

// 検査間隔に依存しない指標にするには？ 総数合計を　裁判個数と diffrencal /2 で割ると 100 が最大になる
extension Collection where Element: TurnPhaseDegreeProtocol{
    func diffrencial() -> Double {
        self.map{
            abs($0.idealDiffrencialAngleFromStartOfTurn - $0.actualDiffrencialAngleSinceStartOfTurn)
        }.reduce(0,+)
    }
}
