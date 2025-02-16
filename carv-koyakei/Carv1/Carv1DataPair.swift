//
//  Carv1Data.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//

//
//  Untitled.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/06.
//
import Foundation
import Spatial
import simd
import SwiftUICore

public class Carv1DataPair :ObservableObject{
    @Published var left: Carv2Data = Carv2Data.init()
    @Published var right: Carv2Data = Carv2Data.init()
    var yawingSide: YawingSide = .straight
    static let periferalName = "⛷CARV"
    
    func signedAngleBetweenUpVectors(q1: simd_quatd, q2: simd_quatd) -> Double {
        let baseUp = simd_double3(0, 1, 0)
        let rotatedUp1 = q1.act(baseUp)
        let rotatedUp2 = q2.act(baseUp)
        
        let cross = simd_cross(rotatedUp1, rotatedUp2)
        let sign = simd_dot(cross, baseUp) >= 0 ? 1.0 : -1.0
        return sign * angleBetweenUpVectors(q1: q1, q2: q2)
    }
    func angleBetweenUpVectors(q1: simd_quatd, q2: simd_quatd) -> Double {
        // 基準の上方向ベクトル
        let baseUp = simd_double3(0, 1, 0)
        
        // 各クォータニオンで回転後の上方向ベクトルを取得
        let rotatedUp1 = q1.act(baseUp)
        let rotatedUp2 = q2.act(baseUp)
        
        // 内積から角度を計算（0〜πラジアン）
        let dot = simd_dot(rotatedUp1, rotatedUp2)
        return acos(dot)
    }
    
    var yawingDiffrencial: Double {
        return signedAngleBetweenUpVectors(q1: left.attitude.quaternion, q2: right.attitude.quaternion)
    }
    
    
}
