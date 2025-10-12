//
//  Record.swift
//  WatchConnectivitySampleForSwiftUI2
//
//  Created by Takuya Aso on 2022/02/09.
//

import Foundation

struct Record: Codable, Hashable {
    var calibrate: Bool
    var timeStamp: Date
}
