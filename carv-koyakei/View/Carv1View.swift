//
//  Carv1View.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/24.
//
import SwiftUI

struct Carv1View: View {
    @StateObject var dataManager: Carv1DataManager
    @StateObject var ble: Carv1BluethoothCentralManager
    var body: some View {
        VStack {
            HStack{
                VStack{
                    Text( dataManager.carvDataPair.left.angularVelocity.x.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.angularVelocity.y.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.angularVelocity.z.formatted(.number.precision(.fractionLength(1))))
                }
                VStack{
                    Text( dataManager.carvDataPair.left.acceleration.x.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.acceleration.y.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.acceleration.z.formatted(.number.precision(.fractionLength(1))))
                }
            }
            HStack{
                Button(action: { dataManager.bluethoothCentralManager.scan() }) {
                    Text("Scan")
                }
                Button(action: { dataManager.bluethoothCentralManager.retrieveAndConnect() }) {
                    Text("Retrieve and Connect")
                }
                .padding()
            }
            if let left = ble.carv1DeviceLeft{
                Carv1DeviceRow(device: left, ble: dataManager.bluethoothCentralManager)
            }
            if let right = ble.carv1DeviceRight{
                Carv1DeviceRow(device: right, ble: dataManager.bluethoothCentralManager)
            }
        }
        
        
    }
}
