//
//  carv_koyakeiApp.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/01/23.
//

import SwiftUI
import CoreBluetooth

@main
struct carv_koyakeiApp: App {
    @StateObject private var carv2DataPair: Carv2DataPair = Carv2DataPair()
    @StateObject private var carv1DataPair: Carv1DataPair = Carv1DataPair()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(carv1DataPair).environmentObject(carv2DataPair) 
        }
    }
    
}
