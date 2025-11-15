//
//  SkateBoardDataManager.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/10/03.
//

import SwiftUI
import CoreMotion
import Spatial
import Combine
import Foundation
import CoreLocation
import WatchConnectivity


final class SkateBoardDataManager:NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var rawData: SkateBoardRawData = .init()
    @Published var analysedData: SkateBoardAnalysedData
    @Published var latestNotCompletedTurn: [SkateBoardAnalysedData]  = []
    let coreMotionManager: CMMotionManager = .init()
    let headMotionManager: CMHeadphoneMotionManager = .init()
//    let droggerBluetooth: DroggerBluetoothModel
    @Published var headMotion: HeadMotionRawData = .init()
    @Published var headBoardDiffrencial: Rotation3DFloat = .identity
    private var cancellables = Set<AnyCancellable>()
    @Published var numberOfTurn: Int = 0
    var session : WCSession
    var modelContext: ModelContext
    
    @Published var finishedTurnDataArray: [SingleFinishedTurnData] = []
    
    @MainActor
    init( analysedData: SkateBoardAnalysedData,modelContext: ModelContext,session: WCSession = .default) {
        self.analysedData = analysedData
        self.session = session
        self.modelContext = modelContext
        super.init()
        if WCSession.isSupported() {
            self.session.delegate = self
            Task { @MainActor in
                self.session.activate()
            }
        }
    }
    
    private func sendFinishedTurnCountToWatch() {
        guard WCSession.isSupported(), WCSession.default.isPaired, WCSession.default.isWatchAppInstalled else { return }
        let message = ["finishedTurnCount": self.finishedTurnDataArray.count]
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
            print("Failed to send turn count to watch: \(error)")
        })
    }
    
    var lastFinishedTrunData: SingleFinishedTurnData {
        get {
            finishedTurnDataArray.last ?? SingleFinishedTurnData.init(numberOfTrun: 0, turnPhases: [])
        }
    }
    
    private func percentageOfTurnsByAngle(_ rawData: SkateBoardRawData, diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat)-> Float{
        abs((rawData.attitude * lastTurnFinishedTurnPhaseAttitude.inverse).angle.radians) / abs(diffrencialAnleFromStartoEnd)
    }
    
    @Published var switchingAngluerRateDegree: Float = 15
    
    func isTurnSwithching(turnPhase: SkateBoardRawData,rotationAngle: Vector3DFloat) -> Bool{
        (Angle2DFloat(degrees: -switchingAngluerRateDegree).radians..<Angle2DFloat(degrees: switchingAngluerRateDegree).radians ~= turnPhase.angulerVelocity.z && turnPhase.timestamp.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.5)
    }
    
    func calibrateHeadBoardDifference(){
        self.headBoardDiffrencial = headMotion.attitude.inverse.rotated(by:rawData.attitude)
        self.headBoardDiffrencialCalubratedAttitudeTrueNorthZVertical = rawData.attitude
    }
    
    var headBoardDiffrencialCalubratedAttitudeTrueNorthZVertical : Rotation3DFloat  = .identity
    
    var headStartRecordingDate: Date = Date.now
    var boardStartRecordingDate: Date = Date.now
    func startHeadAndBoardMotionRecording(){
        self.headStartRecordingDate = Date.now
        // head のほうが常に古い値がheadmotion から発行される　どこにボトルネックがあるのか＿
        coreMotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { [weak self] data, _ in
            guard let self = self else { return }
            guard let value = data else { return }
            self.rawData = SkateBoardRawData(value, Date(timeIntervalSince1970: self.boardStartRecordingDate.timeIntervalSince1970 + value.timestamp))
        }
        headMotionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self = self else { return }
            if let data = data {
                self.headMotion = HeadMotionRawData(data, Date(timeIntervalSince1970: self.headStartRecordingDate.timeIntervalSince1970 + data.timestamp))
            }
        }
        $rawData.compactMap{$0}.combineLatest($headMotion.compactMap{$0}).sink { [self] (rawData, headMotion) in
            let skatebordData = SkateBoardAnalysedData(rawData, with: CLLocation(), isTurnSwitching: self.isTurnSwithching(turnPhase: rawData,rotationAngle: rawData.angulerVelocity), fallLineDirection: self.finishedTurnDataArray.lastTurn.fallLineDirection, diffrencialAnleFromStartoEnd: self.lastFinishedTrunData.diffrencialAngleFromStartToEnd.radians, lastTurnFinishedTurnPhaseAttitude: self.lastFinishedTrunData.lastPhaseOfTune.attitude,
                                                       headAttitude: headMotion.attitude, // truenorth zvertical な値を出してほしい
                                                       headAngulerVelocity: headMotion.angulerVelocity, headAcceleration: headMotion.acceleration,headBodyDiffrencial: self.headBoardDiffrencial)
            self.analysedData = skatebordData
            self.latestNotCompletedTurn.append(skatebordData)
            if skatebordData.isTurnSwitching {
                let lastTurn = SingleFinishedTurnData.init(numberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurn)
                modelContext.insert(lastTurn)
        
                self.finishedTurnDataArray.append(lastTurn)
                self.latestNotCompletedTurn.removeAll()
                self.numberOfTurn += 1
            }
        }
        .store(in: &cancellables)
        self.boardStartRecordingDate = Date.now
        
    }
    
    func startRecording(){
        coreMotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { [weak self] data, _ in
            guard let value = data else { return }
            guard let self = self else { return }
            self.boardStartRecordingDate = Date.now
            self.rawData = SkateBoardRawData(value, Date(timeIntervalSince1970: self.boardStartRecordingDate.timeIntervalSince1970 + value.timestamp))
            let skatebordData = SkateBoardAnalysedData(rawData, with: CLLocation(), isTurnSwitching: self.isTurnSwithching(turnPhase: rawData,rotationAngle: rawData.angulerVelocity), fallLineDirection: self.finishedTurnDataArray.lastTurn.fallLineDirection, diffrencialAnleFromStartoEnd: self.lastFinishedTrunData.diffrencialAngleFromStartToEnd.radians, lastTurnFinishedTurnPhaseAttitude: self.lastFinishedTrunData.lastPhaseOfTune.attitude, headBodyDiffrencial: self.headBoardDiffrencial)
            self.analysedData = skatebordData
            self.latestNotCompletedTurn.append(skatebordData)
            if skatebordData.isTurnSwitching {
                let lastTurn = SingleFinishedTurnData.init(numberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurn)
                modelContext.insert(lastTurn)
                
                self.finishedTurnDataArray.append(lastTurn)
                self.latestNotCompletedTurn.removeAll()
                self.numberOfTurn += 1
            }
        }
    }
    
    func stopRecording(){
        coreMotionManager.stopDeviceMotionUpdates()
        if headMotionManager.isDeviceMotionAvailable{
            headMotionManager.stopDeviceMotionUpdates()
        }
    }
    // To convert:
    func flatten(turnData:
                 SingleFinishedTurnData) -> [TurnPhase] {
        
        return turnData.turnPhases.map { TurnPhase(numberOfTurn: turnData.numberOfTrun, turnPhase: .init($0, ywingSide: turnData.yawingSide, fallLineDirection: turnData.fallLineDirection,diffrencialAnleFromStartoEnd: turnData.diffrencialAngleFromStartToEnd.radians, lastTurnFinishedTurnPhaseAttitude: turnData.firstPhaseOfTune.attitude,headAttitude: $0.headAttitude, headAngulerVelocity: $0.headAngulerVelocity, headAcceleration: $0.acceleration, headBodyDiffrencial: $0.headBoardDiffrencial)) }
    }
    
    func export(){
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
            encoder.dateEncodingStrategy = .custom { date, encoder in
                var container = encoder.singleValueContainer()
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let dateString = iso8601Formatter.string(from: date)
                try container.encode(dateString)
            }
            
            // データをJSONにエンコード
            let jsonData = try encoder.encode(finishedTurnDataArray.map{flatten(turnData: $0)}.flatMap(\.self))
            let df = DateFormatter()
            df.dateFormat = "yyyy年MM月dd日HH:mm:ss"
            
            // 保存先URL (例: Documentsディレクトリ下のperson.json)
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            if let documentURL = urls.first {
                let fileURL = documentURL.appendingPathComponent("runData\(df.string(from: finishedTurnDataArray[safe: 1, default: .init(numberOfTrun: 0, turnPhases: [])].turnStartedTime)).json")
                // ファイルへ書き込み
                try jsonData.write(to: fileURL)
                print("JSONファイルを保存しました: \(fileURL)")
            }
        } catch let EncodingError.invalidValue(value, context) {
            print("エンコード失敗 (invalidValue): value=\(value), codingPath=\(context.codingPath.map(\.stringValue).joined(separator: ".")), debug=\(context.debugDescription)")
        } catch {
            // より詳細なファイル書き込みエラーのログ
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain {
                switch CocoaError.Code(rawValue: nsError.code) {
                case .fileWriteNoPermission:
                    print("ファイル書き込み失敗: 権限がありません。詳細=\(nsError.localizedDescription)")
                case .fileWriteOutOfSpace:
                    print("ファイル書き込み失敗: 空き容量が不足しています。詳細=\(nsError.localizedDescription)")
                case .fileWriteFileExists:
                    print("ファイル書き込み失敗: 同名のファイルが既に存在します。詳細=\(nsError.localizedDescription)")
                case .fileNoSuchFile, .fileReadNoSuchFile:
                    print("ファイル書き込み失敗: ディレクトリ/ファイルが見つかりません。詳細=\(nsError.localizedDescription)")
                case .fileWriteInvalidFileName:
                    print("ファイル書き込み失敗: 無効なファイル名です。詳細=\(nsError.localizedDescription)")
                case .fileWriteUnknown:
                    print("ファイル書き込み失敗: 不明な理由で失敗しました。詳細=\(nsError.localizedDescription)")
                default:
                    print("ファイル書き込み失敗: CocoaError(\(nsError.code)) 詳細=\(nsError.localizedDescription)")
                }
            } else {
                print("エクスポートに失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    @Model
    final class SingleFinishedTurnData : SingleFinishedTurn{
        var turnPhases: [SkateBoardAnalysedData]
        
        init(numberOfTrun: Int, turnPhases: [SkateBoardAnalysedData]) {
            self.numberOfTrun = numberOfTrun
            self.turnPhases = turnPhases
        }
        var numberOfTrun: Int
    }
    
    struct TurnPhase : Encodable{
        let numberOfTurn: Int
        let turnPhase: SkateBoardAnalysedData
    }
    
    // MARK: - WCSessionDelegate 
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["command"] as? String == "export" {
                self.export()
        }
        if message["command"] as? String == "stop" {
                self.stopRecording()
        }
//        if message["command"] as? String == "clear" {
//            self.finishedTurnDataArray.removeAll()
//        }
        if message["command"] as? String == "startHeadAndBoard" {
                self.startHeadAndBoardMotionRecording()
        }
    }
}

extension Array where Element == SkateBoardDataManager.SingleFinishedTurnData{
    var lastTurn : SkateBoardDataManager.SingleFinishedTurnData{
        self.last ?? .init(numberOfTrun: 0, turnPhases: [])
    }
}

final class HeadMotionRawData: ObservableObject{
    var acceleration: Vector3DFloat
    let attitude: Rotation3DFloat
    let angulerVelocity: Vector3DFloat
    let timestamp: Date
    init(_ deviceMotion: CMDeviceMotion ,_ date: Date) {
        self.acceleration = Vector3DFloat(x: Float(deviceMotion.userAcceleration.x),y: Float(deviceMotion.userAcceleration.y), z: Float(deviceMotion.userAcceleration.z))
        self.attitude = Rotation3DFloat(quaternion: simd_quatf( deviceMotion.attitude.quaternion.simdQuat))
        self.angulerVelocity = Vector3DFloat(x: Float(deviceMotion.rotationRate.x), y: Float(deviceMotion.rotationRate.y), z: Float(deviceMotion.rotationRate.z))
        self.timestamp = date
    }
    init(){
        acceleration = .zero
        attitude = .identity
        angulerVelocity = .zero
        timestamp = Date()
    }
}

final class SkateBoardRawData: ObservableObject{
    init(_ deviceMotion: CMDeviceMotion,_ date: Date) {
        self.acceleration = Vector3DFloat(x: Float(deviceMotion.userAcceleration.x),y: Float(deviceMotion.userAcceleration.y), z: Float(deviceMotion.userAcceleration.z))
        self.attitude = Rotation3DFloat(quaternion: simd_quatf( deviceMotion.attitude.quaternion.simdQuat))
        self.angulerVelocity = Vector3DFloat(x: Float(deviceMotion.rotationRate.x), y: Float(deviceMotion.rotationRate.y), z: Float(deviceMotion.rotationRate.z))
        self.timestamp = date
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

import SwiftData
@Model
final class SkateBoardAnalysedData: Encodable {
    var fallLineAcceleration: Vector3DFloat {
        Vector3DFloat(x: Vector3DFloat(x: 1, y: 0, z: 0).rotated(by: relativeFallLineDirection).dot(acceleration), y: Vector3DFloat(x: 0, y: 1, z: 0).rotated(by: relativeFallLineDirection).dot(acceleration), z: Vector3DFloat(x: 0, y: 0, z: 1).rotated(by: relativeFallLineDirection).dot(acceleration))
    }
    
    var location: CLLocation{
        get{
            CLLocation(latitude: .init(latitude), longitude: .init(lontitude))
        }
    }
    var lontitude: Double
    var latitude: Double
    var timestamp: Date
    var acceleration: Vector3DFloat
    var attitude: Rotation3DFloat
    var angulerVelocity: Vector3DFloat
    var isTurnSwitching: Bool
    var fallLineDirection: Rotation3DFloat
    var percentageOfTurnsByAngle: Float
    
//    var headAttitudeWtioutCalibration: Rotation3DFloat
    
    var headAttitude: Rotation3DFloat
    var headAngulerVelocity: Vector3DFloat
    var headAcceleration: Vector3DFloat
    
    var yawingSide: TurnYawingSide
    
    var relativeFallLineDirection:Rotation3DFloat{
        fallLineDirection.rotated(by: attitude.inverse)
    }
    
    var headRelativeAttitudeAgainstBoard: Rotation3DFloat{
        headAttitudeCalibrated.rotated(by: attitude.inverse)//  attitude で回すのもやったけど　.inverse が固定できる。
    }
    
    var headAttitudeCalibrated : Rotation3DFloat{
        headAttitude.rotated(by: headBoardDiffrencial)
    }
    
    var headAttitudeZverticalTrueNorth: Rotation3DFloat{
        headRelativeAttitudeAgainstBoard * attitude
    }
    
    var headRelativeAttitudeAgainstFallLine: Rotation3DFloat{
        headAttitudeZverticalTrueNorth.rotated(by: fallLineDirection.inverse)
    }
    
    var headRelativeAccelerationBoardAhead: Vector3DFloat{
        Vector3DFloat(x: headAcceleration.rotated(by: headRelativeAttitudeAgainstBoard.inverse).dot(Vector3DFloat(x: 1, y: 0, z: 0)), y: headAcceleration.rotated(by: headRelativeAttitudeAgainstBoard.inverse).dot(Vector3DFloat(x: 0, y: 1, z: 0)), z: headAcceleration.rotated(by: headRelativeAttitudeAgainstBoard.inverse).dot(Vector3DFloat(x: 0, y: 0, z: 1)))
    }
    
    var headRelativeAccelerationBoardAhead2: Vector3DFloat{
        headAcceleration.projected(Vector3DFloat(x: 0, y: 0, z: 1).rotated(by: headRelativeAttitudeAgainstBoard.inverse))
    }
    
    var headRelativeAccelerationBoardAhead3: Vector3DFloat{
        headAcceleration.projected(Vector3DFloat(x: 0, y: 1, z: 0).rotated(by: headRelativeAttitudeAgainstBoard.inverse))
    }
    
    var headRelativeAccelerationFallLineAhead: Vector3DFloat{
//        headAcceleration.projected(Vector3DFloat(x: 0, y: 1, z: 0).rotated(by: headAttitudeCalibrated.inverse))
        Vector3DFloat(x: headAcceleration.rotated(by: headRelativeAttitudeAgainstFallLine.inverse).dot(Vector3DFloat(x: 1, y: 0, z: 0)), y: headAcceleration.rotated(by: headRelativeAttitudeAgainstFallLine.inverse).dot(Vector3DFloat(x: 0, y: 1, z: 0)), z: headAcceleration.rotated(by: headRelativeAttitudeAgainstFallLine.inverse).dot(Vector3DFloat(x: 0, y: 0, z: 1)))
    }
    
    var headRelativeFallLineAccelerationAgainstBoard: Vector3DFloat{
        headRelativeAccelerationFallLineAhead - fallLineAcceleration
    }
    
    
    var headRelativeAccelerationAgainstBoard: Vector3DFloat{
        headRelativeAccelerationBoardAhead - acceleration
    }
    
    var headFallineAcceleration: Float{
        Vector3DFloat(x: 0, y: 1, z: 0).rotated(by: relativeFallLineDirection).dot(headAcceleration)
    }
    
    var orthogonalDirection:Vector3DFloat{
        switch yawingSide{
        case .RightYawing:
            Vector3DFloat(x: -1, y: 0, z: 0)
        case .LeftYawing:
            Vector3DFloat(x: 1, y: 0, z: 0)
        case .Straight:
            Vector3DFloat(x: 1, y: 0, z: 0)
        }
    }
    
    var othogonalAcceleration : Float{
        orthogonalDirection.rotated(by: relativeFallLineDirection).dot(acceleration)
    }
    
    // ターン終了前の分析用
    init(_ rawData: SkateBoardRawData, with location: CLLocation, isTurnSwitching: Bool , fallLineDirection : Rotation3DFloat , diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat, headAttitude : Rotation3DFloat = .init(),headAttitudeZverticalTrueNorth: Rotation3DFloat = .identity, headAngulerVelocity : Vector3DFloat = .init(), headAcceleration : Vector3DFloat = .init(),headBodyDiffrencial: Rotation3DFloat) {
        self.fallLineDirection = fallLineDirection
        self.lontitude = location.coordinate.longitude
        self.latitude = location.coordinate.latitude
        self.timestamp = rawData.timestamp
        self.acceleration = rawData.acceleration
        self.attitude = rawData.attitude
        self.angulerVelocity = rawData.angulerVelocity
        self.isTurnSwitching = isTurnSwitching
        self.headAttitude = headAttitude
        
        self.headAcceleration = headAcceleration
        
        self.headAngulerVelocity = headAngulerVelocity
        
        self.yawingSide = {
            switch rawData.angulerVelocity.z{
            case let x where x < 0:
                return .RightYawing
            case let x where x > 0:
                return .LeftYawing
            default:
                return .Straight
            }
        }()
        self.percentageOfTurnsByAngle = abs((rawData.attitude * lastTurnFinishedTurnPhaseAttitude.inverse).angle.radians) / abs(diffrencialAnleFromStartoEnd)
        self.headBoardDiffrencial = headBodyDiffrencial
    }
    
    var headBoardDiffrencial : Rotation3DFloat
    //ターン終了後の分析用
    init(_ rawData: SkateBoardAnalysedData, ywingSide : TurnYawingSide, fallLineDirection : Rotation3DFloat, diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat, headAttitude : Rotation3DFloat = .init(),headAttitudeZverticalTrueNorth: Rotation3DFloat = .identity, headAngulerVelocity : Vector3DFloat = .init(), headAcceleration : Vector3DFloat = .init(), headBodyDiffrencial : Rotation3DFloat) {
        self.lontitude = 0
        self.latitude = 0
        self.timestamp = rawData.timestamp
        self.acceleration = rawData.acceleration
        self.attitude = rawData.attitude
        self.angulerVelocity = rawData.angulerVelocity
        self.isTurnSwitching = rawData.isTurnSwitching
        self.fallLineDirection = fallLineDirection
        self.yawingSide = ywingSide
        self.percentageOfTurnsByAngle = abs((rawData.attitude * lastTurnFinishedTurnPhaseAttitude.inverse).angle.radians) / abs(diffrencialAnleFromStartoEnd)
        self.headAttitude = headAttitude
        self.headBoardDiffrencial = headBodyDiffrencial
        
        self.headAcceleration = headAcceleration
        
        self.headAngulerVelocity = headAngulerVelocity
    }
    
    init(headAttitude : Rotation3DFloat = .init(), headAngulerVelocity : Vector3DFloat = .init(), headAcceleration : Vector3DFloat = .init()){
        self.lontitude = 0
        self.latitude = 0
        timestamp = Date(timeIntervalSince1970: 0)
        acceleration = .zero
        attitude = .identity
        angulerVelocity = .zero
        isTurnSwitching = false
        yawingSide = .Straight
        fallLineDirection = .identity
        percentageOfTurnsByAngle = 0
        
        self.headAttitude = headAttitude
        
        self.headAcceleration = headAcceleration
        
        self.headAngulerVelocity = headAngulerVelocity
        headBoardDiffrencial = .identity
    }
    
    
    enum CodingKeys: String, CodingKey {
        case fallLineAcceleration
        case location
        case timestamp
        case othogonalAcceleration
        case acceleration
        case attitude
        case angulerVelocity
        case isTurnSwitching
        case percentageOfTurnsByAngle
        case attitudeAngle
        case yawingAngle
        case pitchingAngle
        case rollingAngle
        case headyawingAngle
        case headpitchingAngle
        case headrollingAngle
        case headAcceleration
        case headAngulerVelocity
        case headRelativeAccelerationBoardAhead
        case headRelativeAccelerationFallLineAhead
        case headRelativeFallLineAccelerationAgainstBoard
        case headRelativeAccelerationAgainstBoard
        case headFallineAcceleration
    }
    
    enum LocationKeys: String, CodingKey {
        case latitude, longitude, altitude
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fallLineAcceleration, forKey: .fallLineAcceleration)
        // Encode location as a nested object
//        var locContainer = container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
//        try locContainer.encode(location.coordinate.latitude, forKey: .latitude)
//        try locContainer.encode(location.coordinate.longitude, forKey: .longitude)
//        try locContainer.encode(location.altitude, forKey: .altitude)
        // Encode timestamp as ISO8601 string
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(isoFormatter.string(from: timestamp), forKey: .timestamp)
//        try container.encode(othogonalAcceleration, forKey: .othogonalAcceleration)
        try container.encode(acceleration, forKey: .acceleration)
//        try container.encode(attitude, forKey: .attitude)
//        try container.encode(attitude.angle.degrees, forKey: .attitudeAngle)
        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees, forKey: .pitchingAngle)
        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees, forKey: .rollingAngle)
        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees, forKey: .yawingAngle)
//        try container.encode(angulerVelocity, forKey: .angulerVelocity)
        try container.encode(isTurnSwitching, forKey: .isTurnSwitching)
        try container.encode(percentageOfTurnsByAngle, forKey: .percentageOfTurnsByAngle)
        try container.encode(headAcceleration, forKey: .headAcceleration)
//        try container.encode(headAngulerVelocity, forKey: .headAngulerVelocity)
        try container.encode(Angle2DFloat(radians: headAttitude.eulerAngles(order: .xyz).angles.x).degrees, forKey: .headpitchingAngle)
        try container.encode(Angle2DFloat(radians: headAttitude.eulerAngles(order: .xyz).angles.y).degrees, forKey: .headrollingAngle)
        try container.encode(Angle2DFloat(radians: headAttitude.eulerAngles(order: .xyz).angles.z).degrees, forKey: .headyawingAngle)
        try container.encode(headRelativeAccelerationBoardAhead, forKey: .headRelativeAccelerationBoardAhead)
        try container.encode(headRelativeAccelerationFallLineAhead, forKey: .headRelativeAccelerationFallLineAhead)
        try container.encode(headRelativeFallLineAccelerationAgainstBoard, forKey: .headRelativeFallLineAccelerationAgainstBoard)
        try container.encode(headRelativeAccelerationAgainstBoard, forKey: .headRelativeAccelerationAgainstBoard)
        try container.encode(headFallineAcceleration, forKey: .headFallineAcceleration)
    }
}

