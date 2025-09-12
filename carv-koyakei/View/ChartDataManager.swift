import SwiftUI

class Carv2AnalyzedDataPairManager :ObservableObject{
    @Published var currentTurn: [Carv2AnalyzedDataPair] = []
    @Published var beforeTurn: [Carv2AnalyzedDataPair] = []
    
    @Published var carv2DataPair: Carv2DataPair
    init( carv2DataPair: Carv2DataPair) {
        self.carv2DataPair = carv2DataPair
    }
//    @Published var carv2DataPair: Carv2DataPair
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
