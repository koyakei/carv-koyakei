import CoreBluetooth
import Spatial
import Foundation
import SwiftUI

@MainActor
class BluethoothCentralManager: NSObject, ObservableObject, @MainActor CBCentralManagerDelegate {
    @Published var carv2DeviceLeft: CarvDevicePeripheral? = nil
    @Published var carv2DeviceRight: CarvDevicePeripheral? = nil
    
    var carv2DataPair : Carv2DataPair = Carv2DataPair.shared
    @Published var carv2AnalyzedDataPairManager: Carv2AnalyzedDataPairManager
    var centralManager: CBCentralManager!
    static let targetServiceUUID = CBUUID(string: "2DFBFFFF-960D-4909-8D28-F353CB168E8A")
    init(carv2AnalyzedDataPairManager: Carv2AnalyzedDataPairManager) {
        self.carv2AnalyzedDataPairManager = carv2AnalyzedDataPairManager
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scan() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [BluethoothCentralManager.targetServiceUUID], options: nil)
    }
    
    func retrieveAndConnect() {
        let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [BluethoothCentralManager.targetServiceUUID])
        for peripheral in connectedPeripherals {
            addDevice(peripheral)
        }
    }
    
    func subscribe(servece: CBService) {
        
    }
    func connect(carvDevice: CarvDevicePeripheral) {
        let peripheral = carvDevice.peripheral
        peripheral.delegate = carvDevice // デリゲート再設定
        centralManager.connect(carvDevice.peripheral, options: nil)
    }
    
    func disconnect(carvDevice: CarvDevicePeripheral) {
        centralManager.cancelPeripheralConnection(carvDevice.peripheral)
    }
    
    private func addDevice(_ peripheral: CBPeripheral) {
        if peripheral.identifier == Carv2DataPair.leftCharactaristicUUID{
            self.carv2DeviceLeft = CarvDevicePeripheral(peripheral: peripheral, carv2DataPair: carv2DataPair, carv2AnalyzedDataPairManager: carv2AnalyzedDataPairManager)
        }
        if peripheral.identifier == Carv2DataPair.rightCharactaristicUUID{
            self.carv2DeviceRight = CarvDevicePeripheral(peripheral: peripheral, carv2DataPair: carv2DataPair, carv2AnalyzedDataPairManager: carv2AnalyzedDataPairManager)
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            scan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        addDevice(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.identifier == carv2DeviceLeft?.peripheral.identifier{
            carv2DeviceLeft?.updateConnectionState(.connected)
            peripheral.discoverServices([BluethoothCentralManager.targetServiceUUID])
            print("connected")
        }
        
        if peripheral.identifier == carv2DeviceRight?.peripheral.identifier{
            carv2DeviceLeft?.updateConnectionState(.connected)
            peripheral.discoverServices([BluethoothCentralManager.targetServiceUUID])
            print("connected")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral.identifier == carv2DeviceLeft?.peripheral.identifier{
            carv2DeviceLeft?.updateConnectionState(.disconnected)
            print(peripheral.identifier)
            print("disconnected")
        }
        if peripheral.identifier == carv2DeviceRight?.peripheral.identifier{
            carv2DeviceRight?.updateConnectionState(.disconnected)
            print(peripheral.identifier)
            print("disconnected")
        }
    }
}

