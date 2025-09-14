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
    private var carv1DataPair: Carv1DataPair = Carv1DataPair()
    private var locationManager = LocationManager()
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject private var yawingBeep: YawingBeep = YawingBeep()
    private var carv2AnalyzedDataPairManager: Carv2AnalyzedDataPairManager = Carv2AnalyzedDataPairManager(carv2DataPair: Carv2DataPair.shared)
    
    var body: some Scene {
        WindowGroup {
            ContentView(ble: BluethoothCentralManager(carv2AnalyzedDataPairManager:carv2AnalyzedDataPairManager), yawingBeep: yawingBeep)
//                .onChange(of: scenePhase) { oldPhase, newPhase in
//                    handleScenePhaseChange(newPhase)
//                }
        }
    }
    
    init(){
        configureAudioSessionForBackground()
        Carv2DataPair.shared.delegate = yawingBeep
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
