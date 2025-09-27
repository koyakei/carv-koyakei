//
//  MotionController.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/10.
//
import simd
import CoreMotion

class MotionController {
    private let motionManager = CMMotionManager()
    
    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("デバイスモーションを利用できません")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60Hz更新
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (deviceMotion, error) in
            guard let deviceMotion = deviceMotion, error == nil else {
                print("エラー: \(error?.localizedDescription ?? "不明なエラー")")
                return
            }
            
            self?.processMotionData(deviceMotion)
        }
    }
    
    private func processMotionData(_ deviceMotion: CMDeviceMotion) {
        // センサーからの加速度データを取得（単位：m/s²）
        let localAcceleration = simd_float3(
            Float(deviceMotion.userAcceleration.x) * 9.81,
            Float(deviceMotion.userAcceleration.y) * 9.81,
            Float(deviceMotion.userAcceleration.z) * 9.81
        )
        
        // CoreMotionのクォータニオンをsimd_quatfに変換
        let orientationQuaternion = simd_quatf(
            real: Float(deviceMotion.attitude.quaternion.w),
            imag: simd_float3(
                Float(deviceMotion.attitude.quaternion.x),
                Float(deviceMotion.attitude.quaternion.y),
                Float(deviceMotion.attitude.quaternion.z)
            )
        )
        
        // 加速度をワールド座標系に変換
        let worldAcceleration = MotionTransformer.transformAccelerationToWorld(
            localAcceleration: localAcceleration,
            quaternion: orientationQuaternion
        )
        
        print("ローカル加速度: \(localAcceleration)")
        print("ワールド加速度: \(worldAcceleration)")
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}


