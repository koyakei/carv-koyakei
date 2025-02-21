//
// Created by koyanagi on 2021/11/18.
//

import Foundation

// ターンの前半後半って　スキーとの相対加速度で決まってくるのかな
// スキーのヨーイングのターン前半後半
// 横方向の加速度が　スキー > 重心　　スキー＜重心　なのかの区別して　その２要素で判定するのがいいのかな
// 重心側の前半後半で考える場合があるか？　早すぎる最適化か？　ピボットスリップ　アウトサイド　前後　カービング　リープ　サウザンドステップ
// どれも前半後半だけだな
// 重心の横移動方向の符号では区別できないだろう。スキーの横への相対速度に影響されすぎる
// ターン前半を長くとるにはどうすればいいのか？　ターンマックスの定義をずらすか。
struct OneTurn {
    let oneUnifiedTurnInitiation: [UnifiedTurnPhase]
    let oneUnifiedTurnEnd: [UnifiedTurnPhase]
}
