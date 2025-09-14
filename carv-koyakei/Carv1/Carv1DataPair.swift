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
import Observation
import Spatial
import simd
import SwiftUI

@MainActor
@Observable
class Carv1DataPair {
    var left: Carv1Data = Carv1Data.init()
    var right: Carv1Data = Carv1Data.init()
    var yawingSide: YawingSide = .straight
    static let periferalName = "⛷CARV"
    public static let shared: Carv1DataPair = .init()
    // ipad
    static let rightCharactaristicUUID = UUID(uuidString: "8359EA93-4503-E6E0-4B65-65E281678DC3")
    static let leftCharactaristicUUID = UUID(uuidString:  "50556BC5-022C-57BC-6A90-9EA9EC7DACA7")
//    // iphone
//    static let rightCharactaristicUUID = UUID(uuidString: "85E2946B-0D18-FA01-E1C9-0393EDD9013A")
//    static let leftCharactaristicUUID = UUID(uuidString:  "57089C67-2275-E220-B6D3-B16E2639EFD6")
    @MainActor func calibrateForce () {
        left.calibrationPressure = left.rawPressure
        right.calibrationPressure = right.rawPressure
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
    
   
    
    
}

