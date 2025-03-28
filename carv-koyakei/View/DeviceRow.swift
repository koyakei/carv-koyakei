//
//  DeviceRow.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/12.
//
import SwiftUI

struct DeviceRow: View {
    @ObservedObject var device: CarvDevice
    let ble: BluethoothCentralManager
    
    var body: some View {
        VStack {
            Picker("オプションを選択", selection: $device.carv2PripheralSide) {
                            ForEach(Carv2PripheralSide.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
            Button(action: {
                device.setUUID(device.id, device.carv2PripheralSide)
            }){
                Text("set side")
            }
            }
        
        Text(device.carv2PripheralSide.rawValue)
        
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
