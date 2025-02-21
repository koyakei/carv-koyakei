//
//  運動量測定.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/09/25.
//

import Foundation
import Spatial
// 垂直方向にかかる力を計算する
// 内外差に対して
struct MeasureRidersMedicalActivity {
    
    let centerOfMassAtiitude: Rotation3D // vertical up にする？
    var skierRelativeAcceleration: Vector3D  // 001 z 上で１が鉛直 y 1 が前
    var centerOfMassRelativeAcceleration: Vector3D
    var centerOfMassAbsoluteAcceleration: Vector3D {
        get {
            skierRelativeAcceleration.rotated(by: centerOfMassAtiitude)
        }
    }
    
    let ridersMass : Double  = 75000 // gram
    var relativeDirectionFromCenterOfMassToSKi: Vector3D = Vector3D.up
    var absoluteDirectionFromCenterOfMassToSKi: Vector3D{
        get {
            relativeDirectionFromCenterOfMassToSKi.rotated(by: centerOfMassAtiitude)
        }
    }
    
    // Zを取り出せば垂直方向の加速度
    var accelerationOfCenterOfMassToSkiInCoMToSkiVertical: Vector3D {
        get{
            centerOfMassAbsoluteAcceleration.rotated(by:
                        Rotation3D(forward: absoluteDirectionFromCenterOfMassToSKi, // 重心からスキーへ
                                   up: -Vector3D.forward // 下向きのベクトル
                                  )
            )
        }
    }
    
}
// 1 ターンとか長い期間出だしていく仮説を表現してみよう
