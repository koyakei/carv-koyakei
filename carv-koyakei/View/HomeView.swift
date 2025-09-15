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
    var ble : BluethoothCentralManager
    var dataStore: Carv2DataPairStore
    
    @State var yawingBeep: YawingBeep
    
    @State var rollingBeep: Bool = false
    @State var diffRollingTargetAngle: Double = 2.0
    @State private var savedTime: String = ""
    @State private var leftid: String = ""
    var body: some View {
        VStack {
//                        HStack{
//                            Text(Angle2D(radians: carv2DataPair.beforeTurn.fallLineAttitude.eulerAngles(order: .xyz).angles.x).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.beforeTurn.fallLineAttitude.eulerAngles(order: .xyz).angles.y).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.beforeTurn.fallLineAttitude.eulerAngles(order: .xyz).angles.z).degrees.description)
//                        }
//                        HStack{
//                            Text(Angle2D(radians: carv2DataPair.left.leftRealityKitRotation.eulerAngles(order: .xyz).angles.x).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.left.leftRealityKitRotation.eulerAngles(order: .xyz).angles.y).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.left.leftRealityKitRotation.eulerAngles(order: .xyz).angles.z).degrees.description)
//                        }
//                        HStack{
//                            Text(Angle2D(radians: carv2DataPair.right.rightRealityKitRotation.eulerAngles(order: .xyz).angles.x).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.right.rightRealityKitRotation.eulerAngles(order: .xyz).angles.y).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.right.rightRealityKitRotation.eulerAngles(order: .xyz).angles.z).degrees.description)
//                        }
//                        HStack{
//                            Text(Angle2D(radians: carv2DataPair.right.leftRealityKitRotation3.eulerAngles(order: .xyz).angles.x).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.right.leftRealityKitRotation3.eulerAngles(order: .xyz).angles.y).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.right.leftRealityKitRotation3.eulerAngles(order: .xyz).angles.z).degrees.description)
//                        }
                        HStack{
                            Text(Angle2D(radians: dataStore.carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.x).degrees.description)
                            Text(Angle2D(radians: dataStore.carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.y).degrees.description)
                            Text(Angle2D(radians: dataStore.carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.z).degrees.description)
                        }
//                        HStack{
//                            Text(Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.x).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.y).degrees.description)
//                            Text(Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.z).degrees.description)
//                        }
            HStack{
                VStack{
//                                        Text( carv2DataPair.left.angularVelocity.x.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.left.angularVelocity.y.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.left.angularVelocity.z.formatted(.number.precision(.fractionLength(1))))
                }
                VStack{
//                                        Text( carv2DataPair.left.acceleration.x.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.left.acceleration.y.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.left.acceleration.z.formatted(.number.precision(.fractionLength(1))))
                }
                VStack{
//                                        Text( carv2DataPair.right.angularVelocity.x.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.right.angularVelocity.y.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.right.angularVelocity.z.formatted(.number.precision(.fractionLength(1))))
                }
                VStack{
//                                        Text( carv2DataPair.right.acceleration.x.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.right.acceleration.y.formatted(.number.precision(.fractionLength(1))))
//                                        Text( carv2DataPair.right.acceleration.z.formatted(.number.precision(.fractionLength(1))))
                }
//                VStack{
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度Right.x.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度Right.y.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度Right.z.formatted(.number.precision(.fractionLength(1))))
//                }
//                VStack{
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度2.x.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度2.y.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度2.z.formatted(.number.precision(.fractionLength(1))))
//                }
//                
//                VStack{
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度3.x.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度3.y.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度3.z.formatted(.number.precision(.fractionLength(1))))
//                }
//                
//                VStack{
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度4.x.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度4.y.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度4.z.formatted(.number.precision(.fractionLength(1))))
//                }
//                VStack{
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度5.x.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度5.y.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度5.z.formatted(.number.precision(.fractionLength(1))))
//                }
//                VStack{
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度6.x.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度6.y.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度6.z.formatted(.number.precision(.fractionLength(1))))
//                }
                
//                VStack{
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度7.x.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度7.y.formatted(.number.precision(.fractionLength(1))))
//                    Text( carv2DataPair.right.初期姿勢に対しての角速度7.z.formatted(.number.precision(.fractionLength(1))))
//                }
                
            }
//            List(carv2DataPair.left.doubleArray.indices, id: \.self) { idx in
//                        // 小数点以下3桁に固定表示
//                Text(idx.description)
//                Text(String(carv2DataPair.left.doubleArray[idx].description))
//                    }
//            HStack{
//                Text(carv2DataPair.left.leftRealityKitRotation.quaternion.formatQuaternion)
//                Text(carv2DataPair.yawingAngulerRateDiffrential.debugDescription)
//                Text(Angle2D(radians: carv2DataPair.unifiedDiffrentialAttitudeFromLeftToRight.eulerAngles(order: .xyz).angles.x).degrees.description)
//                Text(Angle2D(radians: carv2DataPair.unifiedDiffrentialAttitudeFromLeftToRight.eulerAngles(order: .xyz).angles.y).degrees.description)
//                Text(Angle2D(radians: carv2DataPair.unifiedDiffrentialAttitudeFromLeftToRight.eulerAngles(order: .xyz).angles.z).degrees.description)
//                VStack{
//                    Text(carv2DataPair.unitedYawingAngle.description)
//                    Text(carv2DataPair.analyzedDataPair.numberOfTurns.description)
//                    Text(Date(timeIntervalSince1970:  carv2DataPair.turnSideChangingPeriodFinder.lastSwitchedTurnSideTimeStamp) , format: Date.FormatStyle(date: .omitted, time: .complete))
//                    Text(carv2DataPair.currentTurn.count.description)
//                    Text(carv2AnalyzedDataPairManager.currentTurn.description)
//                }
//            }
//            HStack{
//                Text(Vector3D(carv2DataPair.right.angularVelocity).description)
//            }
//            HStack{
//                Text(String(format: "%.1f",carv2DataPair.parallelAngleByAttitude))
//            }
//            HStack{
//                VStack{
//                    
//                    Text(String(Int(
//                        Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.x).degrees)))
//                    
//                    Text("pitch" + String(Int(
//                        Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.y).degrees)))
//                    
//                    Text(String(Int(
//                        Angle2D(radians: carv2DataPair.left.attitude.eulerAngles(order: .xyz).angles.z).degrees)))
//                }
//                VStack{
//                    
//                    Text(String(Int(
//                        Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.x).degrees)))
//                    
//                    Text("pitch" + String(Int(
//                        Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.y).degrees)))
//                    
//                    Text(String(Int(
//                        Angle2D(radians: carv2DataPair.right.attitude.eulerAngles(order: .xyz).angles.z).degrees)))
//                }
//            }
//            HStack{
//                Button(action: {
//                    ble.carv2DataPair.startCSVRecording()
//                }){
//                    Text("start csv")
//                }
//                Button(action: {
//                    ble.carv2DataPair.stopCSVRecording()
//                }){
//                    Text("stop csv")
//                }
//                
//            }
//            VStack(spacing: 20) {
//                // 現在保存されている時刻を表示
//                Text(savedTime.isEmpty ? "保存された時刻がありません" : "保存された時刻: \(savedTime)")
//                
//            }.onAppear {
//                // アプリ起動時に保存されている時刻を取得
//                if let storedTime = UserDefaults.standard.string(forKey: "rightCarv2UUID") {
//                    savedTime = storedTime
//                }
//            }
//            .padding()
//            
//            VStack(spacing: 20) {
//                // 現在保存されている時刻を表示
//                Text(leftid.isEmpty ? "no left" : "left: \(leftid)")
//                
//            }.onAppear {
//                // アプリ起動時に保存されている時刻を取得
//                if let leftids = UserDefaults.standard.string(forKey: "leftCarv2UUID") {
//                    leftid = leftids
//                }
//            }
//            .padding()
//
            HStack{
                Text(yawingBeep.conductor.data.isPlaying.description)
                Text(yawingBeep.yawingAngulerRateDiffrential.description)
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
                    in: 0.8...4.8,
                    step: 0.2
                ) {
                    Text("Yaw Adjustment")
                }
            }
//            HStack{
//                Button(action: {
//                    rollingBeep.toggle()}){
//                        Text("rolling beep \(yawingBeep.isBeeping ? "on" : "off")")
//                    }
//                Text("Current value: \(diffRollingTargetAngle, specifier: "%.2f")")
//                    .padding()
//            }
//            if rollingBeep {
//                Slider(
//                    value: $diffRollingTargetAngle,
//                    in: 0.0...4.0,
//                    step: 0.2
//                ) {
//                    Text("Rolling Adjustment")
//                }
//            }
            HStack{
                Button(action: { ble.scan() }) {
                    Text("Scan")
                }
                Button(action: { ble.retrieveAndConnect() }) {
                    Text("Retrieve and Connect")
                }
                .padding()
            }
            if let left = ble.carv2DeviceLeft{
                DeviceRow(device: left, ble: ble)
            }
            if let right = ble.carv2DeviceRight{
                DeviceRow(device: right, ble: ble)
            }
        }.onAppear {
            //            conductor.start()
        }
    }
}

