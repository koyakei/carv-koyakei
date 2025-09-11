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
    @StateObject private var carv1DataPair: Carv1DataPair = Carv1DataPair()
    private var locationManager = LocationManager()
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject private var yawingBeep: YawingBeep = YawingBeep()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(carv1DataPair)
                .environmentObject(yawingBeep)
                .environmentObject(BluethoothCentralManager())
//                .onChange(of: scenePhase) { oldPhase, newPhase in
//                    handleScenePhaseChange(newPhase)
//                }
        }
    }
    
    init(){
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
