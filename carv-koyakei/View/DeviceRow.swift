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
                Button(action: {
                    device.subscribeAttitude()
                }) {
                    Text("Subscribe")
                }
            }
        }
    }
}
