import SwiftUI

class Carv2AnalyzedDataPairManager :ObservableObject{
    public static let shared: Carv2AnalyzedDataPairManager = .init()
    
    @Published var currentTurn: [Carv2AnalyzedDataPair] = []
    @Published var beforeTurn: [Carv2AnalyzedDataPair] = []
    
    func receive(data: Carv2AnalyzedDataPair){
        currentTurn.append(data)
        if currentTurn.count > 200 { // 20fps * 3 が最大だろう　２００は楽勝
            currentTurn.removeFirst()
        }
        
        if data.isTurnSwitching {
            self.beforeTurn = self.currentTurn
            self.currentTurn = []
        }
    }
}
