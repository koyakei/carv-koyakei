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

@MainActor
class DroggerBluetoothModel: NSObject, ObservableObject, CBCentralManagerDelegate  {
    
    @Published var rtkDevice: RTKPeripheral? = nil
    private var centralManager: CBCentralManager!
    private var outputs: [String] = []
    var enableToUpdateOutputText = true
    var peripheralStatus: ConnectionStatus = .disconncected
    var deviceDetail: String = ""
    var output: String = ""
    
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
        self.rtkDevice = RTKPeripheral(peripheral: p)
        centralManager.connect(p)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect p: CBPeripheral) {
        print("Connected")
        peripheralStatus = .connected
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
