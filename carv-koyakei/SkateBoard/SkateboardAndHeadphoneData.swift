////
////  Untitled.swift
////  carv-koyakei
////
////  Created by keisuke koyanagi on 2025/10/10.
////
//import Spatial
//import CoreLocation
//
//struct SkateboardAndHeadphoneData: Encodable {
//    var fallLineAcceleration: Float {
//        Vector3DFloat(x: 0, y: 1, z: 0).rotated(by: relativeFallLineDirection).dot(acceleration)
//    }
//    let location: CLLocation
//    let timestamp: Date
//    let acceleration: Vector3DFloat
//    let attitude: Rotation3DFloat
//    let angulerVelocity: Vector3DFloat
//    let isTurnSwitching: Bool
//    let fallLineDirection: Rotation3DFloat
//    let percentageOfTurnsByAngle: Float
//    let headAttitude: Rotation3DFloat
//    let headAngulerVelocity: Vector3DFloat
//    let headAcceleration: Vector3DFloat
//    
//    var yawingSide: TurnYawingSide
//    
//    var relativeFallLineDirection:Rotation3DFloat{
//        fallLineDirection.rotated(by: attitude.inverse)
//    }
//    
//    var orthogonalDirection:Vector3DFloat{
//        switch yawingSide{
//        case .RightYawing:
//            Vector3DFloat(x: -1, y: 0, z: 0)
//        case .LeftYawing:
//            Vector3DFloat(x: 1, y: 0, z: 0)
//        case .Straight:
//            Vector3DFloat(x: 1, y: 0, z: 0)
//        }
//    }
//    
//    var othogonalAcceleration : Float{
//        orthogonalDirection.rotated(by: relativeFallLineDirection).dot(acceleration)
//    }
//    
//    // ターン終了前の分析用
//    init(_ rawData: SkateBoardRawData, with location: CLLocation, isTurnSwitching: Bool , fallLineDirection : Rotation3DFloat , diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat) {
//        self.fallLineDirection = fallLineDirection
//        self.location = location
//        self.timestamp = rawData.timestamp
//        self.acceleration = rawData.acceleration
//        self.attitude = rawData.attitude
//        self.angulerVelocity = rawData.angulerVelocity
//        self.isTurnSwitching = isTurnSwitching
//        
//        self.yawingSide = {
//            switch rawData.angulerVelocity.z{
//            case let x where x < 0:
//                return .RightYawing
//            case let x where x > 0:
//                return .LeftYawing
//            default:
//                return .Straight
//            }
//        }()
//        self.percentageOfTurnsByAngle = abs((rawData.attitude * lastTurnFinishedTurnPhaseAttitude.inverse).angle.radians) / abs(diffrencialAnleFromStartoEnd)
//    }
//    
//    //ターン終了後の分析用
//    init(_ rawData: SkateBoardAnalysedData, ywingSide : TurnYawingSide, fallLineDirection : Rotation3DFloat, diffrencialAnleFromStartoEnd: Float, lastTurnFinishedTurnPhaseAttitude: Rotation3DFloat) {
//        self.location = rawData.location
//        self.timestamp = rawData.timestamp
//        self.acceleration = rawData.acceleration
//        self.attitude = rawData.attitude
//        self.angulerVelocity = rawData.angulerVelocity
//        self.isTurnSwitching = rawData.isTurnSwitching
//        self.fallLineDirection = fallLineDirection
//        self.yawingSide = ywingSide
//        self.percentageOfTurnsByAngle = abs((rawData.attitude * lastTurnFinishedTurnPhaseAttitude.inverse).angle.radians) / abs(diffrencialAnleFromStartoEnd)
//    }
//    
//    init(){
//        location = CLLocation(latitude: 0, longitude: 0)
//        timestamp = Date(timeIntervalSince1970: 0)
//        acceleration = .zero
//        attitude = .identity
//        angulerVelocity = .zero
//        isTurnSwitching = false
//        yawingSide = .Straight
//        fallLineDirection = .identity
//        percentageOfTurnsByAngle = 0
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case fallLineAcceleration
//        case location
//        case timestamp
//        case othogonalAcceleration
//        case acceleration
//        case attitude
//        case angulerVelocity
//        case isTurnSwitching
//        case percentageOfTurnsByAngle
//        case attitudeAngle
//        case yawingAngle
//        case pitchingAngle
//        case rollingAngle
//    }
//
//    enum LocationKeys: String, CodingKey {
//        case latitude, longitude, altitude
//    }
//
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(fallLineAcceleration, forKey: .fallLineAcceleration)
//        // Encode location as a nested object
//        var locContainer = container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
//        try locContainer.encode(location.coordinate.latitude, forKey: .latitude)
//        try locContainer.encode(location.coordinate.longitude, forKey: .longitude)
//        try locContainer.encode(location.altitude, forKey: .altitude)
//        // Encode timestamp as ISO8601 string
//        let isoFormatter = ISO8601DateFormatter()
//        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        try container.encode(isoFormatter.string(from: timestamp), forKey: .timestamp)
//        try container.encode(othogonalAcceleration, forKey: .othogonalAcceleration)
//        try container.encode(acceleration, forKey: .acceleration)
//        try container.encode(attitude, forKey: .attitude)
//        try container.encode(attitude.angle.degrees, forKey: .attitudeAngle)
//        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.x).degrees, forKey: .pitchingAngle)
//        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.y).degrees, forKey: .rollingAngle)
//        try container.encode(Angle2DFloat(radians: attitude.eulerAngles(order: .xyz).angles.z).degrees, forKey: .yawingAngle)
//        try container.encode(angulerVelocity, forKey: .angulerVelocity)
//        try container.encode(isTurnSwitching, forKey: .isTurnSwitching)
//        try container.encode(percentageOfTurnsByAngle, forKey: .percentageOfTurnsByAngle)
//    }
//}
