//
//  ContentView.swift
//  carv-koyakei-watch Watch App
//
//  Created by keisuke koyanagi on 2025/10/12.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    var wcManager = WatchSessionManager()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        Button("エクスポートする") {
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(
                    ["command": "export"],
                    replyHandler: nil,
                    errorHandler: { error in
                        print("送信失敗: \(error.localizedDescription)")
                    }
                )
            } else {
                print("iPhoneに接続されていません")
            }
        }
        Button("start") {
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(
                    ["command": "startHeadAndBoard"],
                    replyHandler: nil,
                    errorHandler: { error in
                        print("送信失敗: \(error.localizedDescription)")
                    }
                )
            } else {
                print("iPhoneに接続されていません")
            }
        }
        TurnCountView()
    }
}

#Preview {
    ContentView()
}
import Combine

// Observable object to receive and publish the turn count
class TurnCountReceiver: NSObject, ObservableObject, WCSessionDelegate {
   
    
    @Published var finishedTurnCount: Int = 0
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    // Receive message from iOS
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let count = message["finishedTurnCount"] as? Int {
            self.finishedTurnCount = count
        }
    }
    // Required (but empty) delegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionReachabilityDidChange(_ session: WCSession) {}
}

// Example SwiftUI view for watchOS
struct TurnCountView: View {
    @StateObject private var receiver = TurnCountReceiver()
    var body: some View {
        VStack {
            Text("ターン数: \(receiver.finishedTurnCount)")
                .font(.title)
                .padding()
            Text("(iPhoneから受信)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    TurnCountView()
}
