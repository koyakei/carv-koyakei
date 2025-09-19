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
    private var carv1DataPair: Carv1DataPair = Carv1DataPair()
    private var locationManager = LocationManager()
    @Environment(\.scenePhase) var scenePhase
    private var yawingBeep: YawingBeep
    private var rollingBeep: RollingBeep = RollingBeep()
    private var carv2AnalyzedDataPairManager: Carv2AnalyzedDataPairManager = Carv2AnalyzedDataPairManager(carv2DataPair: Carv2DataPair.shared)
    private var dataManager: DataManager
    private var bleManager : BluethoothCentralManager = BluethoothCentralManager()
    init() {
        dataManager = DataManager(bluethoothCentralManager: bleManager, carv2DataPair: Carv2DataPair.shared)
       
        self.yawingBeep = YawingBeep(dataManager: dataManager)
    }
    var body: some Scene {
        WindowGroup {
            ContentView(ble: bleManager, yawingBeep: yawingBeep,rollingBeep: rollingBeep,dataManager: dataManager)
        }
    }
}
