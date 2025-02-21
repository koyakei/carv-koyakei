//
//  内倒.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2023/09/25.
//

import Foundation
import Spatial
import simd



struct InclineCoM {
    // 西向きの１前のベクトルを設定する
    let vectorYInNroth = Vector3D(x:-1,y:0,z: 0)
    // 北を絶対値x0とするフォールライン方向
    let fallLineDirectionZVerticalXTrueNorth : Rotation3D
    // 北を絶対値z0とする現在のスキーの向きと姿勢
    let skiDirectionAbsoluteByNorth: Rotation3D
    // スキーセンターからスキーに対して垂直な重心の距離と向き
    let centerOfMassRelativeDirectionFromSki: Point3D
    
    //重力に垂直なスキーの中心からの位置　ｙはフォールライン
    var gravityAbsoluteVerticalCenterOfMassDirectionFromSki : Point3D {
        get {
            centerOfMassRelativeDirectionFromSki.rotated(by: diffOfSkiDrectionAndFallLine)
        }
    }
    
    var currentTrueNorthZVerticalCenterOfMass: Point3D {
        get{
            centerOfMassRelativeDirectionFromSki.rotated(by: skiDirectionAbsoluteByNorth)
        }
    }
    var diffOfSkiDrectionAndFallLine : Rotation3D {
        get {
            skiDirectionAbsoluteByNorth
        }
    }
    
    let ridersMass = Measurement(value: 75, unit: UnitMass.kilograms)
    
    // フォールライン方向を前原点とするスキーヤーの重心位置
    var fallLineForwardGravityAbsoluteCenterOfMass : Point3D {
        get {
            return centerOfMassRelativeDirectionFromSki.rotated(by: skiDirectionAbsoluteByNorth)
                .rotated(by: fallLineDirectionZVerticalXTrueNorth)
        }
    }
    var 谷側に倒れているラジアン角度 :  Measurement<UnitAngle>{
        get {
            Measurement(value: atan(tan(fallLineForwardGravityAbsoluteCenterOfMass.z / fallLineForwardGravityAbsoluteCenterOfMass.y)), unit: UnitAngle.radians)
            
        }
    }
    var fallLinVector: Vector3D{
        get {
            return vectorYInNroth.rotated(by: fallLineDirectionZVerticalXTrueNorth)
        }
    }
    var horizontalDirOfFallLine: Vector3D{
        get {
            Vector3D(x: fallLinVector.x, y: fallLinVector.y, z: 0)
        }
    }
    // 谷をYとした場合
    var 谷にどれだけ重心を落とせているか: Point3D {
        // fall line の水平方向を rotation3Dで表現する方法を知りたい。 フォールラインを原点方向に向けて前方向と横方向の成分をAngle2Dに入れて角度計算
        get {// 現在の重心位置 point  * fall line dire の水平 .inverse   それの　前後方向の値だけを取り出す。
            let originalDir = currentTrueNorthZVerticalCenterOfMass.rotated(by: Rotation3D(target: Point3D(horizontalDirOfFallLine), up: Vector3D.forward).inverse)
            return Point3D(x: originalDir.x, y: originalDir.y, z: originalDir.z)
        }
    }
    
    var turnYawingSide : TurnYawingSide = .Straight
//    // ステアリングアングル　フォールラインに対して何度のヨーイング角度をもっているか？
//    // 左右のターン
    var sterlingAngle : Angle2D{
        get{
            let rad = tan(fallLineForwardGravityAbsoluteCenterOfMass.x / fallLineForwardGravityAbsoluteCenterOfMass.y)
            switch turnYawingSide{
                case .LeftYawing:
                return Angle2D(radians: rad)
            case .RightYawing:
                return Angle2D(radians: -rad)
            case .Straight:
                return Angle2D.zero
            }
        }
    }
    
    // ステアリングアングルが大きい状態で谷に重心が落とせていないほど減速する
    // tan かもしれない。　考えよう。
    var 谷に落とすのに失敗していることでどれだけ板がズレて減速したがっているか : Double {
        sin(sterlingAngle) * -谷にどれだけ重心を落とせているか.y
    }
    
    private func convertU1ResultToDirCoM(direction: SIMD3<Float>) -> Point3D{
        Point3D(x: -direction.x, y: direction.y, z: -direction.z)
    }
}

