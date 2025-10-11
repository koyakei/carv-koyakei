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
            Text("heas \(skateboard.finishedTurnDataArray.last?.lastPhaseOfTune.headAttitude.vector.x.description)")
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




