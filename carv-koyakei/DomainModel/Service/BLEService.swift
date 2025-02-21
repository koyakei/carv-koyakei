//
//  BLService.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/12/14.
//

import Foundation
import CoreBluetooth

class BLEPeripheral : NSObject, CBPeripheralManagerDelegate {

    let CHARACTERISTIC_UUID = CBUUID(string:"D74E4C2A-4D3F-DDE6-04AD-568063771B11")
    let SERVICE_UUID = CBUUID(string:"2DFBFFFF-960D-4909-8D28-F353CB168E8A")
    let LOCAL_NAME = "⛷CARV"

    private var peripheralManager : CBPeripheralManager?
    private var characteristic: CBMutableCharacteristic
    private var ready = false

    public override init(){
        characteristic = CBMutableCharacteristic(
            type: CHARACTERISTIC_UUID,
            properties: CBCharacteristicProperties.read.union(CBCharacteristicProperties.notify),
            value:nil,
            permissions:CBAttributePermissions.readable)

        super.init()

        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    public func update(_ data: Data?) -> Bool {
        if(ready){
            if let d = data{
                characteristic.value = d
                return peripheralManager!.updateValue(d, for: characteristic, onSubscribedCentrals: nil)
            }else{
                print("data is null")
            }
        }else{
            print("not ready")
        }
        return false
    }



    /*
     CBPeripheralManagerDelegate
    */

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager){
        switch (peripheral.state){
        case .poweredOn:
            print("PeripheralManager state is ok")

            let service = CBMutableService(type: SERVICE_UUID, primary: true)
            service.characteristics = [characteristic]
            peripheralManager!.add(service)
            ready = true

        default:
            print("PeripheralManager state is ng:", peripheral.state)
            ready = false
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?){
        if(error != nil){
            print("Add Service error:", error!)
        }else{
            print("Add Service ok")
            peripheral.startAdvertising([
                CBAdvertisementDataLocalNameKey: LOCAL_NAME,
                CBAdvertisementDataServiceUUIDsKey: [SERVICE_UUID]
                ])
        }
    }

    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?){
        if(error != nil){
            print("Start Advertising error:", error!)
        }else{
            print("Start Advertising ok")
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest){
        var value: Data?
        switch request.characteristic.uuid {
        case characteristic.uuid:
            value = characteristic.value

        default: break
        }

        if let v = value{
            if (request.offset > v.count) {
                peripheral.respond(to: request, withResult: CBATTError.invalidOffset)
                print("Read fail: invalid offset")
                return;
            }

            request.value = v.subdata(
                in: Range(uncheckedBounds: (request.offset, v.count - request.offset))
            )
            peripheral.respond(to: request, withResult: CBATTError.success)
            print("Read success")
        }else{
            print("Read fail: wrong characteristic uuid:", request.characteristic.uuid)
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic){
        print("Subscribe to", characteristic.uuid)
    }
}
