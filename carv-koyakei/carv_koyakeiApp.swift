//
//  carv_koyakeiApp.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/01/23.
//

import SwiftUI
import CoreBluetooth
import AVFAudio

@main
struct carv_koyakeiApp: App {
    @StateObject private var conductor = DynamicOscillatorConductor()
    @StateObject private var carv2DataPair: Carv2DataPair = Carv2DataPair()
    @StateObject private var carv1DataPair: Carv1DataPair = Carv1DataPair()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(carv1DataPair)
                .environmentObject(carv2DataPair)
                .environmentObject(YawingBeep(carv2DataPair: carv2DataPair, conductor: conductor))
                .environmentObject(BluethoothCentralManager())
                .environmentObject(conductor)
                .onAppear {
                    conductor.start()
                }
                .onChange(of: scenePhase) { newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            configureAudioSessionForBackground()
        case .active:
            configureAudioSessionForForeground()
        case .inactive:
            break
        @unknown default:
            break
        }
    }

    private func configureAudioSessionForBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.allowBluetoothA2DP, .mixWithOthers, .defaultToSpeaker]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    private func configureAudioSessionForForeground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.allowBluetoothA2DP, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }
}

