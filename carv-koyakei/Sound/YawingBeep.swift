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
class YawingBeep: ObservableObject, Carv2DataPairDelegate{
    
    var isBeeping: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    @Published var diffYawingTargetAngle: Double = 2.0
    @ObservedObject var conductor : DynamicOscillatorConductor = DynamicOscillatorConductor()
    init() {
        
        conductor.start()
//        Task { [weak self] in
//            for await newValue in self?.carv2DataPair.updates ?? AsyncStream { _ in } {
//                await self?.handleRightChange(newValue.right)
//            }
//        }
    }
    var carv2DataPair :Carv2DataPair = Carv2DataPair.shared
    func carv2DataPair(_ dataPair: Carv2DataPair, didUpdateLeft leftData: Carv2Data) {
            print("left データが更新されました: \(leftData)")
            handleRightChange(leftData)
        }

    
        
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

