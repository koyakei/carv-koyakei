import SwiftUI
import SwiftData

struct SingleFinishedTurnDataListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var turns: [SkateBoardDataManager.SingleFinishedTurnData]
    
    var body: some View {
        NavigationStack {
            Text("\(turns.count)")
            List(turns, id: \.persistentModelID) { turn in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Turn #\(turn.numberOfTrun)")
                        .font(.headline)
                    Text("Started: \(turn.turnStartedTime.formatted(date: .numeric, time: .standard))")
                    Text("Ended: \(turn.turnEndedTime.formatted(date: .numeric, time: .standard))")
                    Text("Phases: \(turn.turnPhases.count)")
                    Text("Yawing Side: \(String(describing: turn.yawingSide))")
                    Text("Duration: \(turn.turnDuration, specifier: "%.2f")s")
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Saved Turns")
            .toolbar {
                Button("Add Test Data") {
                    let dummyPhase = SkateBoardAnalysedData()
                    let dummy = SkateBoardDataManager.SingleFinishedTurnData(numberOfTrun: Int.random(in: 1...10), turnPhases: [dummyPhase, dummyPhase])
                    modelContext.insert(dummy)
//                    try? modelContext.save()
                }
            }
        }
    }
}

#Preview {
    SingleFinishedTurnDataListView()
}
