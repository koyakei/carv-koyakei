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
class YawingBeep: Carv2DataPairDelegate{
    func carv2DataPairUpdate(_ dataPair: Carv2DataPair, didUpdateLeft oneSideDataData: Carv2Data) {
        handleRightChange()
    }
    
    var isBeeping: Bool = false {
        didSet{
            if isBeeping {
                conductor.start()
            } else {
                conductor.stop()
            }
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    var diffYawingTargetAngle: Float = 2.0
    var conductor : DynamicOscillatorConductor = DynamicOscillatorConductor()
    init(yawingAngulerRateDiffrential: Float = 0.0) {
    }
    var yawingAngulerRateDiffrential : Float = 0.0
        {
            didSet {
                handleRightChange()
            }
        }
    
    func isInTargetAngleRange() -> Bool {
        return (-diffYawingTargetAngle...diffYawingTargetAngle).contains(yawingAngulerRateDiffrential )
    }
    

    private func handleRightChange() {
        if isBeeping == false {
            conductor.data.isPlaying = false
            return
        }
        if isInTargetAngleRange() {
            conductor.data.isPlaying = false
        } else {
            conductor.data.isPlaying = true
        }
        if yawingAngulerRateDiffrential > 0 {
            conductor.data.frequency = AUValue(hight(ceil(
                yawingAngulerRateDiffrential * 10)))
            conductor.changeWaveFormToSin()
        } else {
            conductor.changeWaveFormToTriangle()
            conductor.data.frequency = AUValue(lowToHigh(-ceil(yawingAngulerRateDiffrential * 10)))
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

