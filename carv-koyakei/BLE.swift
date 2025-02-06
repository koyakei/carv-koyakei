import CoreBluetooth
import Spatial
import Foundation

 class BLE: NSObject, ObservableObject, CBCentralManagerDelegate {
 @Published var carvDeviceList: [CarvDevice] = []
     @Published var carv2DataPair: Carv2DataPair{
         didSet {
            print(self.carv2DataPair.left.attitude)
             DispatchQueue.main.async {
                 self.objectWillChange.send()
             }
         }
     }

     func didUpdateData(_ data: Carv2DataPair) {
         DispatchQueue.main.async { [weak self] in
             self?.carv2DataPair = data
         }
     }
     
     var centralManager: CBCentralManager!
    static let targetServiceUUID = CBUUID(string: "2DFBFFFF-960D-4909-8D28-F353CB168E8A")

override init() {
    carv2DataPair = Carv2DataPair()
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
}

func scan() {
    guard centralManager.state == .poweredOn else { return }
    centralManager.scanForPeripherals(withServices: [BLE.targetServiceUUID], options: nil)
}

func retrieveAndConnect() {
    let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [BLE.targetServiceUUID])
    for peripheral in connectedPeripherals {
        addDevice(peripheral)
    }
}

    func subscribe(servece: CBService) {
        
    }
func connect(carvDevice: CarvDevice) {
    let peripheral = carvDevice.peripheral
    peripheral.delegate = carvDevice // デリゲート再設定
    centralManager.connect(carvDevice.peripheral, options: nil)
}

func disconnect(carvDevice: CarvDevice) {
    centralManager.cancelPeripheralConnection(carvDevice.peripheral)
}

private func addDevice(_ peripheral: CBPeripheral) {
    if !carvDeviceList.contains(where: { $0.id == peripheral.identifier }) {
        let newDevice = CarvDevice(peripheral: peripheral, carv2DataPair: carv2DataPair)
        DispatchQueue.main.async {
            self.carvDeviceList.append(newDevice)
        }
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
    if let device = carvDeviceList.first(where: {
        print (peripheral.name)
        return $0.peripheral.name == Carv1DataPair.periferalName || $0.peripheral.name == Carv2DataPair.periferalName
    }) {
        device.updateConnectionState(.connected)
        peripheral.discoverServices([BLE.targetServiceUUID])
        print(peripheral.name)
        print("connected")
    }
}

func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if let device = carvDeviceList.first(where: { $0.id == peripheral.identifier }) {
        device.updateConnectionState(.disconnected)
        print(peripheral.identifier)
        print("disconnected")
    }
}
}




