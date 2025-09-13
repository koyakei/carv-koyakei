//
//  TurnPhaseByTime.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/03/07.
//
import Spatial
import Foundation

class TurnPhaseByTime {
    var lastTurnSwitchingTime: TimeInterval = 0.0
    var lastTurnTimeDuration: TimeInterval = 0.0
    
    func handle(currentTime: TimeInterval)-> Double {
        abs((currentTime - lastTurnSwitchingTime) / lastTurnTimeDuration)
    }
    
    func turnSwitched(currentTime: TimeInterval) {
        lastTurnTimeDuration = currentTime - lastTurnSwitchingTime
        lastTurnSwitchingTime = currentTime
    }
}


protocol OutsideSkiRollAngle: Identifiable{
    var id : UUID {get}
    var outsideSkiRollAngle: Float {get}
    var recordetTime: TimeInterval  {get}
}


// 理想的な外足のロール角度に関して
// １００個の点を書く　それをつないでそれ以上か以下かを設定する。計算式で出せると格好がいいが、そうもいかない
// クロソイド曲線で　曲率がロール角比例とする
// わかっていること　開始時刻　終了時刻　最大ロール角度　速度がわからないのが問題では？
// ロール角度の最大に合わせて拡大縮小していくか。
//

import Foundation

struct Pose {
    let x: Double
    let y: Double
    let heading: Double // 向き（ラジアン）
}

func clothoidRadius(
    initialPose: Pose,
    finalPose: Pose,
    startTime: Double,
    endTime: Double,
    percentage: Double // 0〜100%
) -> Double {
    // パーセンテージを0-1の範囲に正規化
    let t = max(0, min(1, percentage / 100.0))
    
    // 向きの変化を計算
    var dHeading = finalPose.heading - initialPose.heading
    // -πからπの範囲に正規化
    while dHeading > .pi { dHeading -= 2 * .pi }
    while dHeading < -.pi { dHeading += 2 * .pi }
    
    // 総弧長の推定（単純な近似値）
    let dx = finalPose.x - initialPose.x
    let dy = finalPose.y - initialPose.y
    let straightLineDistance = sqrt(dx*dx + dy*dy)
    let estimatedArcLength = straightLineDistance * (1 + abs(dHeading) / 4)
    
    // クロソイドのパラメータA²を計算
    // クロソイド曲線では、τ = L²/(2A²)の関係がある
    // ここでτは角度変化、Lは弧長、Aはクロソイドパラメータ
    let A_squared = abs(dHeading) > 0 ?
        estimatedArcLength * estimatedArcLength / (2 * abs(dHeading)) :
        Double.infinity
    
    // 指定されたパーセンテージでの弧長を計算
    let arcLengthAtPercentage = estimatedArcLength * t
    
    // この弧長での半径を計算
    // クロソイド曲線では、R·L = A²なので、R = A²/L
    let radiusAtPercentage = arcLengthAtPercentage > 0 ?
        A_squared / arcLengthAtPercentage :
        Double.infinity
    
    return radiusAtPercentage
}

