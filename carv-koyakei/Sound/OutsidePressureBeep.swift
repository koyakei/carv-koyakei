//
//  YawingBeep.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/03/17.
//

import AudioKit
import Foundation
import Combine
import SwiftUI
import AVFAudio
@MainActor
class OutsidePressureBeep{
    
    var isBeeping: Bool = false {
        didSet{
            if isBeeping {
                conductor.start()
            } else {
                conductor.stop()
            }
        }
    }
    
    var conductor: DynamicOscillatorConductor = DynamicOscillatorConductor()
    var dataManager: Carv1DataManager
    private var cancellables = Set<AnyCancellable>()
    init(dataManager: Carv1DataManager){
        self.dataManager = dataManager
        dataManager.$carvDataPair
            .sink { [weak self] newValue in
                self?.handleDataPairChange(newValue)
            }
            .store(in: &cancellables)  //handleDataPairChangeを実行したい
    }
    
    private var cancellable: AnyCancellable? = nil
    
    private func handleDataPairChange(_ carvDataPair: Carv1AnalyzedDataPair) {
        if isBeeping == false { return }
        if(carvDataPair.外足荷重されているか){
            conductor.data.isPlaying = false
        } else {
            conductor.data.isPlaying = true
        }
    }
}

