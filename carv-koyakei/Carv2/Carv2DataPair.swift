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

class Carv2DataPair : ObservableObject{
    @Published var left: Carv2Data = Carv2Data.init()
    @Published var right: Carv2Data = Carv2Data.init()
    public static let shared: Carv2DataPair = .init()
    var yawingSide: YawingSide = .straight
    static let periferalName = "CARV 2"
    // ipad
    static let rightCharactaristicUUID = UUID(uuidString: "85A29A4C-09C3-C632-858A-3387339C67CF")
    static let leftCharactaristicUUID = UUID(uuidString:  "850D8BCF-3B03-1322-F51C-DD38E961FC1A")
    // iphone
//    static let rightCharactaristicUUID = UUID(uuidString: "85E2946B-0D18-FA01-E1C9-0393EDD9013A")
//    static let leftCharactaristicUUID = UUID(uuidString:  "57089C67-2275-E220-B6D3-B16E2639EFD6")

    var yawingAngulerRateDiffrential: Float { Float(right.angularVelocity.y - left.angularVelocity.y)}


    
    
}
