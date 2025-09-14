//
//  DeviceRow.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/12.
//
import SwiftUI
import CoreBluetooth

struct DeviceRow: View {
    var device: CarvDevicePeripheral
    let ble: BluethoothCentralManager
    
    var body: some View {
        VStack {
            Picker("オプションを選択", selection: .constant(device.carv2PripheralSide)) {
                ForEach(Carv2PripheralSide.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            Button(action: {
                device.setUUID(device.id, device.carv2PripheralSide)
            }){
                Text("set side")
            }
        }
        VStack(alignment: .leading) {
            Text(device.id.uuidString)
                .font(.headline)
            Text("State: \(device.connectionState.rawValue)")
                .font(.subheadline)
            Text(device.peripheral.name ?? "(unknown)")
            HStack {
                Button(action: { ble.connect(carvDevice: device) }) {
                    Text("Connect")
                }
                .disabled(device.connectionState == .connected)
                
                
            }
            if !device.services.isEmpty {
                Text("Services:")
                    .font(.headline)
                
                ForEach(device.services, id: \.uuid) { service in
                    Text(service.uuid.uuidString)
                        .font(.caption)
                    Button(action: {
                        device.subscribeAttitude()
                    }) {
                        Text("Subscribe")
                    }
                    //                                .disabled(
                    //                                    device.connectionState != .connected
                    //                                )
                    
                    //                                Button(action: { device.unsubscribeAttitude() }) {
                    //                                    Text("Unsubscribe")
                    //                                }
                    //                                .disabled(device.connectionState == .connected)
                }
            }
        }
    }
}
