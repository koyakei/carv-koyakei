//
//  carv_koyakeiWatchKitExtention.swift
//  carv-koyakeiWatchKitExtention
//
//  Created by keisuke koyanagi on 2025/10/16.
//

import AppIntents

struct carv_koyakeiWatchKitExtention: AppIntent {
    static var title: LocalizedStringResource { "carv-koyakeiWatchKitExtention" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
