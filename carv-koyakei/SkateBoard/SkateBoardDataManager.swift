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

@MainActor
final class SkateBoardDataManager: ObservableObject{
    
    @Published var rawData: SkateBoardRawData = .init()
    @Published var analysedData: SkateBoardAnalysedData
    @Published var latestNotCompletedTurn: [SkateBoardAnalysedData]  = []
    @Published var finishedTurnDataArray: [SingleFinishedTurnData] = []
    @Published var cmDeviceMotion: CMDeviceMotion? = nil
    let coreMotionManager: CMMotionManager = .init()
    let droggerBluetooth: DroggerBluetoothModel
    
    private var cancellables = Set<AnyCancellable>()
    @Published var numberOfTurn: Int = 0
    init( analysedData: SkateBoardAnalysedData, droggerBluetooth: DroggerBluetoothModel) {
        self.droggerBluetooth = droggerBluetooth
        self.analysedData = analysedData
    }
    var lastFinishedTrunData: SingleFinishedTurnData {
        get {
            finishedTurnDataArray.last ?? .init(numberOfTrun: 0, turnPhases: [])
        }
    }
    
    private func percentageOfTurnsByAngle(_ rawData: SkateBoardRawData, diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat)-> Float{
        abs((rawData.attitude * lastTurnFinishedTurnPhaseAttitude.inverse).angle.radians) / abs(diffrencialAnleFromStartoEnd)
    }
    
    private func subscribe() {
//        droggerBluetooth.$rtkDevice.compactMap{ $0 }.compactMap{$0.clLocation}.compactMap{$0}.combineLatest($rawData) { clLocation, rawData in
//            SkateBoardAnalysedData(rawData, with: clLocation, isTurnSwitching: self.isTurnSwithching(rotationAngle: rawData.angulerVelocity), fallLineDirection: self.finishedTurnDataArray.lastTurn.fallLineDirection)
//        }
//        .sink{ [weak self] (data: SkateBoardAnalysedData) in
//            guard let self = self else { return }
//            self.analysedData = data
//            self.latestNotCompletedTurn.append(data)
//            if data.isTurnSwitching {
//                self.finishedTurnDataArray.append(.init(numberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurn))
//                self.latestNotCompletedTurn.removeAll()
//                self.numberOfTurn += 1
//            }
//        }.store(in: &cancellables)
    }
    @Published var switchingAngluerRateDegree: Float = 15
    
    func isTurnSwithching(turnPhase: SkateBoardRawData,rotationAngle: Vector3DFloat) -> Bool{
        (Angle2DFloat(degrees: -switchingAngluerRateDegree).radians..<Angle2DFloat(degrees: switchingAngluerRateDegree).radians ~= turnPhase.angulerVelocity.z && turnPhase.timestamp.timeIntervalSince1970 - self.lastFinishedTrunData.turnEndedTime.timeIntervalSince1970 > 0.4)
    }
    
    func startRecording(){
        coreMotionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { [weak self] data, _ in
            guard let value = data else { return }
            guard let self = self else { return }
            let rawData = SkateBoardRawData(value)
            let skatebordData = SkateBoardAnalysedData(rawData, with: CLLocation(), isTurnSwitching: self.isTurnSwithching(turnPhase: rawData,rotationAngle: rawData.angulerVelocity), fallLineDirection: self.finishedTurnDataArray.lastTurn.fallLineDirection, diffrencialAnleFromStartoEnd: self.lastFinishedTrunData.diffrencialAngleFromStartToEnd.radians, lastTurnFinishedTurnPhaseAttitude: self.lastFinishedTrunData.lastPhaseOfTune.attitude)
            self.analysedData = skatebordData
            self.latestNotCompletedTurn.append(skatebordData)
            if skatebordData.isTurnSwitching {
                self.finishedTurnDataArray.append(.init(numberOfTrun: self.numberOfTurn, turnPhases: self.latestNotCompletedTurn))
                self.latestNotCompletedTurn.removeAll()
                self.numberOfTurn += 1
            }
        }
    }
    
    func stopRecording(){
        coreMotionManager.stopDeviceMotionUpdates()
    }
    
    
    // To convert:
    func flatten(turnData:
                 SingleFinishedTurnData) -> [TurnPhase] {
        return turnData.turnPhases.map { TurnPhase(numberOfTurn: turnData.numberOfTrun, turnPhase: .init($0, ywingSide: turnData.yawingSide, fallLineDirection: turnData.fallLineDirection,diffrencialAnleFromStartoEnd: turnData.diffrencialAngleFromStartToEnd.radians, lastTurnFinishedTurnPhaseAttitude: turnData.firstPhaseOfTune.attitude)) }
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
    
    struct SingleFinishedTurnData {
        let numberOfTrun: Int
        var turnPhases: [SkateBoardAnalysedData]
        
        var yawingSide: TurnYawingSide {
            switch turnPhases.map(\.angulerVelocity.z).reduce(0,+){
            case let x where x < 0:
                return .RightYawing
            case let x where x > 0:
                return .LeftYawing
            default:
                return .Straight
            }
        }
        
        var turnStartedTime: Date {
            firstPhaseOfTune.timestamp
        }
        
        var turnEndedTime: Date {
            lastPhaseOfTune.timestamp
        }
        
        var turnDuration: TimeInterval {
            turnEndedTime.timeIntervalSince(turnStartedTime)
        }
        
        var fallLineDirection: Rotation3DFloat{
            Rotation3DFloat(quaternion: turnPhases.map{ $0.attitude.quaternion}.reduce(simd_quatf(), +))
        }
        
        
        var diffrencialAngleFromStartToEnd: Angle2DFloat {
            (lastPhaseOfTune.attitude * firstPhaseOfTune.attitude.inverse).angle
        }
        
        var firstPhaseOfTune: SkateBoardAnalysedData {
            turnPhases.first ?? .init()
        }
        var lastPhaseOfTune: SkateBoardAnalysedData {
            turnPhases.last ?? .init()
        }
    }
    
    struct TurnPhase : Encodable{
        let numberOfTurn: Int
        let turnPhase: SkateBoardAnalysedData
    }
}

extension Array where Element == SkateBoardDataManager.SingleFinishedTurnData{
    var lastTurn : SkateBoardDataManager.SingleFinishedTurnData{
        self.last ?? .init(numberOfTrun: 0, turnPhases: [])
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

struct SkateBoardAnalysedData: Encodable {
    var fallLineAcceleration: Float {
        Vector3DFloat(x: 0, y: 1, z: 0).rotated(by: relativeFallLineDirection).dot(acceleration)
    }
    let location: CLLocation
    let timestamp: Date
    let acceleration: Vector3DFloat
    let attitude: Rotation3DFloat
    let angulerVelocity: Vector3DFloat
    let isTurnSwitching: Bool
    let fallLineDirection: Rotation3DFloat
    let percentageOfTurnsByAngle: Float
    
    var yawingSide: TurnYawingSide
    
    var relativeFallLineDirection:Rotation3DFloat{
        fallLineDirection.rotated(by: attitude.inverse)
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
    init(_ rawData: SkateBoardRawData, with location: CLLocation, isTurnSwitching: Bool , fallLineDirection : Rotation3DFloat , diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat) {
        self.fallLineDirection = fallLineDirection
        self.location = location
        self.timestamp = rawData.timestamp
        self.acceleration = rawData.acceleration
        self.attitude = rawData.attitude
        self.angulerVelocity = rawData.angulerVelocity
        self.isTurnSwitching = isTurnSwitching
        
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
    }
    
    //ターン終了後の分析用
    init(_ rawData: SkateBoardAnalysedData, ywingSide : TurnYawingSide, fallLineDirection : Rotation3DFloat, diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat) {
        self.location = rawData.location
        self.timestamp = rawData.timestamp
        self.acceleration = rawData.acceleration
        self.attitude = rawData.attitude
        self.angulerVelocity = rawData.angulerVelocity
        self.isTurnSwitching = rawData.isTurnSwitching
        self.fallLineDirection = fallLineDirection
        self.yawingSide = ywingSide
        self.percentageOfTurnsByAngle = abs((rawData.attitude * lastTurnFinishedTurnPhaseAttitude.inverse).angle.radians) / abs(diffrencialAnleFromStartoEnd)
    }
    
    init(){
        location = CLLocation(latitude: 0, longitude: 0)
        timestamp = Date(timeIntervalSince1970: 0)
        acceleration = .zero
        attitude = .identity
        angulerVelocity = .zero
        isTurnSwitching = false
        yawingSide = .Straight
        fallLineDirection = .identity
        percentageOfTurnsByAngle = 0
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
    }

    enum LocationKeys: String, CodingKey {
        case latitude, longitude, altitude
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fallLineAcceleration, forKey: .fallLineAcceleration)
        // Encode location as a nested object
        var locContainer = container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        try locContainer.encode(location.coordinate.latitude, forKey: .latitude)
        try locContainer.encode(location.coordinate.longitude, forKey: .longitude)
        try locContainer.encode(location.altitude, forKey: .altitude)
        // Encode timestamp as ISO8601 string
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(isoFormatter.string(from: timestamp), forKey: .timestamp)
        try container.encode(othogonalAcceleration, forKey: .othogonalAcceleration)
        try container.encode(acceleration, forKey: .acceleration)
        try container.encode(attitude, forKey: .attitude)
        try container.encode(attitude.angle.degrees, forKey: .attitudeAngle)
        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees, forKey: .pitchingAngle)
        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees, forKey: .rollingAngle)
        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees, forKey: .yawingAngle)
        try container.encode(angulerVelocity, forKey: .angulerVelocity)
        try container.encode(isTurnSwitching, forKey: .isTurnSwitching)
        try container.encode(percentageOfTurnsByAngle, forKey: .percentageOfTurnsByAngle)
    }
}
