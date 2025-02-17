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
        
        if (device.id == Carv2Data.leftCharactaristicUUID || device.id == Carv2Data.leftCharactaristicUUID){
            Text("Left")
        }
        if (device.id == Carv2Data.rightCharactaristicUUID || device.id == Carv2Data.rightCharactaristicUUID){Text("Right")}
        VStack(alignment: .leading) {
            Text(device.id.uuidString)
                .font(.headline)
            Text("State: \(device.connectionState.rawValue)")
                .font(.subheadline)
            Text(device.peripheral.name ?? "(unknown)")
//            Text(device.carv2DataPaird.right.attitude.description)
            HStack {
                Button(action: { ble.connect(carvDevice: device) }) {
                    Text("Connect")
                }
                .disabled(device.connectionState == .connected)
                
                
                if let service = device.services.first {
                    Button(action: { ble.subscribe(servece: service) }) {
                        Text("Subscribe")
                    }
                }
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
