//
//  carv_koyakeiApp.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/01/23.
//

import SwiftUI
import AVFAudio

@main
struct carv_koyakeiApp: App {
    @State private var carv2DataPair: Carv2DataPair
    private var carv1DataPair: Carv1DataPair = Carv1DataPair()
    private var locationManager = LocationManager()
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject private var yawingBeep: YawingBeep
    private var carv2AnalyzedDataPairManager: Carv2AnalyzedDataPairManager
    private var bleManager : BluethoothCentralManager
    var body: some Scene {
        WindowGroup {
            ContentView(ble: bleManager, yawingBeep: yawingBeep)
        }
    }
    
    init(){
        carv2DataPair = Carv2DataPair.shared
        
        yawingBeep = YawingBeep(carv2DataPair: Carv2DataPair.shared)
        carv2AnalyzedDataPairManager = Carv2AnalyzedDataPairManager(carv2DataPair: Carv2DataPair.shared)
        bleManager = BluethoothCentralManager(carv2AnalyzedDataPairManager: carv2AnalyzedDataPairManager)
        configureAudioSessionForBackground()
    }

    private func configureAudioSessionForBackground() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .voiceChat,options: [.allowBluetoothA2DP,.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
    }
}
