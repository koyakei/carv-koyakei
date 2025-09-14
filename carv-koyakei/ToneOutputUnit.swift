//
//  ToneOutputUnit.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/11/02.
//

import Foundation
import AVFoundation
import UIKit
import AudioKit
import AudioToolbox
import SoundpipeAudioKit
import Combine


class DynamicOscillatorConductor {
    let engine = AudioEngine()
    var osc = DynamicOscillator()
    var panner : Panner
    
    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }
    
    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }
    
    var data = DynamicOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.amplitude = 1.0
            } else {
                osc.amplitude = 0.0
            }
        }
    }
    
    func changeWaveFormToTriangle(){
        osc.setWaveform(Table(.positiveSawtooth))
    }
    
    func changeWaveFormToSin(){
        osc.setWaveform(Table(.triangle))
    }
    
    func changeWaveFormToSquare(){
        osc.setWaveform(Table(.sawtooth))
    }
    
    init() {
        let mixer = Mixer(osc)
        mixer.volume = 1.0
        panner = Panner(mixer)
        engine.output = panner
    }
    
    func start() {
        osc.amplitude = 1
        do {
            try engine.start()
            osc.start()
            osc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)
            osc.$detuningOffset.ramp(to: data.detuningOffset, duration: data.rampDuration)
        } catch let err {
            Log(err)
        }
    }
    
    func stop() {
        data.isPlaying = false
        osc.stop()
        engine.stop()
    }
}
