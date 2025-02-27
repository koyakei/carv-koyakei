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
    @ObservedObject var ble = BluethoothCentralManager()
    @ObservedObject var carv2DataPair = Carv2DataPair.shared
    @ObservedObject var conductor = DynamicOscillatorConductor()
    @State var diffTargetAngle: Double = 2.0
    var body: some View {
        VStack {
            //            Button(action: {
            //                Carv1DataPair.shared.calibrateForce()
            //            }){
            //                Text("Calibrate")
            //            }
            HStack{
                Text(carv2DataPair.left.attitude.quaternion.formatQuaternion)
                Text(carv2DataPair.right.attitude.quaternion.formatQuaternion)
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
            //            Text("parallel angle2 \(ceil(parallelAngle2))")
            Slider(
                value: $diffTargetAngle,
                in: 0.0...3.0,
                step: 0.05
            ) {
                Text("Adjustment")
            }
            
            Text("Current value: \(diffTargetAngle, specifier: "%.2f")")
                .padding()
            //            Button(action: { conductor.data.isPlaying.toggle()}){
            //                conductor.data.isPlaying ? Text("stop paralell tone") : Text("start paralell tone")
            //            }
                        Button(action: { ble.scan() }) {
                            Text("Scan")
                        }
            Button(action: { ble.retrieveAndConnect() }) {
                Text("Retrieve and Connect")
            }
            .padding()
            List(ble.carvDeviceList) { device in
                
                DeviceRow(device: device, ble: ble)
            }
        }.onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }.onChange(of: carv2DataPair.yawingAngulerRateDiffrential) {
            if (-diffTargetAngle...diffTargetAngle).contains(Double(carv2DataPair.yawingAngulerRateDiffrential) ) {
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
    }
}
