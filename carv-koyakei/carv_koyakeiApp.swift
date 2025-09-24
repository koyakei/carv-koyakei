//
//  carv_koyakeiApp.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/01/23.
//

import SwiftUI
import AVFAudio
import Combine

@main
struct carv_koyakeiApp: App {
    private var locationManager = LocationManager()
    @Environment(\.scenePhase) var scenePhase
    private var yawingBeep: YawingBeep
    private var rollingBeep: RollingBeep
    private var dataManager: DataManager
    private var carv1DataManager: Carv1DataManager = Carv1DataManager(bluethoothCentralManager: Carv1BluethoothCentralManager())
    private var bleManager : BluethoothCentralManager = BluethoothCentralManager()
    init() {
        dataManager = DataManager(bluethoothCentralManager: bleManager)
        self.yawingBeep = YawingBeep(dataManager: dataManager)
        self.rollingBeep = RollingBeep(dataManager: dataManager)
    }
    var body: some Scene {
        WindowGroup {
            ContentView(ble: bleManager, yawingBeep: yawingBeep,rollingBeep: rollingBeep,dataManager: dataManager)
        }
    }
}
