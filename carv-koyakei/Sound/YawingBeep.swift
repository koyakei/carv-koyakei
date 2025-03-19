//
//  YawingBeep.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/03/17.
//


import AudioKit
import Foundation
import Combine
class YawingBeep:ObservableObject{
    
    var conductor : DynamicOscillatorConductor
    init(carv2DataPair :Carv2DataPair ,conductor : DynamicOscillatorConductor) {
        self.conductor = conductor
        self.carv2DataPair = carv2DataPair
    }
    var cancellables = Set<AnyCancellable>()
    var carv2DataPair :Carv2DataPair
        
    func beepObserver(){
        if isBeeping {
            if (-diffYawingTargetAngle...diffYawingTargetAngle).contains(Double(carv2DataPair.yawingAngulerRateDiffrential) ) {
                conductor.data.isPlaying = false
            } else {
                conductor.data.isPlaying = true
            }
            if carv2DataPair.yawingAngulerRateDiffrential > 0 {
                conductor.panner.pan = 1.0
                conductor.data.frequency = AUValue(ToneStep.lowToHigh(ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
                conductor.changeWaveFormToSin()
            } else {
                conductor.panner.pan = -1.0
                conductor.changeWaveFormToTriangle()
                conductor.data.frequency = AUValue(ToneStep.hight(ceil(carv2DataPair.yawingAngulerRateDiffrential * 10)))
            }
        }
        
    }
    var diffYawingTargetAngle: Double = 2.0
    var isBeeping:Bool = false
    func startBeep(){
        carv2DataPair.objectWillChange.sink { _ in
            self.beepObserver()
        }
        isBeeping = true
    }
    
    func stopBeep(){
        isBeeping = false
    }
    
}
