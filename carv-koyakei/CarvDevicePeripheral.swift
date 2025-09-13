////
////  CarvDevice.swift
////  carv-koyakei
////
////  Created by keisuke koyanagi on 2025/02/01.
////
@preconcurrency import CoreBluetooth
import Spatial
import Foundation
import SwiftUI

@MainActor
class CarvDevicePeripheral: NSObject, ObservableObject, Identifiable,@MainActor CBPeripheralDelegate {
    let id: UUID
    let peripheral: CBPeripheral
    @Published var connectionState: CBPeripheralState
    @Published var services: [CBService] = []
    @Published var carv2DataPair: Carv2DataPair
    var carv2AnalyzedDataPairManager :Carv2AnalyzedDataPairManager
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
    
    func setUUID(_ uuid: UUID, _ carv2PripheralSide: Carv2PripheralSide) {
        //        self.carv2PripheralSide = carv2PripheralSide
        switch carv2PripheralSide {
        case .left:
            UserDefaults.standard.set(uuid.uuidString, forKey: "leftCarv2UUID")
        case .right:
            UserDefaults.standard.set(uuid.uuidString, forKey: "rightCarv2UUID")
        }
    }
    
    init(peripheral: CBPeripheral, carv2DataPair: Carv2DataPair,carv2AnalyzedDataPairManager: Carv2AnalyzedDataPairManager) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.connectionState = peripheral.state
        self.carv2DataPair = carv2DataPair
        self.carv2AnalyzedDataPairManager = carv2AnalyzedDataPairManager
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
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
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
        
        self.peripheral.setNotifyValue(true, for: characteristic)
        
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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
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
    
    @MainActor func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("Error updating value: \(error.localizedDescription)")
            return
        }
        if let value = characteristic.value {
            if characteristic.service?.peripheral?.name == Carv1DataPair.periferalName{
            } else if characteristic.service?.peripheral?.name == Carv2DataPair.periferalName {
                
                if peripheral.identifier == Carv2DataPair.rightCharactaristicUUID{
                    // この戻り値をCSVに出力したい。どうすればいいのか？
                    let _ = self.carv2DataPair.receive(right: Carv2Data(value))
                    
                }
                if peripheral.identifier == Carv2DataPair.leftCharactaristicUUID {
                    let _ = self.carv2DataPair.receive(left: Carv2Data(value))
                    
                }
            }
            
            
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        print("peripheral:didUpdateNotificationStateFor: \(characteristic)")
        if let error = error {
            print("error: \(error)")
        }
        print("通知状態更新: \(characteristic.isNotifying ? "有効" : "無効")")
        
    }
    
}
