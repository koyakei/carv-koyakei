//
//  BluetoothModel.swift
//  DroggerSampleAppiOS
//
//  Copyright 2024 BizStation Corp.
//

import Foundation
@preconcurrency import CoreBluetooth
import SwiftUI
import Combine

enum ConnectionStatus: String {
    case connected = "Connected"
    case disconncected = "Disconnected"
    case scanning = "Scanning..."
    case connecting = "Connecting..."
    case error = "Error"
}

let droggerService = CBUUID(string: "0baba001-0000-1000-8000-00805f9b34fb")
let droggerSerialDataCharactaristic = CBUUID(string: "0baba002-0000-1000-8000-00805f9b34fb")
let droggerSerialWriteCharactaristic = CBUUID(string: "0baba003-0000-1000-8000-00805f9b34fb")

class DroggerBluetoothModel: NSObject, ObservableObject {
    
    var rtkDevice: RTKDevise = .shared
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var outputs: [String] = []
    var enableToUpdateOutputText = true
    @Published var peripheralStatus: ConnectionStatus = .disconncected
    @Published var deviceDetail: String = ""
    @Published var output: String = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() {
        peripheralStatus = .scanning
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func addOutput(string: String) {
        outputs.append(string)
        if (outputs.count > 40) {
            outputs.remove(at: 0)
        }
        if !enableToUpdateOutputText {
            return
        }
            self.output = self.outputs.joined(separator: "")
        
    }
}

extension DroggerBluetoothModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth powered on")
            scanForPeripherals()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover p: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralStatus = .connecting
        let name = p.name ?? "no name"
        print("Discovered \(name)")
        if !(name.starts(with: "RWS") || name.starts(with: "RZS")) {
            return
        }
        peripheral = p
        centralManager.connect(p)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect p: CBPeripheral) {
        print("Connected")
        peripheralStatus = .connected
        p.delegate = self
        p.discoverServices([droggerService])
        centralManager.stopScan()
            self.deviceDetail = String(format: "\(p.name!): \(p.identifier)")
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .disconncected
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .error
        print(error?.localizedDescription ?? "no error details")
    }
}

extension DroggerBluetoothModel: CBPeripheralDelegate {
    
    
    func peripheral(_ p: CBPeripheral, didDiscoverServices error: (any Error)?) {
        for service in p.services ?? [] {
            if service.uuid == droggerService {
                p.discoverCharacteristics([droggerSerialDataCharactaristic, droggerSerialWriteCharactaristic], for: service)
            }
        }
    }
    
    func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        for characteristic in service.characteristics ?? [] {
            p.setNotifyValue(true, for: characteristic)
            print("Found the charactaristic \(characteristic.uuid). Waiting for values")
        }
    }
    
    func peripheral(_ p: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid == droggerSerialDataCharactaristic {
            guard let data = characteristic.value else {
                print("No data received for SerialData");
                return
            }
            
            let str = String(decoding: data, as: UTF8.self)
            rtkDevice.update( str)
            //print("Data: \(str)")
            addOutput(string: str)
            return
        }
        
        if characteristic.uuid == droggerSerialWriteCharactaristic {
            print("Write characteristic");
            return
        }
        
        print("charactaristic \(characteristic.uuid) did not match.")
    }
}
