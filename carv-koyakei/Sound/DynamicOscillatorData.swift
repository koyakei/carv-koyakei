//
//  DynamicOscillatorData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/11.
//
import AVFoundation

struct DynamicOscillatorData {
    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var amplitude: AUValue = 1.0
    var rampDuration: AUValue = 0
    var detuningOffset: AUValue = 440
    var balance: AUValue = 1.0
}
