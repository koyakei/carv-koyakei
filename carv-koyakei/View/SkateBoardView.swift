//
//  SkateBoardView.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/29.
//
import SwiftUI
import CoreMotion
import Spatial
import Combine
import Foundation
import CoreLocation
import Charts

struct SkateBoardView: View {
    @StateObject var skateboard: SkateBoardDataManager
    @AppStorage("ssid") var ssid: String = ""
    @AppStorage("password") var password: String = ""
    @StateObject var droggerBluetooth: DroggerBluetoothModel // Owns its own DroggerBluetoothModel instance.
    var body: some View {
        VStack{
            HStack () {
                Label("Device", systemImage: "info.circle")
                    .labelStyle(.automatic)
                    .padding(.bottom, 12)
                Spacer() 
                Text(droggerBluetooth.peripheralStatus.rawValue)
            }
            Text(droggerBluetooth.deviceDetail)
                .font(.system(size: 10, design: .monospaced))
                .textSelection(.enabled)
            Text("number of turn \(skateboard.numberOfTurn.description)")
            Text("heas \(skateboard.analysedData.headFallineAcceleration.description)")
            Rectangle()
                .fill(Color.blue)
                .frame(width: CGFloat((skateboard.rawData.timestamp.timeIntervalSince1970 - skateboard.headMotion.timestamp.timeIntervalSince1970) * 1000 + 100), height: 20)
                .animation(.default, value: CGFloat((skateboard.rawData.timestamp.timeIntervalSince1970 - skateboard.headMotion.timestamp.timeIntervalSince1970) * 1000 + 100))
            // ヘッドフォンがどっち向いているか計算したい
            // 絶対姿勢から相対姿勢を計算する　そこから
            HStack{
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headRelativeAttitudeAgainstBoard.eulerAngles(order: .xyz).angles.x)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headRelativeAttitudeAgainstBoard.eulerAngles(order: .xyz).angles.y)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headRelativeAttitudeAgainstBoard.eulerAngles(order: .xyz).angles.z)))
            }
            HStack{
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.headBoardDiffrencial.eulerAngles(order: .xyz).angles.x)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.headBoardDiffrencial.eulerAngles(order: .xyz).angles.y)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.headBoardDiffrencial.eulerAngles(order: .xyz).angles.z)))
            }
            HStack{
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headAttitude.eulerAngles(order: .xyz).angles.x)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headAttitude.eulerAngles(order: .xyz).angles.y)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headAttitude.eulerAngles(order: .xyz).angles.z)))
            }
            
            HStack{
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headRelativeAttitudeAgainstFallLine.eulerAngles(order: .xyz).angles.x)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headRelativeAttitudeAgainstFallLine.eulerAngles(order: .xyz).angles.y)))
                Text("↑").rotationEffect(Angle(radians: Double(skateboard.analysedData.headRelativeAttitudeAgainstFallLine.eulerAngles(order: .xyz).angles.z)))
            }
  
//            Rectangle()
//                            .fill(Color.blue)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeAccelerationAgainstBoard.uniformlyScaled(by: 100).x + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeAccelerationAgainstBoard.uniformlyScaled(by: 100).x + 100))
//            Rectangle()
//                            .fill(Color.yellow)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeAccelerationAgainstBoard.uniformlyScaled(by: 100).y + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeAccelerationAgainstBoard.uniformlyScaled(by: 100).y + 100))
//            Rectangle()
//                            .fill(Color.red)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeAccelerationAgainstBoard.uniformlyScaled(by: 100).z + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeAccelerationAgainstBoard.uniformlyScaled(by: 100).z + 100))
//            
//            Rectangle()
//                            .fill(Color.blue)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeAcceleration.uniformlyScaled(by: 100).x + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeAcceleration.uniformlyScaled(by: 100).x + 100))
//            Rectangle()
//                            .fill(Color.yellow)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeAcceleration.uniformlyScaled(by: 100).y + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeAcceleration.uniformlyScaled(by: 100).y + 100))
//            Rectangle()
//                            .fill(Color.red)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeAcceleration.uniformlyScaled(by: 100).z + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeAcceleration.uniformlyScaled(by: 100).z + 100))
//            
//            Rectangle()
//                            .fill(Color.blue)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeFallLineAcceleration.uniformlyScaled(by: 100).x + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeFallLineAcceleration.uniformlyScaled(by: 100).x + 100))
//            Rectangle()
//                            .fill(Color.yellow)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeFallLineAcceleration.uniformlyScaled(by: 100).y + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeFallLineAcceleration.uniformlyScaled(by: 100).y + 100))
//            Rectangle()
//                            .fill(Color.red)
//                            .frame(width: CGFloat(skateboard.analysedData.headRelativeFallLineAcceleration.uniformlyScaled(by: 100).z + 100), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.analysedData.headRelativeFallLineAcceleration.uniformlyScaled(by: 100).z + 100))
//            Rectangle()
//                            .fill(Color.blue)
//                            .frame(width: CGFloat(skateboard.headMotion.acceleration.uniformlyScaled(by: 100).x ?? 0), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.headMotion.acceleration.uniformlyScaled(by: 100).x ?? 0))
//            Rectangle()
//                            .fill(Color.blue)
//                            .frame(width: CGFloat(skateboard.headMotion.acceleration.uniformlyScaled(by: 100).y ?? 0), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.headMotion.acceleration.uniformlyScaled(by: 100).y ?? 0))
//            Rectangle()
//                            .fill(Color.blue)
//                            .frame(width: CGFloat(skateboard.headMotion.acceleration.uniformlyScaled(by: 100).z ?? 0), height: 20)
//                            .animation(.default, value: CGFloat(skateboard.headMotion.acceleration.uniformlyScaled(by: 100).z ?? 0))
//            
            VStack{
                Button("clear"){
                    skateboard.finishedTurnDataArray.removeAll()
                }
                Text(skateboard.rawData.timestamp.description)
                Text(skateboard.lastFinishedTrunData.turnEndedTime.description)
                Text("wifi setting 接続先")
                TextField("SSID", text: $ssid)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text( "head avalable \(skateboard.headMotionManager.isDeviceMotionActive.description)")
                if let rtkDevice = droggerBluetooth.rtkDevice {
                    Button("接続"){
                        rtkDevice.setWifiSetting(ssid: ssid, password: password)
                    }
                    Button("start ntrip"){
                        rtkDevice.startNtrip()
                    }
                    Text(rtkDevice.latestRes)
                    Text("接続遅延秒数 \(String(describing: rtkDevice.age))")
                }
                HStack{
                    Button("start motion"){
                        skateboard.startRecording()
                    }
                    Button("start head and board recoarding"){
                        skateboard.startHeadAndBoardMotionRecording()
                    }
                }
                Button("head orientation calibration"){
                    skateboard.calibrateHeadBoardDifference()
                }
                Button("stop motion"){
                    skateboard.stopRecording()
                }
                Button("export json"){
                    skateboard.export()
                }
            }
        }
    }
}

