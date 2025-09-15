//
//  carv_koyakeiApp.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/01/23.
//

import SwiftUI
import AVFAudio
import Combine

@MainActor
final class Carv2DataPairStore: ObservableObject {
    @Published var carv2DataPairArray: [Carv2DataPair] = []
    @Published var carv2DataPair: Carv2DataPair = Carv2DataPair()
    func update(_ carv2DataPair: Carv2DataPair) {
        self.carv2DataPair = carv2DataPair
        self.carv2DataPairArray.append(carv2DataPair)
    }
}

@main
struct carv_koyakeiApp: App {
    private var dataStore = Carv2DataPairStore()
    private var carv2DataPair: Carv2DataPair = Carv2DataPair()
    private var carv1DataPair: Carv1DataPair = Carv1DataPair()
    private var locationManager = LocationManager()
    private var ble: BluethoothCentralManager = BluethoothCentralManager()
    private var cancellables = Set<AnyCancellable>()
    @Environment(\.scenePhase) var scenePhase
    
    init(){
        configureAudioSessionForBackground()
        ble.carv2DeviceLeft?.characteristicUpdatePublisher
            .sink { characteristic in
                            // 3. Handle the received characteristic update here
                            print("Received characteristic update in Subscriber Class!")
                print("Characteristic value: \(characteristic.description)") // `hexString` is a common extension for Data
                            
                        }
            .store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataStore, ble: ble)
        }
    }
    
    private func configureAudioSessionForBackground() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .voiceChat, options: [.allowBluetoothA2DP, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
    }
}

