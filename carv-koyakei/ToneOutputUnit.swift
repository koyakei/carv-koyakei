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

struct ToneStep{
    static func hight(_ num : Float) -> Float {
        let base : Float = 440.0
        let min: Float = -24
        return base * pow(pow(2, num + min), 1/12)
    }
}

struct DynamicOscillatorData {
    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 0
    var detuningOffset: AUValue = 440
}

class DynamicOscillatorConductor: ObservableObject {

    let engine = AudioEngine()

    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }

    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }

    @Published var data = DynamicOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
                osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)
                osc.$detuningOffset.ramp(to: data.detuningOffset, duration: data.rampDuration)
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

    var osc = DynamicOscillator()

    init() {
        engine.output = osc
    }

    func start() {
        osc.amplitude = 0.2
        do {
            try engine.start()
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

class SineWave {

    
    var oscillator = Oscillator()
    
    private enum Fade {
        case none
        case `in`
        case out
    }

    private let audioEngine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var buffer: AVAudioPCMBuffer!
    private var fadeInBuffer: AVAudioPCMBuffer!
    private var fadeOutBuffer: AVAudioPCMBuffer!
    private let semaphore = DispatchSemaphore(value: 0)

    var volume: Float = 0.1 {
        didSet { updateBuffers() }
    }

    var hz: Float = 600 {
        didSet { updateBuffers() }
    }
    static public var shared = SineWave.init()
    
    init(volume: Float = 0.1, hz: Float = 600) {
        self.volume = volume
        self.hz = hz
        let audioFormat = player.outputFormat(forBus: 0)
        updateBuffers()
        audioEngine.attach(player)
        audioEngine.connect(player, to: audioEngine.mainMixerNode, format: audioFormat)
        audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch {
            print(error.localizedDescription)
        }
    }

    deinit {
        stopEngine()
    }

    func updateBuffers() {
        buffer = makeBuffer()
        fadeInBuffer = makeBuffer(fade: .in)
        fadeOutBuffer = makeBuffer(fade: .out)
    }

    private func makeBuffer(fade: Fade = .none) -> AVAudioPCMBuffer {
        let audioFormat = player.outputFormat(forBus: 0)
        let sampleRate = Float(audioFormat.sampleRate) // 44100.0
        let length = AVAudioFrameCount(sampleRate / hz)
        let capacity = fade == .none ? length : 15 * length
        guard let buf = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: capacity) else {
            fatalError("Error initializing AVAudioPCMBuffer")
        }
        buf.frameLength = capacity
//        let u = Float.pi / Float(capacity)
        for n in (0 ..< Int(capacity)) {
            let power: Float
//            switch fade {
//            case .none: power = 1.0
//            case .in:   power = 0.5 * (1.0 - cosf(Float(n) * u))
//            case .out:  power = 0.5 * (1.0 + cosf(Float(n) * u))
//            }
            power = 1.0
            let value = power * volume * sinf(Float(n) * 2.0 * Float.pi / Float(length))
            buf.floatChannelData?.advanced(by: 0).pointee[n] = value
            buf.floatChannelData?.advanced(by: 1).pointee[n] = value
        }
        return buf
    }

    func play() {
        
        oscillator.play()
        if audioEngine.isRunning {
            player.play()
            player.scheduleBuffer(fadeInBuffer) { [weak self] in
                self?.semaphore.signal()
            }
            player.scheduleBuffer(buffer, at: nil, options: .loops)
        }
    }

    func pause() {
        if player.isPlaying {
            switch semaphore.wait(timeout: .now()) {
            case .success:
//                self.pause()
//                break
                player.scheduleBuffer(fadeOutBuffer, at: nil,
                                      options: .interruptsAtLoop,
                                      completionHandler: { [weak self] in
                                          self?.player.pause()
                                      })
            case .timedOut:
                break
            }
        }
    }

    func stopEngine() {
        pause()
        if audioEngine.isRunning {
            audioEngine.disconnectNodeOutput(player)
            audioEngine.detach(player)
            audioEngine.stop()
        }
    }

}
