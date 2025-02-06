//
//  BLEManager.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/01/23.
//

import CoreBluetooth

final class BLEManager: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
                case .unknown:
                    print("unknown")
                case .resetting:
                    print("resetting")
                case .unsupported:
                    print("unsupported")
                case .unauthorized:
                    print("unauthorized")
                case .poweredOff:
                    print("poweredOff")
                case .poweredOn:
                    print("poweredOn")
                @unknown default:
                    print("unknown")
                }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}
