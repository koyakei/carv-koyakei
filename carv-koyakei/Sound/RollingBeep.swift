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
@MainActor
@Observable
class RollingBeep{
    private var cancellable: AnyCancellable?
    init() {
        conductor.start()
        cancellable = carv2DataPair.updates
                    .receive(on: RunLoop.main) // メインスレッドで値を受け取ることを保証
                    .sink { [weak self] updatedData in
                        // 値が流れてくるたびにこのクロージャが実行される
                        // handleRightChangeが非同期関数のためTaskで囲む
                        Task {
                            self?.handleRightChange(updatedData)
                        }
                    }
    }
    
    var isBeeping: Bool = false
    private var cancellables = Set<AnyCancellable>()
    var diffYawingTargetAngle: Double = 2.0
    var conductor : DynamicOscillatorConductor = DynamicOscillatorConductor()
    
    var carv2DataPair :Carv2DataPair = Carv2DataPair.shared
        
    private func handleRightChange(_ newValue: Carv2Data) {
        if isBeeping == false { return }
        if (-diffYawingTargetAngle...diffYawingTargetAngle).contains(Double(carv2DataPair.rollingAngulerRateDiffrential) ) {
            conductor.data.isPlaying = false
        } else {
            conductor.data.isPlaying = true
        }
        if carv2DataPair.rollingAngulerRateDiffrential > 0 {
            conductor.data.frequency = AUValue(hight(ceil(carv2DataPair.rollingAngulerRateDiffrential * 10)))
            conductor.changeWaveFormToSin()
        } else {
            conductor.changeWaveFormToTriangle()
            conductor.data.frequency = AUValue(lowToHigh(-ceil(carv2DataPair.rollingAngulerRateDiffrential * 10)))
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

