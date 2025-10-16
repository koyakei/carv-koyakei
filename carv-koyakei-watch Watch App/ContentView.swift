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
        
        Button("エクスポート") {
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
        Button("clear") {
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(
                    ["command": "clear"],
                    replyHandler: nil,
                    errorHandler: { error in
                        print("送信失敗: \(error.localizedDescription)")
                    }
                )
            } else {
                print("iPhoneに接続されていません")
            }
        }
        Button("stop") {
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(
                    ["command": "stop"],
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
    var session: WCSession = .default
    
    override init() {
        super.init()
        if WCSession.isSupported() {
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
            Text(receiver.session.isReachable.description)
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
