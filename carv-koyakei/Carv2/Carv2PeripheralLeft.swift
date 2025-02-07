//
//  Carv2Peripheral.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/07.
//
import Foundation
import CoreBluetooth
import SwiftUI
import Spatial

class Carv2PeripheralLeft:NSObject, Identifiable, ObservableObject,CBPeripheralDelegate {
    let id: UUID
    let peripheral: CBPeripheral
    static let charactaristicUUID = UUID(uuidString:  "850D8BCF-3B03-1322-F51C-DD38E961FC1A")
    @Published var carv2Data: Carv2Data = Carv2Data()
    @Published var rotation3D: Rotation3D = .identity
    @Published var connectionState: CBPeripheralState
    init(peripheral: CBPeripheral) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.connectionState = peripheral.state
        super.init()
        self.peripheral.delegate = self
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value: \(error.localizedDescription)")
            return
        }
        if let value = characteristic.value {
//            if characteristic.service?.peripheral?.name == Carv2DataPair.periferalName && characteristic{
//                let data1 = value.dropFirst(1)
//                carv2Data = Carv2Data(leftData: data1)
//                rotation3D = carv2Data.attitude
//            }
        }
    }
}
