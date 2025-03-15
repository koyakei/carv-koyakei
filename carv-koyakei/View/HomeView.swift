//
//  HomeView.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/26.
//

import SwiftUI
import Spatial
import AudioKit

extension Vector3D {
    var description: String {
        "(\(String(format: "%.1f",x)), \(String(format: "%.1f",y)), \(String(format: "%.1f",z)))"
    }
}
struct HomeView: View {
    @ObservedObject var ble = BluethoothCentralManager()
    @ObservedObject var carv2DataPair = Carv2DataPair.shared
    @ObservedObject var conductor = DynamicOscillatorConductor()
    @ObservedObject var carv2AnalyzedDataPairManager = Carv2AnalyzedDataPairManager.shared
    @State var diffYawingTargetAngle: Double = 2.0
    @State var yawingBeep: Bool = false
    @State var rollingBeep: Bool = false
    @State var diffRollingTargetAngle: Double = 2.0

    var body: some View {
        VStack {
            HStack{
                Text(carv2DataPair.rightAngularVelocityProjectedToLeft.description)
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
            //            Text("paralell rotation angle \(carv2DataPair.yawingAngulerRateDiffrential * 10)")
           
            HStack{
                Button(action: {
                    yawingBeep.toggle()}){
                        Text("yawing beep \(yawingBeep ? "on" : "off")")
                    }
                Text("Current value: \(diffYawingTargetAngle, specifier: "%.2f")")
                    .padding()
            }
            if yawingBeep {
                    Slider(
                        value: $diffYawingTargetAngle,
                        in: 0.0...4.0,
                        step: 0.2
                    ) {
                    Text("Yaw Adjustment")
                }
            }
            HStack{
                Button(action: {
                    rollingBeep.toggle()}){
                        Text("rolling beep \(yawingBeep ? "on" : "off")")
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
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }.onChange(of: carv2DataPair.yawingAngulerRateDiffrential) {
            if yawingBeep {
                if (-diffYawingTargetAngle...diffYawingTargetAngle).contains(Double(carv2DataPair.yawingAngulerRateDiffrential) ) {
                    conductor.data.isPlaying = false
                } else {
                    conductor.data.isPlaying = true
                }
                if carv2DataPair.yawingAngulerRateDiffrential > 0 {
                    conductor.panner.pan = 1.0
                    conductor.data.frequency = AUValue(ToneStep.lowToHigh(ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
                    conductor.changeWaveFormToSin()
                } else {
                    conductor.panner.pan = -1.0
                    conductor.changeWaveFormToTriangle()
                    conductor.data.frequency = AUValue(ToneStep.hight(ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
                }
            }
        }.onChange(of: carv2DataPair.rollingAngulerRateDiffrential) {
            if rollingBeep {
                if (-diffRollingTargetAngle...diffRollingTargetAngle).contains(Double(carv2DataPair.rollingAngulerRateDiffrential) ) {
                    conductor.data.isPlaying = false
                } else {
                    conductor.data.isPlaying = true
                }
                if carv2DataPair.rollingAngulerRateDiffrential > 0 {
                    conductor.panner.pan = 1.0
                    conductor.data.frequency = AUValue(ToneStep.lowToHigh(ceil(carv2DataPair.rollingAngulerRateDiffrential * 10)))
                    conductor.changeWaveFormToSin()
                } else {
                    conductor.panner.pan = -1.0
                    conductor.changeWaveFormToTriangle()
                    conductor.data.frequency = AUValue(ToneStep.hight(ceil(carv2DataPair.rollingAngulerRateDiffrential * 10)))
                }
            }
        }
    }
}
