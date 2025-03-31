//
//  YawingBeep.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/03/17.
//


import AudioKit
import Foundation
import Combine
import SwiftUICore

class YawingBeep: ObservableObject{
    
    var isBeeping: Bool = false
    public static var shared: YawingBeep = .init()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var diffYawingTargetAngle: Double = 2.0
    @ObservedObject var conductor : DynamicOscillatorConductor = DynamicOscillatorConductor()
    private init() {
        
        conductor.start()
        carv2DataPair.$right
            .sink { [weak self] newValue in
                self?.handleRightChange(newValue)
            }
            .store(in: &cancellables)
    }
    var carv2DataPair :Carv2DataPair = Carv2DataPair.shared
        
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
