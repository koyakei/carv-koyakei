//
//  DeviceRow.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/12.
//
import SwiftUI
import CoreBluetooth

struct Carv1DeviceRow: View {
    @StateObject var device: Carv1DevicePeripheral
    let ble: Carv1BluethoothCentralManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(device.id.uuidString)
                .font(.headline)
            Text("State: \(String(describing: device.peripheral.state))")
                .font(.subheadline)
            Text(device.peripheral.name ?? "(unknown)")
            HStack {
                Button(action: { ble.connect(carvDevice: device) }) {
                    Text("Connect")
                }
                Button(action: {
                    device.subscribeAttitude()
                }) {
                    Text("Subscribe")
                }
                Button(action: {
                    device.unsubscribeAttitude()
                }) {
                    Text("unsubscribe")
                }
            }
        }
    }
}
