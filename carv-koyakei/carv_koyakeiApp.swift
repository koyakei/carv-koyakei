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
    private var outsidePressureBeep: OutsidePressureBeep
    private var carvDataManager = CarvDataManager()
    private var carv1DataManager: Carv1DataManager
    @StateObject private var bleManager : Carv2BluethoothCentralManager = Carv2BluethoothCentralManager()
    private var carv1BleManager : Carv1BluethoothCentralManager = Carv1BluethoothCentralManager()
    private var skateBoardDataManager: SkateBoardDataManager
    private var droggerVluetooth: DroggerBluetoothModel = DroggerBluetoothModel()
    
    init() {
        carv1DataManager = Carv1DataManager(bluethoothCentralManager: carv1BleManager)
        skateBoardDataManager = SkateBoardDataManager(analysedData: SkateBoardAnalysedData(), droggerBluetooth: droggerVluetooth)
        self.outsidePressureBeep = OutsidePressureBeep(dataManager: carv1DataManager)
    }
    var body: some Scene {
        WindowGroup {
            ContentView(ble: bleManager,dataManager: carvDataManager, carv1DataManager: carv1DataManager,outsidePressureBeep: outsidePressureBeep, carv1Ble: carv1BleManager, skateBoardDataManager: skateBoardDataManager,droggerBlueTooth: droggerVluetooth)
        }
    }
}

@MainActor
class CarvDataManager {
    @StateObject  var yawingBeep: YawingBeep = YawingBeep()
     var carv2DataManager: Carv2DataManager = Carv2DataManager()
    @StateObject  var bleManager: Carv2BluethoothCentralManager =  Carv2BluethoothCentralManager()
    init() {
    }
}
