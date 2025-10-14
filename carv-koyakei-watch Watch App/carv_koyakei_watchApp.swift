//
//  carv_koyakei_watchApp.swift
//  carv-koyakei-watch Watch App
//
//  Created by keisuke koyanagi on 2025/10/12.
//

import SwiftUI
import WatchConnectivity

@main
struct carv_koyakei_watch_Watch_AppApp: App {
//    @WKApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class WatchSessionManager: NSObject, WCSessionDelegate {
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // 必須デリゲートの空実装
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionReachabilityDidChange(_ session: WCSession) {}

    // エラーや応答が必要な場合はここに追記
}
