//
//  HomeView.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/26.
//

import SwiftUI
import Spatial
import AudioKit


struct HomeView: View {
    @EnvironmentObject var ble : BluethoothCentralManager
    @ObservedObject var carv2DataPair = Carv2DataPair.shared
    @ObservedObject var yawingBeep: YawingBeep = .shared
    @ObservedObject var carv2AnalyzedDataPairManager = Carv2AnalyzedDataPairManager.shared
   
    @State var rollingBeep: Bool = false
    @State var diffRollingTargetAngle: Double = 2.0

    var body: some View {
        VStack {
            HStack{
                Text(Angle2D(radians: carv2DataPair.beforeTurn.fallLineAttitude.eulerAngles(order: .xyz).angles.x).degrees.description)
                Text(Angle2D(radians: carv2DataPair.beforeTurn.fallLineAttitude.eulerAngles(order: .xyz).angles.y).degrees.description)
                Text(Angle2D(radians: carv2DataPair.beforeTurn.fallLineAttitude.eulerAngles(order: .xyz).angles.z).degrees.description)
            }
            HStack{
                Text(Angle2D(radians: carv2DataPair.left.leftRealityKitRotation.eulerAngles(order: .xyz).angles.x).degrees.description)
                Text(Angle2D(radians: carv2DataPair.left.leftRealityKitRotation.eulerAngles(order: .xyz).angles.y).degrees.description)
                Text(Angle2D(radians: carv2DataPair.left.leftRealityKitRotation.eulerAngles(order: .xyz).angles.z).degrees.description)
            }
            HStack{
                Text(Angle2D(radians: carv2DataPair.right.rightRealityKitRotation.eulerAngles(order: .xyz).angles.x).degrees.description)
                Text(Angle2D(radians: carv2DataPair.right.rightRealityKitRotation.eulerAngles(order: .xyz).angles.y).degrees.description)
                Text(Angle2D(radians: carv2DataPair.right.rightRealityKitRotation.eulerAngles(order: .xyz).angles.z).degrees.description)
            }
            HStack{
                Text(Angle2D(radians: carv2DataPair.right.leftRealityKitRotation3.eulerAngles(order: .xyz).angles.x).degrees.description)
                Text(Angle2D(radians: carv2DataPair.right.leftRealityKitRotation3.eulerAngles(order: .xyz).angles.y).degrees.description)
                Text(Angle2D(radians: carv2DataPair.right.leftRealityKitRotation3.eulerAngles(order: .xyz).angles.z).degrees.description)
            }
            HStack{
                Text(Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.x).degrees.description)
                Text(Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.y).degrees.description)
                Text(Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.z).degrees.description)
            }
            HStack{
                Text(Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.x).degrees.description)
                Text(Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.y).degrees.description)
                Text(Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.z).degrees.description)
            }
            HStack{
                Text(carv2DataPair.left.leftRealityKitRotation.quaternion.formatQuaternion)
                Text(carv2DataPair.right.rightRealityKitRotation.quaternion.formatQuaternion)
                VStack{
                    Text(carv2DataPair.unitedYawingAngle.description)
                    Text(carv2DataPair.analyzedDataPair.numberOfTurns.description)
                    Text(Date(timeIntervalSince1970:  carv2DataPair.turnSideChangingPeriodFinder.lastSwitchedTurnSideTimeStamp) , format: Date.FormatStyle(date: .omitted, time: .complete))
                    Text(carv2DataPair.currentTurn.count.description)
                    Text(carv2AnalyzedDataPairManager.currentTurn.description)
                }
            }
            HStack{
                Text(Vector3D(carv2DataPair.right.angularVelocity).description)
            }
            HStack{
                Text(String(format: "%.1f",carv2DataPair.parallelAngleByAttitude))
            }
            HStack{
                VStack{
                    
                    Text(String(Int(
                        Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.x).degrees)))
                    
                    Text("pitch" + String(Int(
                        Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.y).degrees)))
                    
                    Text(String(Int(
                        Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.z).degrees)))
                }
                VStack{
                    
                    Text(String(Int(
                        Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.x).degrees)))
                    
                    Text("pitch" + String(Int(
                        Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.y).degrees)))
                    
                    Text(String(Int(
                        Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.z).degrees)))
                }
            }
            HStack{
                Button(action: {
                    ble.carv2DataPair.startCSVRecording()
                }){
                    Text("start csv")
                }
                Button(action: {
                    ble.carv2DataPair.stopCSVRecording()
                }){
                    Text("stop csv")
                }
            }
           
            HStack{
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
                        in: 0.0...4.0,
                        step: 0.2
                    ) {
                    Text("Yaw Adjustment")
                }
            }
            HStack{
                Button(action: {
                    rollingBeep.toggle()}){
                        Text("rolling beep \(yawingBeep.isBeeping ? "on" : "off")")
                    }
                Text("Current value: \(diffRollingTargetAngle, specifier: "%.2f")")
                    .padding()
            }
            if rollingBeep {
                Slider(
                    value: $diffRollingTargetAngle,
                    in: 0.0...4.0,
                    step: 0.2
                ) {
                    Text("Rolling Adjustment")
                }
            }
            HStack{
                Button(action: { ble.scan() }) {
                    Text("Scan")
                }
                Button(action: { ble.retrieveAndConnect() }) {
                    Text("Retrieve and Connect")
                }
                .padding()
            }
            List(ble.carvDeviceList) { device in
                
                DeviceRow(device: device, ble: ble)
            }
        }.onAppear {
//            conductor.start()
        }
    }
}
