//
//  ResistanceCalculator.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/10/08.
//
import Spatial
struct ResistanceCalculator{
    let wheelBase : Float = 0.411
    let 車軸中心からタイヤまでの長さc : Float = 0.026 // c
    let 車軸長さl : Float = 0.09 // l
    let タイヤの半径r: Float = 0.035 // r
    let タイヤの回転平面の角度φ: Angle2D = Angle2D(degrees: -20.4) // φ　−20.4 論文の数値　自分の使っているスケボーと同じ
     // 20度最大なのでそこから小さいのを返さないようにする
    func 回転半径(_ rollAngleψ: Angle2D)-> Float{
        let d : Float = sin( Float(rollAngleψ.radians))
        let z : Float = cos(Float(タイヤの回転平面の角度φ.radians))
        let y : Float = cos(Float(rollAngleψ.radians) )
        let a : Float = (-1 * 車軸長さl) * z * d
        let b : Float = ( 車軸中心からタイヤまでの長さc + タイヤの半径r) * cos(Float(タイヤの回転平面の角度φ.radians)) * y
        let c : Float = wheelBase / 2
        return (a - b + c) / tan( Float(rollAngleψ.radians))
    }
}
