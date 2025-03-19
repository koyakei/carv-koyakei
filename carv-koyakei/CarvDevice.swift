////
////  CarvDevice.swift
////  carv-koyakei
////
////  Created by keisuke koyanagi on 2025/02/01.
////
import CoreBluetooth
import Spatial
import Foundation
import SwiftUI

class CarvDevice: NSObject, ObservableObject, Identifiable, CBPeripheralDelegate {
    let id: UUID
    let peripheral: CBPeripheral
    @Published var connectionState: CBPeripheralState
    @Published var services: [CBService] = []
    @Published var carv2DataPair: Carv2DataPair
    @Published var carv1DataPair: Carv1DataPair = Carv1DataPair.shared
    var carv2AnalyzedDataPairManager = Carv2AnalyzedDataPairManager.init()

    @Published var carv2PripheralSide: Carv2PripheralSide = .right {
        didSet{
            switch carv2PripheralSide {
                case .left:
                    UserDefaults.standard.set(id.uuidString, forKey: "leftCarv2UUID") // device.carv2PripheralSideを　picker から変更してもここが動かない
                case .right:
                    UserDefaults.standard.set(id.uuidString, forKey: "rightCarv2UUID")
            }
        }
    }
    
    init(peripheral: CBPeripheral, carv2DataPair: Carv2DataPair) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.connectionState = peripheral.state
        self.carv2DataPair = carv2DataPair
        super.init()
        self.peripheral.delegate = self
        //　UserDefaults.standard.string(forKey: "leftCarv2UUID")　が空だった場合、現在の値を代入
        
        if let uuidString = UserDefaults.standard.object(forKey: "leftCarv2UUID"){
            if let uuid =  UUID(uuidString: uuidString as! String) {
                if id == uuid {
                    carv2PripheralSide = .left
                }
            } else {
                UserDefaults.standard.set(id.uuidString, forKey: "leftCarv2UUID")
            }
        }
        
        if let uuidString = UserDefaults.standard.object(forKey: "rightCarv2UUID"){
            if let uuid =  UUID(uuidString: uuidString as! String) {
                if id == uuid {
                    carv2PripheralSide = .right
                }
            } else {
                UserDefaults.standard.set(id.uuidString, forKey: "rightCarv2UUID")
            }
        }
    }
    
    // 特性発見メソッドを実装
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("特性発見エラー: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("発見された特性: \(characteristic.uuid)")
        }
    }
    
    func updateConnectionState(_ state: CBPeripheralState) {
        DispatchQueue.main.async {
            self.connectionState = state
        }
    }
    
    func subscribeAttitude() {
        guard let characteristic = findCharacteristic(periferalName: peripheral.name!) else {
            print("Characteristic not found")
            return
        }
        
        // 通知サポートチェックを追加
        guard characteristic.properties.contains(.notify) else {
            print("Characteristic does not support notifications")
            return
        }
        
        // 非同期処理を追加
        DispatchQueue.global(qos: .userInitiated).async {
            self.peripheral.setNotifyValue(true, for: characteristic)
        }
        print("Subscribe initiated")
    }

func unsubscribeAttitude() {
    guard let characteristic = findCharacteristic(periferalName: peripheral.name!) else { return }
    peripheral.setNotifyValue(false, for: characteristic)
}

    private func findCharacteristic(periferalName : String) -> CBCharacteristic? {
        guard let service = peripheral.services?.first(where: { $0.peripheral?.name == periferalName }) else {
        print("no service")
        return nil }
    return service.characteristics?.first
}

// MARK: - CBPeripheralDelegate

func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let error = error {
                print("Error discovering services: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.services = peripheral.services ?? []
            }
            
            for service in peripheral.services ?? [] {
                peripheral.discoverCharacteristics(nil, for: service)
            }
}

func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
        print("Error updating value: \(error.localizedDescription)")
        return
    }
    
    if let value = characteristic.value {
        if characteristic.service?.peripheral?.name == Carv1DataPair.periferalName{
            if peripheral.identifier == Carv2DataPair.rightCharactaristicUUID {
                Carv1DataPair.shared.right  = Carv1Data(rightData: value)
            }
            if peripheral.identifier == Carv2DataPair.leftCharactaristicUUID {
                Carv1DataPair.shared.left  = Carv1Data(leftData: value)
            }
        } else if characteristic.service?.peripheral?.name == Carv2DataPair.periferalName {
            
            if peripheral.identifier == Carv2DataPair.rightCharactaristicUUID{
                     // この戻り値をCSVに出力したい。どうすればいいのか？
                carv2AnalyzedDataPairManager.receive(data: self.carv2DataPair.receive(right: Carv2Data(value)))
                
            }
            if peripheral.identifier == Carv2DataPair.leftCharactaristicUUID {
                carv2AnalyzedDataPairManager.receive(data:self.carv2DataPair.receive(left: Carv2Data(value)) )
                
            }
        }
        
        
    }
}
        public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
                print("peripheral:didUpdateNotificationStateFor: \(characteristic)")
                if let error = error {
                    print("error: \(error)")
                }
            print("通知状態更新: \(characteristic.isNotifying ? "有効" : "無効")")
                
            }

}


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

/// 実際にCore Motionを使用する例
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



