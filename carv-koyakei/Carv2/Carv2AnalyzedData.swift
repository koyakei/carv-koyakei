//
//  Carv2AnalyzedData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//
import Spatial
import Foundation

struct Carv2AnalyzedData {
    var attitude: Rotation3D
    var acceleration: SIMD3<Float>
    var angularVelocity : SIMD3<Float>
    let recordetTime: TimeInterval = Date.now.timeIntervalSince1970
    var rollAngle: Double {attitude.eulerAngles(order: .xyz).angles.x}
    var yawAngle: Double {attitude.eulerAngles(order: .xyz).angles.y}
    var pitchAngle: Double {attitude.eulerAngles(order: .xyz).angles.z}
}

struct Carv2AnalyzedDataPair :Identifiable{
    let id = UUID()
    var left: Carv2AnalyzedData
    var right: Carv2AnalyzedData
    var yawingSide: TurnYawingSide {
        get{
            switch unitedYawingAngle {
            case -.infinity..<Float(Angle2D(degrees: -1).radians):
                return TurnYawingSide.RightYawing
            case Float(Angle2D(degrees: 1).radians)...Float.infinity:
                return TurnYawingSide.LeftYawing
            default:
                return TurnYawingSide.Straight
            }
        }
    }
    var outsideSki: Carv2AnalyzedData {
        if yawingSide == .LeftYawing {
            return left
        } else {
            return right
        }
    }
    
    var insideSki: Carv2AnalyzedData {
        if yawingSide == .RightYawing {
            return right
        } else {
            return left
        }
    }
    
    var isTurnSwitching: Bool
    var unitedAttitude: simd_quatf {
        (left.attitude.quaternion + right.attitude.quaternion).normalized.simd_quatf
    }
    var percentageOfTurns: Float
    var unitedYawingAngle : Float {
        left.angularVelocity.y + right.angularVelocity.y
    }
    var numberOfTurns: Int
    var recordetTime: TimeInterval
}
