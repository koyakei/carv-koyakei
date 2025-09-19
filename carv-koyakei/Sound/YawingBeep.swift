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
class YawingBeep{
    
    var isBeeping: Bool = false {
        didSet{
            if isBeeping {
                conductor.start()
            } else {
                conductor.stop()
            }
        }
    }
    var diffYawingTargetAngle: Double = 2.0
    var conductor: DynamicOscillatorConductor = DynamicOscillatorConductor()
    
    var dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    init(dataManager: DataManager){
        self.dataManager = dataManager
        dataManager.$carv2DataPair
            .sink { [weak self] newValue in
                self?.handleDataPairChange(newValue)
            }
            .store(in: &cancellables)  //handleDataPairChangeを実行したい
    }
    private var cancellable: AnyCancellable? = nil
    
    
    private func handleDataPairChange(_ carv2DataPair: Carv2DataPair) {
        if isBeeping == false { return }
        if (-diffYawingTargetAngle...diffYawingTargetAngle).contains(Double(carv2DataPair.yawingAngulerRateDiffrential) ) {
            conductor.data.isPlaying = false
        } else {
            conductor.data.isPlaying = true
        }
        if carv2DataPair.yawingAngulerRateDiffrential > 0 {
            conductor.data.frequency = AUValue(hight(ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
            conductor.changeWaveFormToSin()
        } else {
            conductor.changeWaveFormToTriangle()
            conductor.data.frequency = AUValue(lowToHigh(-ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
        }
    }
    
    func lowToHigh(_ num : Float) -> Float {
            let base : Float = 440.0
            let max: Float = -48
            return base * pow(pow(2, max - num), 1/12)
        }
    
    func hight(_ num : Float) -> Float {
            let base : Float = 440.0
            let min: Float = 0
            return base * pow(pow(2, num + min), 1/12)
        }
}

