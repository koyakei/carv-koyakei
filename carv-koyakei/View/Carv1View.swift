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
    @State var outsidePressureBeep: OutsidePressureBeep
    @State var yawingBeep: YawingBeepCarv1
    // この数字で向きを揃えられるがヨーイングがいまいち揃わない
       @State var diffrencialYaw : Float = -.pi
       @State var diffrencialX : Float = -1
       @State var diffrencialY : Float = 0
       @State var diffrencialZ : Float = 0
    var body: some View {
        ScrollView {
            Text(
                dataManager.carvRawDataPair.left.recordedAtFromBootDevice.description)
            let gridItems = Array(repeating: GridItem(.flexible()), count: 5)
            LazyVGrid(columns: gridItems, spacing: 10) {
//                Text(dataManager.carvRawDataPair.left.debugString)
                ForEach(dataManager.carvRawDataPair.left.fordebug.indices, id: \.self) { i in
                    Grid{
                        VStack{
                            Text("\(i.description)")
                            Text(" \(dataManager.carvRawDataPair.left.fordebug[i].formatted(FloatingPointFormatStyle<Float>.number.precision(.fractionLength(3))))")
                        }
                        
                    }
                }
                .padding()
            }
        }
        VStack {
            HStack{
                Text(yawingBeep.conductor.data.isPlaying.description)
                Button(action: {
                    yawingBeep.isBeeping.toggle()}){
                        Text("yawing beep \(yawingBeep.isBeeping ? "on" : "off")")
                    }
                Text("Current value: \(yawingBeep.diffYawingTargetAngle, specifier: "%.2f")")
                    .padding()
            }
            
            if yawingBeep.isBeeping {
                Slider(
                    value: $yawingBeep.diffYawingTargetAngle,
                    in: 0.4...4.8,
                    step: 0.2
                ) {
                    Text("Yaw Adjustment")
                }
            }
            HStack {
                
                VStack{
//                    Text("記録開始時からの時間経過　\(dataManager.carvRawDataPair.left.recordedAtFromBootDevice)")
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
                VStack{
                    Text(
                        String(
                            Int(
                                Angle2DFloat(radians:
                                                                                dataManager.carvDataPair.left.attitude
                                                                        .eulerAngles(order: .xyz).angles.x
                                                                            ).degrees)
                            - Int(
                                Angle2DFloat(radians:
                                                                                dataManager.carvDataPair.right.attitude
                                                                        .eulerAngles(order: .xyz).angles.x
                                                                            ).degrees)
                            
                        )
                    )
                    Text("ヨーイング角度差")
                    Text(dataManager.carvDataPair.yawingAnguleDiffrential.formatted(.number.precision(.fractionLength(1))))
                }
            }
            
            HStack{
                VStack{
                    Text(
                        String(
                            Int(
                                dataManager.carvDataPair.left.attitude.twist(twistAxis: .x).angle.degrees
                                )
                        )
                    )
                    Text(
                        String(
                            Int(
                                dataManager.carvDataPair.left.attitude.twist(twistAxis: .y).angle.degrees
                            )
                        )
                    )
                    Text(
                        String(
                            Int(
                                dataManager.carvDataPair.left.attitude.twist(twistAxis: .z).angle.degrees
                            )
                        )
                    )
                }
                VStack{
                    Text(
                        String(
                            Int(
                                dataManager.carvDataPair.right.attitude.twist(twistAxis: .x).angle.degrees
                                )
                        )
                    )
                    Text(
                        String(
                            Int(
                                dataManager.carvDataPair.right.attitude.twist(twistAxis: .y).angle.degrees
                            )
                        )
                    )
                    Text(
                        String(
                            Int(
                                dataManager.carvDataPair.right.attitude.twist(twistAxis: .z).angle.degrees
                            )
                        )
                    )
                }
//                VStack{
//                    Text(
//                        String(
//                            Int(
//                                Angle2DFloat(radians:
//                                                dataManager.carvDataPair.right.attitude.eulerAngles(order: .xyz).angles.x
//                                            ).degrees)
//                        )
//                    )
//                    Text(
//                        String(
//                            Int(
//                                Angle2DFloat(radians:
//                                                dataManager.carvDataPair.right.attitude.eulerAngles(order: .xyz).angles.y
//                                            ).degrees)
//                        )
//                    )
//                    Text(
//                        String(
//                            Int(
//                                Angle2DFloat(radians:
//                                                dataManager.carvDataPair.right.attitude.eulerAngles(order: .xyz).angles.z
//                                            ).degrees)
//                        )
//                    )
//                }
            }
            HStack{
                Text(outsidePressureBeep.conductor.data.isPlaying.description)
                Button(action: {
                    outsidePressureBeep.isBeeping.toggle()}){
                        Text("yawing beep \(outsidePressureBeep.isBeeping ? "on" : "off")")
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

