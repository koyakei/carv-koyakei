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
    @Published var carv2DataPair: Carv2DataPair = Carv2DataPair.shared
    init(peripheral: CBPeripheral, carv2DataPair: inout Carv2DataPair) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.connectionState = peripheral.state
        self.carv2DataPair = carv2DataPair
        super.init()
        self.peripheral.delegate = self
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
            // ここで受信したデータを処理します
                let data1 = value.dropFirst(51)
    //            print(data1.map{String(format: "%02hhx", $0)}.joined())
                notificationHandler(data: data1)
        } else if characteristic.service?.peripheral?.name == Carv2DataPair.periferalName {
            let data1 = value.dropFirst(1)
            if peripheral.identifier == Carv2Data.rightCharactaristicUUID{
                DispatchQueue.main.async {
                    Carv2DataPair.shared.right = Carv2Data(rightData: data1)
                }
            }
            if peripheral.identifier == Carv2Data.leftCharactaristicUUID {
                DispatchQueue.main.async {
                    Carv2DataPair.shared.left = Carv2Data(leftData: data1)
                }
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
    
    private func notificationHandler(data: Data) {
            guard data.count >= 9 else { print("less 9")
                return }
            let intbyte :[Int16] = data.withUnsafeBytes {
                Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
            }
            let i = 0
            let quatx = Float(intbyte[i]) / 32768.0
            let quaty = Float(intbyte[i+1])  / 32768.0
            let quatz = Float(intbyte[i+2])  / 32768.0
            let quatw = Float(intbyte[i+3])  / 32768.0
            let ax = Float(intbyte[i+4])  / 32768.0  * 16 * 9.8
            let ay = Float(intbyte[i+5])  / 32768.0  * 16 * 9.8
            let az = Float(intbyte[i+6])  / 32768.0  * 16 * 9.8
        let rotation2 = Rotation3D.init(simd_quatf(ix: Float(intbyte[i+7])  / 32768.0, iy: Float(intbyte[i+8])  / 32768.0, iz: Float(intbyte[i+9])  / 32768.0, r: Float(intbyte[i+10])  / 32768.0))
        print("roll: \(Angle2D(radians: rotation2.eulerAngles(order: .xyz).angles.x).degrees), yaw: \(Angle2D(radians: rotation2.eulerAngles(order: .xyz).angles.y).degrees), pitch: \(Angle2D(radians: rotation2.eulerAngles(order: .xyz).angles.z).degrees)" )
        }
    

    private func carv2dataHandler(data: Data) {
        guard data.count >= 24 else { print("less 24")
            return }
        let intbyte :[Int16] = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Int16>(start: $0.baseAddress?.assumingMemoryBound(to: Int16.self), count: data.count / MemoryLayout<Int16>.stride))
        }
        let i = 0
        let quatx = Float(intbyte[i]) / 32768.0
        let quaty = Float(intbyte[i+1])  / 32768.0
        let quatz = Float(intbyte[i+2])  / 32768.0
        let quatw = Float(intbyte[i+3])  / 32768.0
        let ax = Float(intbyte[i+4])  / 32768.0  * 16 * 9.8
        let ay = Float(intbyte[i+5])  / 32768.0  * 16 * 9.8
        let az = Float(intbyte[i+6])  / 32768.0  * 16 * 9.8
        let quatx2 = Float(intbyte[i+7]) / 32768.0
        let quaty2 = Float(intbyte[i+8])  / 32768.0
        let quatz2 = Float(intbyte[i+9])  / 32768.0
        let quatw2 = Float(intbyte[i+10])  / 32768.0
        let ax2 = Float(intbyte[i+11])  / 32768.0
        let ay2 = Float(intbyte[i+12])  / 32768.0
        let az2 = Float(intbyte[i+13])  / 32768.0
        let rotation = Rotation3D.init(simd_quatf(ix: quatx, iy: quaty, iz: quatz, r: quatw))
        let rotation2 = Rotation3D.init(simd_quatf(ix: Float(intbyte[i+8])  / 32768.0, iy: Float(intbyte[i+9])  / 32768.0, iz: Float(intbyte[i+10])  / 32768.0, r: Float(intbyte[i+11])  / 32768.0))
//        print("ax: \(quatx2), ay: \(quatx2), az: \(quatx2), quatw: \(quatw2),ax: \(ax2), ay: \(ay2), az: \(az2)")
        print("ax: \(ax2), ay: \(ay2), az: \(az2), roll: \(Angle2D(radians: rotation.eulerAngles(order: .xyz).angles.x).degrees), yaw: \(Angle2D(radians: rotation.eulerAngles(order: .xyz).angles.y).degrees), pitch: \(Angle2D(radians: rotation.eulerAngles(order: .xyz).angles.z).degrees)" )
//        print("ax: \(ax2), ay: \(ay2), az: \(az2), roll: \(Angle2D(radians: rotation2.eulerAngles(order: .xyz).angles.x).degrees), yaw: \(Angle2D(radians: rotation2.eulerAngles(order: .xyz).angles.y).degrees), pitch: \(Angle2D(radians: rotation2.eulerAngles(order: .xyz).angles.z).degrees)" )
    }
}
