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
    @Environment(\.scenePhase) var scenePhase
    private var yawingBeep: YawingBeep
    private var rollingBeep: RollingBeep
    private var outsidePressureBeep: OutsidePressureBeep
    private var dataManager: DataManager
    private var carv1DataManager: Carv1DataManager
    private var bleManager : BluethoothCentralManager = BluethoothCentralManager()
    private var carv1BleManager : Carv1BluethoothCentralManager = Carv1BluethoothCentralManager()
    private var skateBoardDataManager: SkateBoardDataManager
    private var modelContext :ModelContext
    private var droggerVluetooth: DroggerBluetoothModel = DroggerBluetoothModel()
    init() {
        do{
            let modelContainer = try ModelContainer(for: SkateBoardDataManager.SingleFinishedTurnData.self)
            modelContext = ModelContext(modelContainer)
        }catch {
            fatalError("Could not set up ModelContainer: \(error)")
        }
        dataManager = DataManager(bluethoothCentralManager: bleManager)
        carv1DataManager = Carv1DataManager(bluethoothCentralManager: carv1BleManager)
        skateBoardDataManager = SkateBoardDataManager(analysedData: SkateBoardAnalysedData(), droggerBluetooth: droggerVluetooth, modelContext: modelContext)
        self.yawingBeep = YawingBeep(dataManager: dataManager)
        self.rollingBeep = RollingBeep(dataManager: dataManager)
        self.outsidePressureBeep = OutsidePressureBeep(dataManager: carv1DataManager)
    }
    var body: some Scene {
        WindowGroup {
            ContentView(ble: bleManager, yawingBeep: yawingBeep,rollingBeep: rollingBeep,dataManager: dataManager, carv1DataManager: carv1DataManager,outsidePressureBeep: outsidePressureBeep, carv1Ble: carv1BleManager, skateBoardDataManager: skateBoardDataManager,droggerBlueTooth: droggerVluetooth)
        }
    }
}
