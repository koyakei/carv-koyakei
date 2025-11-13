//
//  carv_koyakeiApp.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/01/23.
//

import SwiftUI
import AVFAudio
import Combine
import SwiftData

@main
struct carv_koyakeiApp: App {
    private var locationManager = LocationManager()
    var modelContainer : ModelContainer
    private var yawingBeep: YawingBeep
    private var rollingBeep: RollingBeep
    private var outsidePressureBeep: OutsidePressureBeep
    private var dataManager: DataManager
    private var carv1DataManager: Carv1DataManager
    private var bleManager : BluethoothCentralManager = BluethoothCentralManager()
    private var carv1BleManager : Carv1BluethoothCentralManager = Carv1BluethoothCentralManager()
    private var droggerBluetooth: DroggerBluetoothModel = DroggerBluetoothModel()
    init() {
        dataManager = DataManager(bluethoothCentralManager: bleManager)
        self.yawingBeep = YawingBeep(dataManager: dataManager)
        self.rollingBeep = RollingBeep(dataManager: dataManager)
        carv1DataManager = Carv1DataManager(bluethoothCentralManager: carv1BleManager)
        self.outsidePressureBeep = OutsidePressureBeep(dataManager: carv1DataManager)
        self.modelContainer = try! ModelContainer(for: SkateBoardDataManager.SingleFinishedTurnData.self)
    }
    var body: some Scene {
        WindowGroup {
            ContentView(ble: bleManager, yawingBeep: yawingBeep,rollingBeep: rollingBeep,dataManager: dataManager, carv1DataManager: carv1DataManager,outsidePressureBeep: outsidePressureBeep, carv1Ble: carv1BleManager,modelContainer: modelContainer)
        }
    }
}
