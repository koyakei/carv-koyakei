//
//  SkateBoardView.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/09/29.
//
import SwiftUI
import CoreMotion
import Spatial
import Combine
import Foundation
import CoreLocation

struct SkateBoardView: View {
    var body: some View {
        Text("Hello, World!")
    }
    
    // モーションレコード
    // フォールライン方向の
    //
}

@MainActor
final class SkateBoardDataManager: ObservableObject{
    
    @Published var rawData: SkateBoardRawData = .init()
    @Published var analysedData: SkateBoardAnalysedData
    @Published var latestNotCompletedTurn: [SkateBoardAnalysedData]  = []
    @Published var finishedTurnDataArray: [SingleFinishedTurnData] = []
    @Published var cmDeviceMotion: CMDeviceMotion? = nil
    let coreMotionManager: CMMotionManager = .init()
    var droggerBluetooth: DroggerBluetoothModel = .init()
    
    private var cancellables = Set<AnyCancellable>()
    @Published var numberOfTurn: Int = 0
    init( analysedData: SkateBoardAnalysedData) {
        
        self.analysedData = analysedData
    }
    private var lastFinishedTrunData: SingleFinishedTurnData {
        get {
            finishedTurnDataArray.last ?? .init(numberOfTrun: 0, turnPhases: [])
        }
    }
    
    private func subscribe() {
        $cmDeviceMotion
            .compactMap { $0 }
            .map{SkateBoardRawData($0)}
            .assign(to: \.rawData, on: self)
            .store(in: &cancellables)
        droggerBluetooth.$rtkDevice.compactMap{ $0 }.compactMap{$0.clLocation}.compactMap{$0}.combineLatest($rawData) { clLocation, rawData in
            SkateBoardAnalysedData(rawData, with: clLocation, isTurnSwitching: self.isTurnSwithching(rotationAngle: rawData.angulerVelocity))
        }.sink{ [weak self] (data: SkateBoardAnalysedData) in
            guard let self = self else { return }
            self.analysedData = data
            self.latestNotCompletedTurn.append(data)
            if data.isTurnSwitching {
                self.finishedTurnDataArray.append(.init(numberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurn))
                self.latestNotCompletedTurn.removeAll()
                self.numberOfTurn += 1
            }
        }.store(in: &cancellables)
    }
    @Published var switchingAngluerRateDegree: Float = 15
    
    func isTurnSwithching(rotationAngle: Vector3DFloat) -> Bool{
        (Angle2DFloat(degrees: -switchingAngluerRateDegree).radians..<Angle2DFloat(degrees: switchingAngluerRateDegree).radians ~= rawData.angulerVelocity.z && rawData.timestamp.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.4)
    }
    
    func startRecording(){
        coreMotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { [weak self] data, _ in
            self?.cmDeviceMotion = data
        }
    }
    
    struct SingleFinishedTurnData {
        let numberOfTrun: Int
        var turnPhases: [SkateBoardAnalysedData]
        
        var turnStartedTime: Date {
            firstPhaseOfTune.timestamp
        }
        
        var turnEndedTime: Date {
            lastPhaseOfTune.timestamp
        }
        
        var turnDuration: TimeInterval {
            turnEndedTime.timeIntervalSince(turnStartedTime)
        }
        
        var diffrencialAngleFromStartToEnd: Angle2DFloat {
            (lastPhaseOfTune.attitude * firstPhaseOfTune.attitude.inverse).angle
        }
        
        var firstPhaseOfTune: SkateBoardAnalysedData {
            turnPhases[safe: 0, default: .init()]
        }
        var lastPhaseOfTune: SkateBoardAnalysedData {
            turnPhases[safe: turnPhases.endIndex - 1, default: .init()]
        }
    }
}

extension simd_quatf{
    init(_ val: simd_quatd){
        self.init(ix: Float(val.vector.x), iy: Float(val.vector.y), iz: Float(val.vector.z), r: Float(val.vector.w))
    }
}

struct SkateBoardRawData{
    init(_ deviceMotion: CMDeviceMotion) {
        self.acceleration = Vector3DFloat(x: Float(deviceMotion.userAcceleration.x),y: Float(deviceMotion.userAcceleration.y), z: Float(deviceMotion.userAcceleration.z))
        self.attitude = Rotation3DFloat(quaternion: simd_quatf( deviceMotion.attitude.quaternion.simdQuat))
        self.angulerVelocity = Vector3DFloat(x: Float(deviceMotion.rotationRate.x), y: Float(deviceMotion.rotationRate.y), z: Float(deviceMotion.rotationRate.z))
        self.timestamp = Date(timeIntervalSince1970: deviceMotion.timestamp)
    }
    init(){
        attitude = .identity
        acceleration = .zero
        angulerVelocity = .zero
        timestamp = Date()
    }
    let acceleration: Vector3DFloat
    let attitude: Rotation3DFloat
    let angulerVelocity: Vector3DFloat
    let timestamp: Date
}

struct SkateBoardAnalysedData{
    let fallLineAcceleration: Float
    let location: CLLocation
    let timestamp: Date
    let othogonalAcceleration: Float
    let acceleration: Vector3DFloat
    let attitude: Rotation3DFloat
    let angulerVelocity: Vector3DFloat
    let isTurnSwitching: Bool
    init(_ rawData: SkateBoardRawData, with location: CLLocation, isTurnSwitching: Bool ) {
        self.fallLineAcceleration = 0
        self.location = location
        self.timestamp = rawData.timestamp
        self.othogonalAcceleration = 0
        self.acceleration = rawData.acceleration
        self.attitude = rawData.attitude
        self.angulerVelocity = rawData.angulerVelocity
        self.isTurnSwitching = isTurnSwitching
    }
    init(){
        fallLineAcceleration = 0
        location = CLLocation(latitude: 0, longitude: 0)
        timestamp = Date()
        othogonalAcceleration = 0
        acceleration = .zero
        attitude = .identity
        angulerVelocity = .zero
        isTurnSwitching = false
    }
}


