//
//  Carv1View.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/24.
//
import SwiftUI
import Spatial
import Foundation

struct Carv1View: View {
    @StateObject var dataManager: Carv1DataManager
    @StateObject var ble: Carv1BluethoothCentralManager
    var body: some View {
        ScrollView {
            let gridItems = Array(repeating: GridItem(.flexible()), count: 5)
            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach(dataManager.carvRawDataPair.right.fordebug.indices, id: \.self) { i in
                    Grid{
                        Text("\(i.description)  \(dataManager.carvRawDataPair.right.fordebug[i].formatted(FloatingPointFormatStyle<Float>.number.precision(.fractionLength(1))))")
                    }
                }
                .padding()
            }
        }
        VStack {
            HStack {
                
                VStack{
                    Text("記録開始時からの時間経過　\(dataManager.carvRawDataPair.left.recordedAtFromBootDevice)")
                    Text( dataManager.carvDataPair.left.angularVelocity.x.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.angularVelocity.y.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.angularVelocity.z.formatted(.number.precision(.fractionLength(1))))
                    
                    Text( dataManager.carvDataPair.left.acceleration.x.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.acceleration.y.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.left.acceleration.z.formatted(.number.precision(.fractionLength(1))))
                }
                VStack{
                    Text( dataManager.carvDataPair.right.angularVelocity.x.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.right.angularVelocity.y.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.right.angularVelocity.z.formatted(.number.precision(.fractionLength(1))))
                    
                    Text( dataManager.carvDataPair.right.acceleration.x.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.right.acceleration.y.formatted(.number.precision(.fractionLength(1))))
                    Text( dataManager.carvDataPair.right.acceleration.z.formatted(.number.precision(.fractionLength(1))))
                }
            }
            
            HStack{
                VStack{
                    Text(
                        String(
                            Int(
                                Angle2DFloat(radians:
                                                dataManager.carvDataPair.left.attitude.eulerAngles(order: .xyz).angles.x
                                            ).degrees)
                        )
                    )
                    Text(
                        String(
                            Int(
                                Angle2DFloat(radians:
                                                dataManager.carvDataPair.left.attitude.eulerAngles(order: .xyz).angles.y
                                            ).degrees)
                        )
                    )
                    Text(
                        String(
                            Int(
                                Angle2DFloat(radians:
                                                dataManager.carvDataPair.left.attitude.eulerAngles(order: .xyz).angles.z
                                            ).degrees)
                        )
                    )
                }
                VStack{
                    Text(
                        String(
                            Int(
                                Angle2DFloat(radians:
                                                dataManager.carvDataPair.right.attitude.eulerAngles(order: .xyz).angles.x
                                            ).degrees)
                        )
                    )
                    Text(
                        String(
                            Int(
                                Angle2DFloat(radians:
                                                dataManager.carvDataPair.right.attitude.eulerAngles(order: .xyz).angles.y
                                            ).degrees)
                        )
                    )
                    Text(
                        String(
                            Int(
                                Angle2DFloat(radians:
                                                dataManager.carvDataPair.right.attitude.eulerAngles(order: .xyz).angles.z
                                            ).degrees)
                        )
                    )
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

