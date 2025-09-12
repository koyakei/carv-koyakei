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

class YawingBeep: ObservableObject{
    
    var isBeeping: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    @Published var diffYawingTargetAngle: Double = 2.0
    @ObservedObject var conductor : DynamicOscillatorConductor = DynamicOscillatorConductor()
    init(carv2DataPair :Carv2DataPair) {
        self.carv2DataPair = carv2DataPair
        conductor.start()
    }
    var carv2DataPair :Carv2DataPair
        
    private func handleRightChange(_ newValue: Carv2Data) {
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
