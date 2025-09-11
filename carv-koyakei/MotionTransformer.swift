//
//  Untitled.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/10.
//

import simd
import CoreMotion

/// モーションセンサーデータの座標変換を行うユーティリティクラス
class MotionTransformer {
    
    /// クォータニオンから回転行列を生成する
    static func rotationMatrix(from quaternion: simd_quatf) -> simd_float3x3 {
        // クォータニオンの各成分を抽出
        let x = quaternion.imag.x
        let y = quaternion.imag.y
        let z = quaternion.imag.z
        let w = quaternion.real
        
        // 回転行列の各要素を計算
        let xx = x * x
        let xy = x * y
        let xz = x * z
        let xw = x * w
        
        let yy = y * y
        let yz = y * z
        let yw = y * w
        
        let zz = z * z
        let zw = z * w
        
        // 回転行列の構築
        return simd_float3x3(
            simd_float3(1 - 2 * (yy + zz), 2 * (xy - zw), 2 * (xz + yw)),
            simd_float3(2 * (xy + zw), 1 - 2 * (xx + zz), 2 * (yz - xw)),
            simd_float3(2 * (xz - yw), 2 * (yz + xw), 1 - 2 * (xx + yy))
        )
    }
    
    /// センサーローカル座標系の加速度をワールド座標系に変換（回転行列使用）
    static func transformAccelerationToWorld(localAcceleration: simd_float3, quaternion: simd_quatf) -> simd_float3 {
        let rotMatrix = rotationMatrix(from: quaternion)
        return rotMatrix * localAcceleration
    }
    
    /// センサーローカル座標系の加速度をワールド座標系に変換（クォータニオン直接使用）
    static func transformAccelerationUsingQuaternion(localAcceleration: simd_float3, quaternion: simd_quatf) -> simd_float3 {
        // 加速度ベクトルから純粋なクォータニオンを作成
        let accelerationQuaternion = simd_quatf(real: 0, imag: localAcceleration)
        
        // 回転演算: q^-1 * a * q
        let rotatedQuaternion = quaternion.conjugate * accelerationQuaternion * quaternion
        
        // 結果のベクトル部分を抽出
        return rotatedQuaternion.imag
    }
    
    /// ワールド加速度から重力の影響を除去
    static func removeGravity(worldAcceleration: simd_float3, gravityDirection: simd_float3 = simd_float3(0, 0, -1)) -> simd_float3 {
        let normalizedGravity = simd_normalize(gravityDirection)
        let gravityMagnitude: Float = 9.81
        let gravityVector = normalizedGravity * gravityMagnitude
        
        return worldAcceleration - gravityVector
    }
}
