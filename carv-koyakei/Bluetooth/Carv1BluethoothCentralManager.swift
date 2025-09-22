import CoreBluetooth
import Combine
import Spatial
import Foundation
import SwiftUI

@MainActor
class Carv1BluethoothCentralManager: NSObject, @MainActor CBCentralManagerDelegate , ObservableObject{
    
//    // ipad
//    static let rightCharactaristicUUID = UUID(uuidString: "85A29A4C-09C3-C632-858A-3387339C67CF")
//    static let leftCharactaristicUUID = UUID(uuidString:  "850D8BCF-3B03-1322-F51C-DD38E961FC1A")
    // iphone
    let rightCharactaristicUUID = UUID(uuidString:"D74E4C2A-4D3F-DDE6-04AD-568063771B11")
    let leftCharactaristicUUID = UUID(uuidString: UserDefaults.standard.string(forKey: "leftCarv2UUID") ?? "57089C67-2275-E220-B6D3-B16E2639EFD6") // UUID(uuidString:  "57089C67-2275-E220-B6D3-B16E2639EFD6")
    
    static let periferalName = "⛷CARV"
    @Published var carv1DeviceLeft: Carv1DevicePeripheral? = nil
    @Published var carv1DeviceRight: Carv1DevicePeripheral? = nil
    
    var centralManager: CBCentralManager!
    let targetDataSubscribeServiceUUID = CBUUID(string: "2DFBFFFF-960D-4909-8D28-F353CB168E8A")
    let targetDataWriteServiceUUID  = CBUUID(string: "2DFBFFFF-960D-4909-8D28-F353CB168E8A")
    override init() {
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
    
    func connect(carvDevice: Carv2DevicePeripheral) {
        let peripheral = carvDevice.peripheral
        peripheral.delegate = carvDevice
        centralManager.connect(carvDevice.peripheral, options: nil)
    }
    
    func disconnect(carvDevice: Carv2DevicePeripheral) {
        centralManager.cancelPeripheralConnection(carvDevice.peripheral)
    }
    
    private func addDevice(_ peripheral: CBPeripheral) {
        if peripheral.identifier == leftCharactaristicUUID{
            self.carv1DeviceLeft = Carv1DevicePeripheral(peripheral: peripheral)
        }
        if peripheral.identifier == rightCharactaristicUUID{
            self.carv1DeviceRight = Carv1DevicePeripheral(peripheral: peripheral)
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
        if peripheral.identifier == carv1DeviceLeft?.peripheral.identifier{
            peripheral.discoverServices([self.targetDataSubscribeServiceUUID])
            print("connected")
        }
        
        if peripheral.identifier == carv1DeviceRight?.peripheral.identifier{
            peripheral.discoverServices([self.targetDataSubscribeServiceUUID])
            print("connected")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if peripheral.identifier == carv1DeviceLeft?.peripheral.identifier{
            print(peripheral.identifier)
            print("disconnected")
        }
        if peripheral.identifier == carv1DeviceRight?.peripheral.identifier{
            print(peripheral.identifier)
            print("disconnected")
        }
    }
}

