//
//  Carv1View.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/24.
//
import SwiftUI

struct Carv1View: View {
    @StateObject var dataManager: Carv1DataManager
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
        }
        if let left = dataManager.bluethoothCentralManager.carv1DeviceLeft{
            Carv1DeviceRow(device: left, ble: dataManager.bluethoothCentralManager)
        }
        if let right = dataManager.bluethoothCentralManager.carv1DeviceRight{
            Carv1DeviceRow(device: right, ble: dataManager.bluethoothCentralManager)
        }
    }
}
